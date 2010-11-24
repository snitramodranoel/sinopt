% @problema/private/construir_bring.m builds b vector.
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
function obj = construir_bring(obj)
  % system data
  af= get(obj.si,'af');
  ni= get(obj.si,'ni');
  nu= get(obj.si,'nu');
  ti= get(obj.si,'ti');
  uc= get(obj.si,'uc');
  vi= get(obj.si,'vi');
  % build vector
  b= zeros(nu,ni);
  for k= 1:nu
    up= upstream(obj.si,k);
    for j= 1:ni
      b(k,j)= af(k,j);
      for i= 1:length(up)
        b(k,j)= b(k,j) - af(up(i),j);
      end
    end
  end
  % consumptive use
  b= b - uc;
  % final reservoir storage requirements
  delta= ti(1)/10^6;
  b(:,1)= b(:,1) + (1/delta)*(vi);
  % data packing
  b= reshape(b,nu*ni,1);
  % data update
  obj.b= b;
end
