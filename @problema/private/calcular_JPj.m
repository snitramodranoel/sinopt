% @problema/private/calcular_JPj.m computes the Jacobian matrix of P(j).
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
function J= calcular_JPj(obj,j,s,q,v)
  % system dimensions
  ni= get(obj.si,'ni');
  ns= get(obj.si,'ns');
  nu= get(obj.si,'nu');
  % list of hydro plants
  uh= get(obj.si,'uh');
  % allocate room for partial derivatives
  ds= spalloc(nu,ns,nu);
  dq= spalloc(nu,ns,nu);
  dv= spalloc(nu,ns,nu);
  % compute partial derivatives for all hydro plants grouped by system
  for i= 1:nu
    k= get(uh{i},'ss');
    [ds(i,k), dq(i,k), dv(i,k)]= dp(uh{i},s(i),q(i),v(i));
  end
  % compute gradients of P(j)
  J= spalloc(ns,obj.nx,3*nu);
  dPks= spalloc(nu,ni,nu);
  dPkq= spalloc(nu,ni,nu);
  dPkv= spalloc(nu,ni,nu);
  for k= 1:ns
    dPks(:,j)= ds(:,k);
    dPkq(:,j)= dq(:,k);
    dPkv(:,j)= dv(:,k);
    J(k,:)= [reshape(dPks,1,nu*ni), ...
             reshape(dPkq,1,nu*ni), ...
             reshape(dPkv,1,nu*ni)];
    % reset gradients
    dPks(:,j)= 0 * dPks(:,j);
    dPkq(:,j)= 0 * dPkq(:,j);
    dPkv(:,j)= 0 * dPkv(:,j);
  end
end