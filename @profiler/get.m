% @profiler/get.m returns object property values.
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
function valor= get(obj, propriedade)
  switch propriedade
    case 'ad'
      valor= obj.ad;
    case 'ap'
      valor= obj.ap;
    case 'cg'
      valor= obj.cg;
    case 'cs'
      valor= obj.cs;
    case 'cw'
      valor= obj.cw;
    case 'cy'
      valor= obj.cy;
    case 'cz'
      valor= obj.cz;
    case 'f'
      valor= obj.f;
    case 'ga'
      valor= obj.ga;
    case 'k'
      valor= obj.k;
    case 'mu'
      valor= obj.mu;
    case 'ry'
      valor= obj.ry;
    case 'si'
      valor= obj.si;
    case 't'
      valor= obj.t;
    otherwise
      error('SINopt:profiler:invalidProperty', ...
          '%s is not a valid property', propriedade);
  end
end