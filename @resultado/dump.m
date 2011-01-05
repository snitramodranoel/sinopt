% @resultado/dump.m dumps object property values to standard output.
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
function dump(obj)
  fprintf(1,'resultado.s:  %dx%d\n',size(obj.s,1),size(obj.s,2));
  fprintf(1,'resultado.q:  %dx%d\n',size(obj.q,1),size(obj.q,2));
  fprintf(1,'resultado.v:  %dx%d\n',size(obj.v,1),size(obj.v,2));
  fprintf(1,'resultado.y:  %dx%d\n',size(obj.y,1),size(obj.y,2));
  fprintf(1,'resultado.z:  %dx%d\n',size(obj.z,1),size(obj.z,2));
  fprintf(1,'resultado.P:  %dx%d\n',size(obj.P,1),size(obj.P,2));
  fprintf(1,'resultado.Q:  %dx%d\n',size(obj.Q,1),size(obj.Q,2));
  fprintf(1,'resultado.la: %dx%d\n',size(obj.la,1),size(obj.la,2));
  fprintf(1,'resultado.lb: %dx%d\n',size(obj.lb,1),size(obj.lb,2));
  fprintf(1,'resultado.uq: %dx%d\n',size(obj.uq,1),size(obj.uq,2));
end