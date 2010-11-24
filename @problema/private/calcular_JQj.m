% @problema/private/calcular_JQj.m computes the Jacobian matrix of Q(j).
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
function J= calcular_JQj(obj,j)
  % system data
  ut= get(obj.si,'ut');
  % system dimensions
  ni= get(obj.si,'ni');
  ns= get(obj.si,'ns');
  nt= get(obj.si,'nt');
  % allocate room for partial derivatives
  dz= spalloc(nt,ns,nt);
  % compute partial derivatives for all 
  %% calcula derivadas parciais para todas usinas agrupadas por subsistema
  for k= 1:nt
    dz(k,get(ut{k},'ss'))= 1; % TODO: Is this correct?
  end
  % compute gradients of Q(j)
  J= spalloc(ns,obj.nz,nt);
  dQkz= spalloc(nt,ni,nt);
  for k= 1:ns
    dQkz(:,j)= dz(:,k);
    J(k,:)= reshape(dQkz,1,nt*ni);
    % reset gradients
    dQkz(:,j)= 0 * dQkz(:,j);
  end
end