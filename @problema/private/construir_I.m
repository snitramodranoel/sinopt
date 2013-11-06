% @problema/private/construir_I.m builds bus-plant membership matrix I.
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

function obj= construir_I(obj)
  % system data
  uh= get(obj.si,'uh');
  th= get(obj.si,'th');
  % system dimensions
  ni= get(obj.si,'ni');
  np= get(obj.si,'np');
  ns= get(obj.si,'ns');
  nu= get(obj.si,'nu');
  % sum up number of bus-plant assignments
  nbc= 0;
  for i= 1:nu
    nbc= nbc + length(get(uh{i}, 'bc'));
  end
  % compute number of nonzero elements in the matrix
  nze= nbc * ni * np;
  % memory allocation
  Ii= zeros(nze,1);
  Ij= zeros(nze,1);
  Is= zeros(nze,1);
  % assign distribution factors to membership matrix elements
  k= 0;
  for l= 1:np
    for j= 1:ni
      for i= 1:nu
        bc= get(uh{i}, 'bc');
        df= get(uh{i}, 'df');
        for b= 1:length(bc)
          k= k+1;
          Is(k)= th{l}(j) * df(b);              % distribution factor
          Ii(k)= ns*(ni*(l-1) + (j-1)) + bc(b); % row
          Ij(k)= nu*(ni*(l-1) + (j-1)) + i;     % column
        end
      end
    end
  end
  % build sparse matrix
  obj.I= sparse(Ii, Ij, Is, obj.mb, nu*ni*np);
end