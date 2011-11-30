% @problema/private/ipo.m wrapper for IPOPT solver.
%
% Copyright (c) 2011 Leonardo Martins, Universidade Estadual de Campinas
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
function obj= ipo(obj)
  % set up callbacks
  funcs.objective= @(x) calcular_f(obj,x);
  funcs.constraints= @(x) calcular_g(obj,x);
  funcs.gradient= @(x) calcular_df(obj,x);
  funcs.jacobian= @(x) calcular_J(obj,x);
  funcs.jacobianstructure= @jacobianstructure;
  funcs.hessian= @(x,sigma,lambda) tril(calcular_H(obj,x,sigma,lambda));
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
  options.ipopt.constr_viol_tol= 1e-02;
  options.ipopt.linear_solver= 'ma57';
  options.ipopt.mu_strategy= 'adaptive';
  options.ipopt.print_level= 5;
  options.ipopt.tol= 1e-06;
  %
  % solve problem
  [x,info]= ipopt(x,funcs,options);
  % compute solution
  rs= resultado();
  y= info.lambda;
  rs= set(rs,'s',desempacotar_s(obj,extrair_s(obj,x)));
  rs= set(rs,'q',desempacotar_q(obj,extrair_q(obj,x)));
  rs= set(rs,'v',desempacotar_v(obj,extrair_v(obj,x)));
  rs= set(rs,'y',desempacotar_y(obj,extrair_y(obj,x)));
  rs= set(rs,'z',desempacotar_z(obj,extrair_z(obj,x)));
  rs= set(rs,'P',desempacotar_lambdab(obj,calcular_P(obj,x)));
  rs= set(rs,'Q',desempacotar_lambdab(obj,calcular_Q(obj,x)));
  rs= set(rs,'la',desempacotar_lambdaa(obj,extrair_lambdaa(obj,y)));
  rs= set(rs,'lb',desempacotar_lambdab(obj,extrair_lambdab(obj,y)));
  rs= set(rs,'uq',desempacotar_q(obj, extrair_q(obj,options.ub)));
  obj.rs= rs;
  %
  % subfunctions
  % @problema/private/ipo.m:jacobianstructure computes jacobian structure
  function J= jacobianstructure()
    li= [obj.J(:,1); obj.JP(:,1)];
    co= [obj.J(:,2); obj.JP(:,2)];
    len= length(li);
    vlu= ones(len,1);
    J= sparse(li, co, vlu, obj.m, obj.n, len);
  end
  %
  % % @problema/private/ipo.m:hessianstructure computes hessian structure
  function H= hessianstructure()
    li= obj.H(:,1);
    co= obj.H(:,2);
    len= length(li);
    vlu= ones(len,1);
    H= tril(sparse(li, co, vlu, obj.n, obj.n, len));
  end
end
