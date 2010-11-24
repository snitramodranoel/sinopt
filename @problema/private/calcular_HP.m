% @problema/private/calcular_HP.m computes Hessian of P(x).
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
function HP= calcular_HP(obj,u,lambda)
  % system dimensions
  ni= get(obj.si,'ni');
  nu= get(obj.si,'nu');
  % list of hydro plants
  uh= get(obj.si,'uh');
  % unpack x variables
  s= obter_ms(obj,u);
  q= obter_mq(obj,u);
  v= obter_mv(obj,u);
  % allocate room for partial derivatives
  dss= zeros(nu,ni);
  dsq= zeros(nu,ni);
  dqq= zeros(nu,ni);
  dqv= zeros(nu,ni);
  dvv= zeros(nu,ni);
  % compute partial derivatives
  lambda_b= obter_mlambda_b(obj,lambda);
  for i= 1:nu
    k= get(uh{i},'ss');
    for j= 1:ni
      % compute partial derivatives...
      [dss(i,j), dsq(i,j), dqq(i,j), dqv(i,j), dvv(i,j)] = ...
          Hp(uh{i}, s(i,j), q(i,j), v(i,j));
      % ... and multiply them by their corresponding dual variables
      dss(i,j)= dss(i,j) * lambda_b(k,j);
      dsq(i,j)= dsq(i,j) * lambda_b(k,j);
      dqq(i,j)= dqq(i,j) * lambda_b(k,j);
      dqv(i,j)= dqv(i,j) * lambda_b(k,j);
      dvv(i,j)= dvv(i,j) * lambda_b(k,j);
    end
  end
  % allocate room for Hessian matrix blocks
  SS= spalloc(nu*ni,nu*ni,nu*ni);
  SQ= spalloc(nu*ni,nu*ni,nu*ni);
  QQ= spalloc(nu*ni,nu*ni,nu*ni);
  QV= spalloc(nu*ni,nu*ni,nu*ni);
  VV= spalloc(nu*ni,nu*ni,nu*ni);
  for j= 1:ni
    for i= 1:nu
      p= i+(j-1)*nu;
      SS(p,p)= dss(i,j);
      SQ(p,p)= dsq(i,j);
      QQ(p,p)= dqq(i,j);
      QV(p,p)= dqv(i,j);
      VV(p,p)= dvv(i,j);
    end
  end
  % fill Hessian elements
  HP= spalloc(obj.nx,obj.nx,7*nu*ni);
  HP(1:nu*ni, 1:nu*ni)= SS;
  HP(nu*ni+1:2*nu*ni, nu*ni+1:2*nu*ni)= QQ;
  HP(2*nu*ni+1:3*nu*ni, 2*nu*ni+1:3*nu*ni)= VV;
  HP(1:nu*ni, nu*ni+1:2*nu*ni)= SQ;
  HP(nu*ni+1:2*nu*ni, 1:nu*ni)= SQ;
  HP(nu*ni+1:2*nu*ni, 2*nu*ni+1:3*nu*ni)= QV;
  HP(2*nu*ni+1:3*nu*ni, nu*ni+1:2*nu*ni)= QV;
end