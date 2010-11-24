% @uhe/Hp.m computes power generation partial second-order derivatives.
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
function [dss,dsq,dqq,dqv,dvv]= Hp(obj,s,q,v)
  % compute second-order partial derivatives
  %  in terms of water head
  dhs=  derivar(obj.yc,1,s);
  d2hs= derivar(obj.yc,2,s);
  dhq=  derivar(obj.yf{1,2},1,q+v);
  d2hq= derivar(obj.yf{1,2},2,q+v);
  dhv=  derivar(obj.yf{1,2},1,q+v);
  d2hv= derivar(obj.yf{1,2},2,q+v);
  %  in terms of penstock loss
  switch obj.pc{1}
    case 1
      dps=  obj.pc{2}*dhs;
      d2ps= obj.pc{2}*d2hs;
      dpq=  obj.pc{2}*dhq;
      d2pq= obj.pc{2}*d2hq;
      dpv=  obj.pc{2}*dhv;
      d2pv= obj.pc{2}*d2hv;
    otherwise
      dps=  0.0;
      d2ps= 0.0;
      dpq=  0.0;
      d2pq= 0.0;
      dpv=  0.0;
      d2pv= 0.0;
  end
  %  combined derivatives
  dss= obj.pe*q*(d2hs - d2ps);
  dsq= obj.pe*(dhs - dps);
  dqq= -obj.pe*(2*(dhq - dpq) + (d2hq - d2pq)*q);
  dqv= -obj.pe*(dhv - dpv + q*(d2hv - d2pv));
  dvv= -obj.pe*q*(d2hv - d2pv);
end