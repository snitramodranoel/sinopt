% @problema/private/inverter_D.m computes the inverse of D.
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
function Di= inverter_D(obj,D)
  %% desempacota Dx, Dy, Dz
  Dx= obter_Dx(obj,D);
  Dy= obter_Dy(obj,D);
  Dz= obter_Dz(obj,D);
  %% calcula inversas
  %  (Dx)
  Dx= inverter_Dx(obj,Dx);
  %  (Dy)
  Dy= inverter_Dy(obj,Dy);
  %  (Dz)
  Dz= inverter_Dz(obj,Dz);
  %% empacota blocos
  Di= spalloc(obj.n, obj.n, nzmax(D));
  Di(1:obj.nx, 1:obj.nx)= Dx;
  Di(obj.nx+1:obj.nx+obj.ny, obj.nx+1:obj.nx+obj.ny)= Dy;
  Di(obj.nx+obj.ny+1:obj.n, obj.nx+obj.ny+1:obj.n)= Dz;
end