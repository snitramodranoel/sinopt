% @problema/qlower.m builds lower bounds for the qinopt problem.
%
% Copyright (c) 2013 Leonardo Martins, Universidade Estadual de Campinas
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions
% are met:
%
% 1. Redistributions of source code must retain the above copyright
%    notice, this list of conditions and the following disclaimer.
% 2. Redistributions in binary form must reproduce the above copyright
%    notice, this list of conditions and the following disclaimer in the
%    documentation and/or other materials provided with the distribution.
% 3. The name of the author may not be used to endorse or promote products
%    derived from this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
% IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
% OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
% IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
% INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
% NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
% DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
% THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
% THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
function obj= qlower(obj)
  % swap plants between ROR and regulation reservoir lists
  obj= swap(obj);
  % system dimensions
  nc= get(obj.si,'nc');
  ni= get(obj.si,'ni');
  nl= get(obj.si,'nl');
  np= get(obj.si,'np');
  nr= get(obj.si,'nr');
  ns= get(obj.si,'ns');
  nt= get(obj.si,'nt');
  nu= get(obj.si,'nu');
  % system data
  ut = get(obj.si,'ut');
  uh = get(obj.si,'uh');
    
  % variable-space dimensions
  obj.na= nr*(ni-1);
  obj.nq= nu*ni*np;
  obj.nv= nu*ni;
  obj.nx= obj.na + obj.nq + obj.nv;
  obj.ny= nl*np*ni;
  obj.nz= nt*np*ni;
  obj.n = obj.nx + obj.ny + obj.nz;
  % constraint-space dimensions
  obj.ma= nu*ni;
  obj.mb= ns*np*ni;
  obj.mc= nc*np*ni;
  obj.m = obj.ma + obj.mb + obj.mc;
  % box constraints
  obj= construir_lb(obj);
  obj= construir_ub(obj);
  % hydro constraints
  obj= construir_bb(obj);
  obj= construir_A(obj);
  % power constraints
  obj= construir_d(obj);
  obj= construir_B(obj);
  obj= construir_C(obj);
  % check for data sanity
  obj= verificar(obj);
  % build membership matrices
  obj= construir_G(obj);
  obj= construir_I(obj);
  % compute matrix structures
  %obj= construir_J(obj);
  %obj= construir_H(obj);
  
  % vector z
  c = zeros(nt,1);
  for t = 1:nt
      co = get(ut{t},'co');
      cf = get(co,'cf');
      c(t) = cf(3);
  end
  
  % matrix Q
  Q = sparse(1:obj.nz, 1:obj.nz, repmat(c,[ni,1]), obj.nz, obj.nz, obj.nz);
  
  % compute vector Pi
  pi = zeros(nu,1);
  for i = 1:nu
    ym = get(uh{i},'yc');
    ym_cf = get(ym,'cf');
    yf = get(uh{i},'yf');
    yf_cf = get(yf{1,2},'cf');
    pc = get(uh{i},'pc');
    if pc{1} == 1
       pc_cf(1) = 0;
       pc_cf(2) = pc{2}; 
    elseif pc{1} == 2
       pc_cf(2) = 0;
       pc_cf(1) = pc{2};
    end
    pi(i) = get(uh{i},'pe') * (ym_cf(2) * get(uh{1},'vm') + ym_cf(1) - yf_cf(1) - pc_cf(1) - (yf_cf(2) + pc_cf(2)) * get(uh{1},'dn'));
  end
  
  Pi = sparse(1:obj.nq, 1:obj.nq, repmat(pi,[ni,1]), obj.nq, obj.nq, obj.nq);
  
  % Construct Jacobian
  nze= nnz(obj.A) + nnz(obj.B) + nnz(obj.C) + obj.nz + obj.nq;
  % compute constant elements
  J= spalloc(obj.m, obj.n, nze);
  J(1:obj.ma, 1:obj.nx)= obj.A;
  J(obj.ma+obj.mc+1:obj.m, obj.nx+1:obj.nx+obj.ny)= obj.B;
  J(obj.ma+1:obj.ma+obj.mc, obj.nx+1:obj.nx+obj.ny)= obj.C;
  J(obj.ma+obj.mc+1:obj.m, obj.nx+obj.ny+1:obj.n)= -obj.G;
  J(obj.ma+obj.mc+1:obj.m, obj.na+1:obj.na+obj.nq)= -obj.I * Pi;
  [rows,cols,vlus]= find(J);
  % compute structure
  Jest= zeros(length(rows),3);
  Jest(:,1)= rows;
  Jest(:,2)= cols;
  Jest(:,3)= vlus;
 
  % Hessian
  % memory allocation
  %Hf= zeros(obj.nz,2);
  % compute row, column indexes
  %for ii= 1:obj.nz
  %  Hf(ii,1)= obj.nx + obj.ny + ii;
  %  Hf(ii,2)= Hf(ii,1);
  %end
  Hf = 2*Q;
    
  % ??????????
  obj= construir_Hg(obj);
    
  H(:,1)= [obj.Hg(:,1); Hf(:,1)];
  H(:,2)= [obj.Hg(:,2); Hf(:,2)];
  
  H= sparse(H(:,1), ...
      H(:,2), ...
      [Hg; Hf], ...
      obj.n, ...
      obj.n, ...
      length(obj.H(:,1)));
  
  % memory allocation for object @resultado
  rs= resultado();
  % set up callbacks
  funcs.objective= @(x) calc_f(obj,x);
  funcs.constraints= @(x) calc_g(obj,x);
  funcs.gradient= @(x) calc_df(obj,x);
  funcs.jacobian= @(x) calc_J(obj,x);
  funcs.jacobianstructure= @jacobianstructure;
  funcs.hessian= @(x,sigma,lambda) tril(calc_H(obj,x,sigma,lambda));
  funcs.hessianstructure= @hessianstructure;
  % set up variable bounds
  options.lb= [obj.ls; obj.lq; obj.lv; obj.ly; obj.lz];
  options.ub= [obj.us; obj.uq; obj.uv; obj.uy; obj.uz];
  % set up constraint bounds
  options.cl= [obj.b; zeros(obj.mc,1); -obj.d];
  options.cu= options.cl;
  % set up initial primal solution
  x= mean([options.lb'; options.ub'])';
  % set up initial dual solution
  options.zl= max(abs(x),10);
  options.zu= max(abs(x),10);
  options.lambda= ones(obj.m,1);
  % set up solver options
  options.ipopt.bound_relax_factor= 1e-06;
  options.ipopt.constr_viol_tol= 1e-06;
  if get(obj, 'n') > 2048
    options.ipopt.linear_solver= 'mumps';
  else
    options.ipopt.linear_solver= 'ma57';
  end
  options.ipopt.max_iter= obj.km;
  options.ipopt.mu_strategy= 'adaptive';
  options.ipopt.print_level= obj.dv;
  options.ipopt.tol= 1e-06;
  
  options.ipopt.jac_c_constant = 'yes';
  options.ipopt.hessian_constant = 'yes';
  %
  % solve problem
  [x,info]= ipopt(x,funcs,options);
  % compute solution
  y= info.lambda;
  rs= set(rs,  's', desempacotar_s(obj,extrair_s(obj,x)));
  rs= set(rs,  'q', desempacotar_q(obj,extrair_q(obj,x)));
  rs= set(rs,  'v', desempacotar_v(obj,extrair_v(obj,x)));
  rs= set(rs,  'y', desempacotar_y(obj,extrair_y(obj,x)));
  rs= set(rs,  'z', desempacotar_z(obj,extrair_z(obj,x)));
  rs= set(rs, 'lz', desempacotar_z(obj,obj.lz));
  rs= set(rs,  'P', desempacotar_lambdab(obj,obj.Iu*calcular_p(obj,x)));
  rs= set(rs,  'Q', desempacotar_lambdab(obj,obj.Gu*extrair_z(obj,x)));
  rs= set(rs, 'lQ', desempacotar_lambdab(obj,obj.Gu*extrair_z(obj,options.lb)));
  rs= set(rs, 'la', desempacotar_lambdaa(obj,extrair_lambdaa(obj,y)));
  rs= set(rs, 'lb', desempacotar_lambdab(obj,extrair_lambdab(obj,y)));
  rs= set(rs, 'uq', desempacotar_q(obj,extrair_q(obj,options.ub)));
  switch info.status
    case {0,1}
      rs= set(rs,'status',0);
      rs= set(rs,'message','Optimal solution found');
    otherwise
      rs= set(rs,'status',1);
      rs= set(rs,'message','No primal-dual optimal solution found');
  end
  
  %callbacks

  function f= calc_f(obj,w)
      % unpack z variables
      z= extrair_z(obj,w);
      % compute complementary thermal power generation costs
      f= z'*Q*z;
  end

  function g= calc_g(obj,w)
    % unpack z
    z= extrair_z(obj,w);
    q= extrair_q(obj,w);
    % solve constraints
    g= [calcular_Ax(obj,w); ...
        calcular_Cy(obj,w); ...
        calcular_By(obj,w) - (obj.I * Pi * q) - (obj.G * z)];
  end

  function df= calc_df(obj,w)
      % unpack z variables
      z= extrair_z(obj,w);
      df= [zeros(obj.nx+obj.ny,1) ;  2*Q*z];
  end

  function Jresp= calc_J(obj,x)
    Jresp = J;
  end

  function Hresp= calc_H(obj,u,sigma,lambda)
    Hresp = H;
  end

  function J= jacobianstructure()
    li= [Jest(:,1)];
    co= [Jest(:,2)];
    len= length(li);
    vlu= ones(len,1);
    J= sparse(li, co, vlu, obj.m, obj.n, len);
  end

  function H= hessianstructure()
    li= H(:,1);
    co= H(:,2);
    en= length(li);
    vlu= ones(len,1);
    H= tril(sparse(li, co, vlu, obj.n, obj.n, len));
  end
end