% @problema/private/construir_G.m builds bus-plant membership matrix G.
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

function obj= construir_G(obj)
  % system data
  ut= get(obj.si,'ut');
  th= get(obj.si,'th');
  % system dimensions
  ni= get(obj.si,'ni');
  np= get(obj.si,'np');
  ns= get(obj.si,'ns');
  nt= get(obj.si,'nt');
  % sum up number of bus-plant assignments
  nbc= 0;
  for t= 1:nt
    nbc= nbc + length(get(ut{t}, 'bc'));
  end
  % compute number of nonzero elements in the matrix
  nze= nbc * ni * np;
  % memory allocation
  Gi= zeros(nze,1);
  Gj= zeros(nze,1);
  Gs= zeros(nze,1);
  % assign distribution factors to membership matrix elements
  k= 0;
  for l= 1:np
    for j= 1:ni
      for t= 1:nt
        bc= get(ut{t}, 'bc');
        df= get(ut{t}, 'df');
        for b= 1:length(bc)
          k= k+1;
          Gs(k)= 1e-3 * th{l}(j) * df(b);       % distribution factor
          Gi(k)= ns*(ni*(l-1) + (j-1)) + bc(b); % row
          Gj(k)= nt*(ni*(l-1) + (j-1)) + t;     % column
        end
      end
    end
  end
  % build sparse matrix
  obj.G= sparse(Gi, Gj, Gs, obj.mb, obj.nz);
end