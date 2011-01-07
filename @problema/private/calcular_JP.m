% @problema/private/calcular_JP.m computes Jacobian of P(x).
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
function JP= calcular_JP(obj,w)
  % system data
  uh= get(obj.si,'uh');
  vf= get(obj.si,'vf');
  % system dimensions
  ni= get(obj.si,'ni');
  np= get(obj.si,'np');
  ns= get(obj.si,'ns');
  nu= get(obj.si,'nu');
  n = nu*ni;
  m = ns*ni;
  % compute number of nonzero elements
  nze= np*(2*n + obj.na);
  % unpack x variables
  s= desempacotar_s(obj, extrair_s(obj,w));
  q= desempacotar_q(obj, extrair_q(obj,w));
  v= desempacotar_v(obj, extrair_v(obj,w));
  % allocate memory for row index vectors
  lis= zeros(obj.na*np,1);
  liq= zeros(n*np,1);
  liv= zeros(n*np,1);
  % allocate memory for column index vectors
  cos= zeros(obj.na*np,1);
  coq= zeros(n*np,1);
  cov= zeros(n*np,1);
  % allocate memory for partial derivatives
  ds= zeros(obj.na*np,1);
  dq= zeros(n*np,1);
  dv= zeros(n*np,1);
  % compute Jacobian
  k= 0;
  u= 0;
  for l= 1:np
    for j= 1:ni
      % check for final stage
      if j < ni
        a= s(:,j);
      else
        a= vf;
      end
      % compute 
      for i= 1:nu
        k= k+1;
        % compute index vectors and partial derivatives for storage variables
        if j < ni % check for final stage
          u= u+1;
          ds(u) = dpds(uh{i}, a(i), q{l}(i,j));
          lis(u)= get(uh{i},'ss') + m*(l-1) + ns*(j-1);
          cos(u)= i + (nu*(j-1));
        end
        % compute index vectors and partial derivatives for discharge variables
        dq(k) = dpdq(uh{i}, a(i), q{l}(i,j), v(i,j));
        liq(k)= get(uh{i},'ss') + m*(l-1) + ns*(j-1);
        coq(k)= obj.na + n*(l-1) + nu*(j-1) + i;
        % compute index vectors and partial derivatives for spill variables
        dv(k) = dpdv(uh{i}, q{l}(i,j), v(i,j));
        liv(k)= get(uh{i},'ss') + m*(l-1) + ns*(j-1);
        cov(k)= obj.na + obj.nq + nu*(j-1) + i;
      end
    end
  end
  % build Jacobian
  li= [lis;liq;liv];
  co= [cos;coq;cov];
  dp= [ ds; dq; dv];
  JP= sparse(li, co, dp, obj.mb, obj.nx, nze);
end