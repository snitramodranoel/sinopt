% @problema/private/construir_JP.m builds structure of Jacobian of P(x).
%
% Copyright (c) 2011 Leonardo Martins, Universidade Estadual de Campinas
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
function obj= construir_JP(obj)
  % system data
  uh= get(obj.si,'uh');
  uf= get(obj.si,'uf');
  ur= get(obj.si,'ur');
  % system dimensions
  ni= get(obj.si,'ni');
  nf= get(obj.si,'nf');
  np= get(obj.si,'np');
  nr= get(obj.si,'nr');
  ns= get(obj.si,'ns');
  nu= get(obj.si,'nu');
  n = nu*ni;
  m = ns*ni;
  % allocate memory for row index vectors
  lis= zeros(obj.na*np,1);
  liq= zeros(n*np,1);
  liv= zeros(n*np,1);
  % allocate memory for column index vectors
  cos= zeros(obj.na*np,1);
  coq= zeros(n*np,1);
  cov= zeros(n*np,1);
  % compute Jacobian
  k= 0;
  u= 0;
  for l= 1:np
    for j= 1:ni
      % compute indexes for plants with a reservoir
      for i= 1:nr
        % check for final stage
        if j < ni
          u = u+1;
          lis(u)= get(uh{ur(i)},'ss') + m*(l-1) + ns*(j-1);
          cos(u)= i + (nr*(j-1));
        end
        k = k+1;
        % discharge variables
        liq(k)= get(uh{ur(i)},'ss') + m*(l-1) + ns*(j-1);
        coq(k)= obj.na + n*(l-1) + nu*(j-1) + ur(i);
        % spill variables
        liv(k)= get(uh{ur(i)},'ss') + m*(l-1) + ns*(j-1);
        cov(k)= obj.na + obj.nq + nu*(j-1) + ur(i);
      end
      % compute indexes for run-off-river plants
      for i= 1:nf
        k= k+1;
        % discharge variables
        liq(k)= get(uh{uf(i)},'ss') + m*(l-1) + ns*(j-1);
        coq(k)= obj.na + n*(l-1) + nu*(j-1) + uf(i);
        % spill variables
        liv(k)= get(uh{uf(i)},'ss') + m*(l-1) + ns*(j-1);
        cov(k)= obj.na + obj.nq + nu*(j-1) + uf(i);
      end
    end
  end
  % buffer
  li= [lis;liq;liv];
  co= [cos;coq;cov];
  % memory allocation
  obj.JP= zeros(length(lis)+length(liq)+length(liv), 2);
  obj.JP(:,1)= (obj.ma+obj.mc)*ones(length(li),1) + li;
  obj.JP(:,2)= co;
end