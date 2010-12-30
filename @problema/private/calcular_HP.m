% @problema/private/calcular_HP.m computes Hessian of P(x).
%
% Copyright (c) 2010 Leonardo Martins, Universidade Estadual de Campinas
%
% @package sinopt
% @author  Leonardo Martins
% @version SVN: $Id$
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
function HP= calcular_HP(obj,w,lambda)
  % system data
  uh= get(obj.si,'uh');
  % system dimensions
  ni= get(obj.si,'ni');
  np= get(obj.si,'np');
  nu= get(obj.si,'nu');
  n = nu*ni;
  % unpack primal variables
  s= desempacotar_s(obj, extrair_s(obj,w));
  q= desempacotar_q(obj, extrair_q(obj,w));
  v= desempacotar_v(obj, extrair_v(obj,w));
  % unpack dual variables
  yb= desempacotar_lambdab(obj, extrair_lambdab(obj,lambda));
  % allocate memory for row index vectors
  liss= zeros(n,1);
  lisq= zeros(n*np,1);
  liqs= zeros(n*np,1);
  liqq= zeros(n*np,1);
  liqv= zeros(n*np,1);
  livq= zeros(n*np,1);
  livv= zeros(n,1);
  % allocate memory for column index vectors
  coss= zeros(n,1);
  cosq= zeros(n*np,1);
  coqs= zeros(n*np,1);
  coqq= zeros(n*np,1);
  coqv= zeros(n*np,1);
  covq= zeros(n*np,1);
  covv= zeros(n,1);
  % allocate memory for partial derivatives
  dss= zeros(n,1);
  dsq= zeros(n*np,1);
  dqq= zeros(n*np,1);
  dqv= zeros(n*np,1);
  dvv= zeros(n,1);
  % compute Hessian
  k= 0;
  u= 0;
  for j= 1:ni
    for i= 1:nu
      u= u+1;
      % compute row indexes for dp/dss, dp/dvv partial derivatives
      liss(u)= u;
      livv(u)= n*(np+1) + u;
      % compute column indexes for dp/dss, dp/dvv partial derivatives
      coss(u)= liss(u);
      covv(u)= livv(u);
      for l= 1:np
        k= k+1;
        % compute row indexes
        lisq(k)= liss(u);
        liqq(k)= n*((l-1) + 1) + u;
        liqv(k)= liqq(k);
        % compute column indexes
        cosq(k)= n*((l-1) + 1) + u;
        coqq(k)= liqq(k);
        coqv(k)= covv(u);
        % compute tranpose indexes
        liqs(k)= cosq(k);
        livq(k)= coqv(k);
        coqs(k)= lisq(k);
        covq(k)= liqv(k);
        % temporary buffer
        y= yb{l}(get(uh{i},'ss'),j);
        % compute partial derivatives
        dss(u)= dss(u) + y * dpdss(uh{i},s(i,j),q{l}(i,j));
        dsq(k)= y * dpdsq(uh{i},s(i,j));
        dqq(k)= y * dpdqq(uh{i},q{l}(i,j),v(i,j));
        dqv(k)= y * dpdqv(uh{i},q{l}(i,j),v(i,j));
        dvv(k)= dvv(u) + y * dpdvv(uh{i},q{l}(i,j),v(i,j));
      end
    end
  end
  % concatenate vectors
  li= [liss; lisq; cosq; liqq; liqv; livq; livv];
  co= [coss; cosq; coqs; coqq; coqv; covq; covv];
  dp= [ dss;  dsq;  dsq;  dqq;  dqv;  dqv;  dvv];
  % build Hessian
  HP= sparse(li, co, dp, obj.nx, obj.nx, n*(5*np+2));
end