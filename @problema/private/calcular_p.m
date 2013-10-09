% @problema/private/calcular_p.m evaluates p(.) affine function.
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
function pp= calcular_p(obj,w)
  % system data
  uf= get(obj.si,'uf');
  uh= get(obj.si,'uh');
  ur= get(obj.si,'ur');
  vi= get(obj.si,'vi');
  vf= get(obj.si,'vf');
  % system dimensions
  nf= get(obj.si,'nf');
  ni= get(obj.si,'ni');
  np= get(obj.si,'np');
  nq= get(obj.si,'nq');
  nr= get(obj.si,'nr');
  nu= get(obj.si,'nu');
  % unpack x variables
  ss = desempacotar_s(obj, extrair_s(obj,w));
  qq = desempacotar_q(obj, extrair_q(obj,w));
  vv = desempacotar_v(obj, extrair_v(obj,w));
  
  % memory allocation
  a = zeros(nr,1);
  pp= zeros(nu*ni*np, 1);
  
  % compute p() affine function
  for l= 1:np
    for j= 1:ni
      % check for final stage
      if (j < ni)
        a= ss(:,j);
      else
        for i= 1:nr
          a(i)= vf(ur(i));
        end
      end
      % run-off-river plants
      for i= 1:nf
        s= vi(uf(i));
        q= qq{l}(uf(i),j);
        v= vv(uf(i),j);
        % check for power generation availability
        if nq(uf(i),j) > 0
          zeta= 1;
        else
          zeta= 0;
        end
        pp(nu*(ni*(l-1) + (j-1)) + uf(i))= p(uh{uf(i)}, zeta, s, q, v);
      end
      % plants with reservoirs
      for i= 1:nr
        s= a(i);
        q= qq{l}(ur(i),j);
        v= vv(ur(i),j);
        % check for power generation availability
        if nq(ur(i),j) > 0
          zeta= 1;
        else
          zeta= 0;
        end
        pp(nu*(ni*(l-1) + (j-1)) + ur(i))= p(uh{ur(i)}, zeta, s, q, v);
      end
    end
  end
end