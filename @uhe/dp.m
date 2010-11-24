% @uhe/dp.m computes power generation first-order partial derivatives.
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
function [ds,dq,dv]= dp(obj,s,q,v)
  % compute net water head
  h = calcular(obj.yc,s) - calcular(obj.yf{1,2},q+v);
  switch obj.pc{1}
    case 1
      h= h * (1-obj.pc{2});
    case 2
      h= h - obj.pc{2};
    otherwise
      error('sinopt:uhe:p:invalidData', ...
          'Penstock loss of type %d is invalid', obj.pc{1});
  end
  % compute partial derivatives
  %  in terms of water head
  dhs= derivar(obj.yc,1,s);
  dhq= derivar(obj.yf{1,2},1,q+v);
  dhv= derivar(obj.yf{1,2},1,q+v);
  %  in terms of penstock loss
  switch obj.pc{1}
    case 1
      ds= obj.pc{2}*dhs;
      dq= obj.pc{2}*dhq;
      dv= obj.pc{2}*dhv;
    otherwise
      ds= 0.0;
      dq= 0.0;
      dv= 0.0;   
  end
  %  compute dp/ds
  ds= obj.pe*q*(dhs - ds);
  %  compute dp/dq
  dq= obj.pe*(h-(dhq - dq)*q);
  %  compute dp/dv
  dv= -obj.pe*q*(dhv - dv);
end