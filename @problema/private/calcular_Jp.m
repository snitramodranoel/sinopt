% @problema/private/calcular_Jp.m computes Jacobian of p(x).
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
function Jp= calcular_Jp(obj,w)
  % system data
  th= get(obj.si,'th');
  uh= get(obj.si,'uh');
  uf= get(obj.si,'uf');
  ur= get(obj.si,'ur');
  vi= get(obj.si,'vi');
  vf= get(obj.si,'vf');
  % system dimensions
  ni= get(obj.si,'ni');
  nf= get(obj.si,'nf');
  np= get(obj.si,'np');
  nq= get(obj.si,'nq');
  nr= get(obj.si,'nr');

  % unpack x variables
  ss= desempacotar_s(obj, extrair_s(obj,w));
  qq= desempacotar_q(obj, extrair_q(obj,w));
  vv= desempacotar_v(obj, extrair_v(obj,w));

  % compute number of connected buses
  nbr= 0;
  for i= 1:nr
    nbr= nbr + length(get(uh{ur(i)}, 'bc'));
  end
  nbf= 0;
  for i= 1:nf
    nbf= nbf + length(get(uh{uf(i)}, 'bc'));
  end
  
  % memory allocation for partial derivatives
  ds= zeros(nbr*(ni-1)*np, 1);
  dq= zeros((nbr+nbf)*ni*np, 1);
  dv= zeros((nbr+nbf)*ni*np, 1);
  
  % compute Jacobian
  k= 0;
  u= 0;
  for l= 1:np
    for j= 1:ni
      % check for final stage
      if j < ni
        a= ss(:,j);
      else
        for i= 1:nr
          a(i)= vf(ur(i));
        end
      end
      % compute indexes and partial derivatives for plants with a reservoir
      for i= 1:nr
        % scalar buffers
        s= a(i);
        q= qq{l}(ur(i),j);
        v= vv(ur(i),j);
        % check for power generation availability
        if nq(ur(i),j) > 0
          zeta= 1;
        else
          zeta= 0;
        end
        % for each connected bus...
        df= get(uh{ur(i)}, 'df');
        nbc= length(get(uh{ur(i)}, 'bc'));
        for b= 1:nbc
          % check for final stage
          if j < ni
            u = u+1;
            ds(u) = 1e-3 * th{l}(j) * df(b) * dpds(uh{ur(i)},zeta,s,q);
          end
          k = k+1;
          % discharge variables
          dq(k) = 1e-3 * th{l}(j) * df(b) * dpdq(uh{ur(i)},zeta,s,q,v);
          % spill variables
          dv(k) = 1e-3 * th{l}(j) * df(b) * dpdv(uh{ur(i)},zeta,q,v);
        end
      end
      % compute indexes and partial derivatives for run-off-river plants
      for i= 1:nf
        % scalar buffers
        s= vi(uf(i));
        q= qq{l}(uf(i),j);
        v= vv(uf(i),j);
        % check for power generation availability
        if nq(uf(i),j) > 0
          zeta= 1;
        else
          zeta= 0;
        end
        % for each connected bus...
        df= get(uh{uf(i)}, 'df');
        nbc= length(get(uh{uf(i)}, 'bc'));
        for b= 1:nbc
          k= k+1;
          % discharge variables
          dq(k) = 1e-3 * th{l}(j) * df(b) * dpdq(uh{uf(i)},zeta,s,q,v);
          % spill variables
          dv(k) = 1e-3 * th{l}(j) * df(b) * dpdv(uh{uf(i)},zeta,q,v);
        end
      end
    end
  end
  % build Jacobian matrix
  Jp= [ds;dq;dv];
end