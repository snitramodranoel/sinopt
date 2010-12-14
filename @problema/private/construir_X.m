% @problema/private/construir_X.m builds matrix X.
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
function obj = construir_X(obj)
  % system dimensions
  ni= get(obj.si,'ni');
  nu= get(obj.si,'nu');
  ti= get(obj.si,'ti');
  % matrix filling
  k= 0;
  obj.Xj= cell(ni,1);
  obj.X = spalloc(nu*ni, nu*ni, ni*(2*nu - 1));
  for j= 1:nu:nu*ni
    k= k+1;
    % unit conversion factor
    delta= ti(k)/10^6;
    % compute submatrix X(j)
    obj.Xj{j}= sparse(diag(ones(nu,1)*(1/delta)));
    % fill diagonal elements
    obj.X(j:j+nu-1, j:j+nu-1)= obj.Xj{j};
    if k > 1
      % fill subdiagonal elements
      obj.X(j:j+nu-1, j-nu:j-1)= -obj.Xj{j};
    end
  end
end