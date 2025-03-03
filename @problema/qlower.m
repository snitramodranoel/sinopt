% @problema/qlower.m builds lower bounds for the qinopt problem.
%
% Copyright (c) 2014 Leonardo Martins, Universidade Estadual de Campinas
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
function [v0, q0, s0]= qlower(obj)
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
  ut= get(obj.si,'ut');
  uh= get(obj.si,'uh');
  th= get(obj.si,'th');

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
  
  % 
  % build membership matrices
  %
  obj= construir_G(obj);
  obj= construir_I(obj);

  % compute vector pih of maximum productivity coefficients
  pih = zeros(nu,1);
  for i = 1:nu
    % forebay coefficients
    cm = get(get(uh{i},'yc'), 'cf');
    % penstock head loss coefficients
    cp = get(get(uh{i},'yp'), 'cf');
    % tailrace coefficients
    yf = get(uh{i},'yf');
    cj = get(yf{1,2},'cf');
    % compute efficiency coefficients
    pe= get(uh{i},'pe');
    vm= get(uh{1},'vm');
    dn= get(uh{1},'dn');
    pih(i) = pe * (cm(2)*vm + cm(1) - cj(1) - cp(1) - (cj(2) + cp(2))*dn);
  end
  
  % 
  % build Pi matrix
  %
  Pi = sparse(1:obj.nq, 1:obj.nq, repmat(pih,[ni,1]), obj.nq, obj.nq, obj.nq);
  
  %
  % build Jacobian matrix
  %
  obj.J= spalloc(obj.m, obj.n, ...
      nnz(obj.A) + nnz(obj.B) + nnz(obj.C) + obj.nz + obj.nq);
  %
  obj.J(1:obj.ma, 1:obj.nx)= obj.A;
  obj.J(obj.ma+obj.mc+1:obj.m, obj.nx+1:obj.nx+obj.ny)= obj.B;
  obj.J(obj.ma+1:obj.ma+obj.mc, obj.nx+1:obj.nx+obj.ny)= obj.C;
  obj.J(obj.ma+obj.mc+1:obj.m, obj.nx+obj.ny+1:obj.n)= -obj.G;
  obj.J(obj.ma+obj.mc+1:obj.m, obj.na+1:obj.na+obj.nq)= -obj.I * Pi;

  % vector z
  c = zeros(nt,1);
  for t = 1:nt
    co = get(ut{t},'co');
    cf = get(co,'cf');
    c(t) = cf(3);
  end
  % clean up
  clear t;
  clear co;
  clear cf;
  
  %
  % build scaling matrix
  %
  k= 0;
  S= zeros(obj.nz, obj.nz);
  for j= 1:ni
    for t= 1:nt
      k= k+1;
      S(k,k)= th{1}(j) * 1e-3;
    end
  end
  S = sparse(S);
  
  %
  % build matrix Q of second-degree fuel cost function coefficients 
  %
  Q = sparse(1:obj.nz, 1:obj.nz, repmat(c,[ni,1]), obj.nz, obj.nz, obj.nz);

  % compute scaled-down coefficient matrix
  Q = Q * S;

  %
  % build lagrangian Hessian matrix
  %
  [rows, cols, vlus] = find(2*Q);
  obj.Hf= [(obj.nx+obj.ny) + rows, (obj.nx+obj.ny) + cols, vlus];

  % set up callbacks
  funcs.objective= @(x) compute_f(obj,x);
  funcs.constraints= @(x) compute_g(obj,x);
  funcs.gradient= @(x) compute_df(obj,x);
  funcs.jacobian= @(x) compute_Jg(obj,x);
  funcs.jacobianstructure= @jacobianstructure;
  funcs.hessian= @(x,sigma,lambda) tril(compute_H(obj,x,sigma,lambda));
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
  options.ipopt.linear_solver= 'mumps';
  options.ipopt.max_iter= obj.km;
  options.ipopt.mu_strategy= 'adaptive';
  options.ipopt.print_level= obj.dv;
  options.ipopt.tol= 1e-06;
  
  options.ipopt.jac_c_constant = 'yes';
  options.ipopt.hessian_constant = 'yes';
  %
  % solve problem
  [x,~]= ipopt(x,funcs,options);
  % compute solution
  v0= desempacotar_s(obj,extrair_s(obj,x));
  q0= desempacotar_q(obj,extrair_q(obj,x));
  s0= desempacotar_v(obj,extrair_v(obj,x));
  
  % 
  % callback functions
  %

  % compute objective function
  function psi= compute_f(obj,w)
    % unpack z variables
    z= extrair_z(obj,w);
    % compute complementary thermal power generation costs
    psi= z'*Q*z;
  end

  % compute constraints
  function g= compute_g(obj,w)
    g= obj.J * w;
  end

  % compute objective function gradient
  function df= compute_df(obj,w)
    % unpack z variables
    z= extrair_z(obj,w);
    df= [zeros(obj.nx+obj.ny,1) ;  2*Q*z];
  end

  % compute Jacobian matrix
  function Jg= compute_Jg(obj,~)
    Jg= obj.J;
  end

  % compute lagrangian Hessian matrix
  function H= compute_H(obj,~,sigma,~)
    H= sparse(obj.Hf(:,1), obj.Hf(:,2), sigma * obj.Hf(:,3), ...
        obj.n, obj.n, obj.n);
  end

  % compute Jacobian matrix structure
  function strct= jacobianstructure()
    [rows,cols,vlus]= find(obj.J);
    strct= sparse(rows, cols, vlus, obj.m, obj.n, length(rows));
  end

  % compute lagrangian Hessian matrix structure
  function strct= hessianstructure()
    strct= sparse(obj.Hf(:,1), obj.Hf(:,2), obj.Hf(:,3), obj.n, obj.n, obj.n);
  end
end