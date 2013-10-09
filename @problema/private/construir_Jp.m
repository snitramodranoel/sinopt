% @problema/private/construir_Jp.m builds structure of Jacobian of p(x).
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
function obj= construir_Jp(obj)
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

  % shortcuts
  n = nu*ni;
  m = ns*ni;

  % compute number of connected buses
  nbr= 0;
  for i= 1:nr
    nbr= nbr + length(get(uh{ur(i)}, 'bc'));
  end
  nbf= 0;
  for i= 1:nf
    nbf= nbf + length(get(uh{uf(i)}, 'bc'));
  end

  % memory allocation for row index vectors
  lis= zeros(nbr*(ni-1)*np, 1);
  liq= zeros((nbr+nbf)*ni*np, 1);
  liv= zeros((nbr+nbf)*ni*np, 1);
  % memory allocation for column index vectors
  cos= zeros(nbr*(ni-1)*np, 1);
  coq= zeros((nbr+nbf)*ni*np, 1);
  cov= zeros((nbr+nbf)*ni*np, 1);
  
  k= 0;
  u= 0;
  % compute the structure of the Jacobian of p(x)
  for l= 1:np
    for j= 1:ni
      % compute indexes for plants with a reservoir
      for i= 1:nr
        % for each connected bus...
        bc= get(uh{ur(i)}, 'bc');
        for b= 1:length(bc)
          % check for final stage
          if j < ni
            u = u+1;
            lis(u)= bc(b) + m*(l-1) + ns*(j-1);
            cos(u)= i + (nr*(j-1));
          end
          k = k+1;
          % discharge variables
          liq(k)= bc(b) + m*(l-1) + ns*(j-1);
          coq(k)= obj.na + n*(l-1) + nu*(j-1) + ur(i);
          % spill variables
          liv(k)= bc(b) + m*(l-1) + ns*(j-1);
          cov(k)= obj.na + obj.nq + nu*(j-1) + ur(i);
        end
      end
      % compute indexes for run-off-river plants
      for i= 1:nf
        % for each connected bus...
        bc= get(uh{uf(i)}, 'bc');
        for b= 1:length(bc)
          k= k+1;
          % discharge variables
          liq(k)= bc(b) + m*(l-1) + ns*(j-1);
          coq(k)= obj.na + n*(l-1) + nu*(j-1) + uf(i);
          % spill variables
          liv(k)= bc(b) + m*(l-1) + ns*(j-1);
          cov(k)= obj.na + obj.nq + nu*(j-1) + uf(i);
        end
      end
    end
  end
  % buffer
  li= [lis;liq;liv];
  co= [cos;coq;cov];
  % memory allocation
  obj.Jp= zeros(length(lis)+length(liq)+length(liv), 2);
  obj.Jp(:,1)= (obj.ma+obj.mc)*ones(length(li),1) + li;
  obj.Jp(:,2)= co;
end