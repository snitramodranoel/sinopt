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
  ur= get(obj.si,'ur');
  vf= get(obj.si,'vf');
  % system dimensions
  ni= get(obj.si,'ni');
  np= get(obj.si,'np');
  nu= get(obj.si,'nu');
  nr= get(obj.si,'nr');
  n = nu*ni;
  % compute number of nonzeros elements
  nze= obj.na*(2*np + 1) + n*(3*np + 1);
  % unpack primal variables
  s= desempacotar_s(obj, extrair_s(obj,w));
  q= desempacotar_q(obj, extrair_q(obj,w));
  v= desempacotar_v(obj, extrair_v(obj,w));
  % unpack dual variables
  yb= desempacotar_lambdab(obj, extrair_lambdab(obj,lambda));
  % allocate memory for row index vectors
  liss= zeros(obj.na,1);
  lisq= zeros(obj.na*np,1);
  liqs= zeros(obj.na*np,1);
  liqq= zeros(n*np,1);
  liqv= zeros(n*np,1);
  livq= zeros(n*np,1);
  livv= zeros(n,1);
  % allocate memory for column index vectors
  coss= zeros(obj.na,1);
  cosq= zeros(obj.na*np,1);
  coqs= zeros(obj.na*np,1);
  coqq= zeros(n*np,1);
  coqv= zeros(n*np,1);
  covq= zeros(n*np,1);
  covv= zeros(n,1);
  % allocate memory for partial derivatives
  dss= zeros(obj.na,1);
  dsq= zeros(obj.na*np,1);
  dqq= zeros(n*np,1);
  dqv= zeros(n*np,1);
  dvv= zeros(n,1);
  % compute Hessian
  k= 0;
  u= 0;
  r= 0;
  t= 0;
  for j= 1:ni
    % check for final stage
    if j < ni
      a= s(:,j);
    else
      for i= 1:nr
        a(i)= vf(ur(i));
      end
    end
    % reset index of plants with a reservoir
    z = 0;
    % perform computations
    for i= 1:nu
      ror= get(uh{i},'ie');
      % check for plants with a reservoir
      if ~ror
        z= z+1;
        % check for final stage
        if j < ni
          r= r+1;
          % compute row, column indexes for dp/dss partial derivatives
          liss(r)= r;
          coss(r)= liss(r);
        end
      end
      % compute row, column indexes for dp/dvv partial derivatives
      u= u+1;
      livv(u)= obj.na + obj.nq + u;
      covv(u)= livv(u);
      for l= 1:np
        k= k+1;
        % buffer
        y= yb{l}(get(uh{i},'ss'),j);
        % check for plants with a reservoir
        if ~ror
          % check for final stage
          if j < ni
            t= t+1;
            % compute row, column indexes for dp/dsq partial derivatives
            lisq(t)= liss(r);
            cosq(t)= obj.na + n*(l-1) + u;
            % compute transpose indexes for dp/dqs partial derivatives
            liqs(t)= cosq(t);
            coqs(t)= lisq(t);
            % compute dp/dss and dp/dsq partial derivatives
            dss(r)= dss(r) + y * dpdss(uh{i},a(z),q{l}(i,j));
            dsq(t)= y * dpdsq(uh{i},a(z));
          end
        end
        % compute row indexes for dp/dqq and dp/dqv partial derivatives
        liqq(k)= obj.na + n*(l-1) + u;
        liqv(k)= liqq(k);
        % compute column indexes for dp/dqq and dp/dqv partial derivatives
        coqq(k)= liqq(k);
        coqv(k)= covv(u);
        % compute tranpose indexes for dp/dvq partial derivatives
        livq(k)= coqv(k);
        covq(k)= liqv(k);
        % compute partial derivatives
        dqq(k)= y * dpdqq(uh{i},q{l}(i,j),v(i,j));
        dqv(k)= y * dpdqv(uh{i},q{l}(i,j),v(i,j));
        dvv(u)= dvv(u) + y * dpdvv(uh{i},q{l}(i,j),v(i,j));
      end
    end
  end
  % concatenate vectors
  li= [liss; lisq; cosq; liqq; liqv; livq; livv];
  co= [coss; cosq; coqs; coqq; coqv; covq; covv];
  dp= [ dss;  dsq;  dsq;  dqq;  dqv;  dqv;  dvv];
  % build Hessian
  HP= sparse(li, co, dp, obj.nx, obj.nx, nze);
end