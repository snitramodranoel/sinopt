% @profiler/dump.m dumps object property values.
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
  fprintf(1,'profiler.ad: %dx%d\n', size(obj.ad,1), size(obj.ad,2));
  fprintf(1,'profiler.ap: %dx%d\n', size(obj.ap,1), size(obj.ap,2));
  fprintf(1,'profiler.cg: %dx%d\n', size(obj.cg,1), size(obj.cg,2));
  fprintf(1,'profiler.cs: %dx%d\n', size(obj.cs,1), size(obj.cs,2));
  fprintf(1,'profiler.cw: %dx%d\n', size(obj.cw,1), size(obj.cw,2));
  fprintf(1,'profiler.cy: %dx%d\n', size(obj.cy,1), size(obj.cy,2));
  fprintf(1,'profiler.cz: %dx%d\n', size(obj.cz,1), size(obj.cz,2));
  fprintf(1,'profiler.f : %dx%d\n', size(obj.f,1), size(obj.f,2));
  fprintf(1,'profiler.ga: %dx%d\n', size(obj.ga,1), size(obj.ga,2));
  fprintf(1,'profiler.k : %d\n', obj.k);
  fprintf(1,'profiler.mu: %dx%d\n', size(obj.mu,1), size(obj.mu,2));
  fprintf(1,'profiler.ry: %dx%d\n', size(obj.ry,1), size(obj.ry,2));
  fprintf(1,'profiler.si: %dx%d\n', size(obj.si,1), size(obj.si,2));
  fprintf(1,'profiler.t : %d\n', obj.tt);
end