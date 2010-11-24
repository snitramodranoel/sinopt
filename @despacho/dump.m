% @despacho/dump.m dumps object property values to standard output.
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
  fprintf(1,'despacho.ms: %dx%d\n',size(obj.ms,1),size(obj.ms,2));
  fprintf(1,'despacho.mq: %dx%d\n',size(obj.mq,1),size(obj.mq,2));
  fprintf(1,'despacho.mv: %dx%d\n',size(obj.mv,1),size(obj.mv,2));
  fprintf(1,'despacho.my: %dx%d\n',size(obj.my,1),size(obj.my,2));
  fprintf(1,'despacho.mz: %dx%d\n',size(obj.mz,1),size(obj.mz,2));
  fprintf(1,'despacho.mp: %dx%d\n',size(obj.mp,1),size(obj.mp,2));
  fprintf(1,'despacho.ma: %dx%d\n',size(obj.ma,1),size(obj.ma,2));
end
