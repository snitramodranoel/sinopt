% @problema/private/inverter_Dx.m computes the inverse of Dx.
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
function [Dxi, pD]= inverter_Dx(obj,Dx)
  % system dimensions
  ni= get(obj.si,'ni');
  nu= get(obj.si,'nu');
  % algorithm variables
  I=       speye(obj.nx);             % sparse identity matrix
  lambda=  full(abs(mean(diag(Dx)))); % diagonal mean value
  prtrb=   false;                     % perturbation switch control
  pD=      0;                         % perturbation counter
  % fast inverse computation
  Dxi= spalloc(obj.nx,obj.nx,7*nu*ni);
  while true
    for i= 1:obj.nx/3
      % relative coordinates
      j= obj.nx/3 + i;
      k= 2*obj.nx/3 + i;
      % denominador
      beta= Dx(i,i) * (Dx(j,k) * Dx(k,j) - Dx(j,j) * Dx(k,k)) ...
          + Dx(k,k) * Dx(i,j) * Dx(j,i);
      % check for singularity
      if (abs(0 - beta) < sqrt(eps))
        prtrb= true;
        break;
      end
      % compute inverse elements
      Dxi(i,i)=  (Dx(j,k)*Dx(k,j) - Dx(j,j)*Dx(k,k)) / beta;
      Dxi(i,j)=  (Dx(i,j)*Dx(k,k))                   / beta;
      Dxi(j,i)=  (Dx(j,i)*Dx(k,k))                   / beta;
      Dxi(j,j)= -(Dx(i,i)*Dx(k,k))                   / beta;
      Dxi(j,k)=  (Dx(i,i)*Dx(j,k))                   / beta;
      Dxi(k,j)=  (Dx(i,i)*Dx(k,j))                   / beta;
      Dxi(i,k)= -(Dx(i,j)*Dx(j,k))                   / beta;
      Dxi(k,i)= -(Dx(j,i)*Dx(k,j))                   / beta;
      Dxi(k,k)=  (Dx(i,j)*Dx(j,i) - Dx(i,i)*Dx(j,j)) / beta;
    end
    % check for the need of perturbation
    if (prtrb)
      Dx=     Dx + lambda*I;
      lambda= 1.01*lambda;
      pD=     pD + 1;
      prtrb=  false;
    else
      break;
    end
  end
end