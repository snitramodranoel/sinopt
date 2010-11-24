% @problema/private/calcular_Hf.m computes Hessian of f(z).
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
function Hf= calcular_Hf(obj,u)
  % list of thermal plants
  ut= get(obj.si,'ut');
  % system dimensions
  ni= get(obj.si,'ni');
  nt= get(obj.si,'nt');
  ti= get(obj.si,'ti');
  % unpack z variables
  mz= obter_mz(obj,u);
  % compute Hessian
  ZZ= spalloc(obj.nz, obj.nz, obj.nz);
  for k= 1:nt
    cg= get(ut{k},'cg');
    for j= 1:ni
      % compute partial derivatives
      ZZ(k+((j-1)*nt),k+((j-1)*nt))= derivar(cg,2,mz(k,j),(ti(j)/3600)/730);
    end
  end
  % fill Hessian elements
  Hf= spalloc(obj.n, obj.n, obj.nz);
  Hf(obj.nx+obj.ny+1:obj.n, obj.nx+obj.ny+1:obj.n)= ZZ;
end