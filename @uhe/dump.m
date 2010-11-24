% @uhe/dump.m dumps object property values.
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
  fprintf(1,'uhe.am: %dx%d\n',size(obj.am,1),size(obj.am,2));
  fprintf(1,'uhe.as: %dx%d\n',size(obj.as,1),size(obj.as,2));
  fprintf(1,'uhe.cd: %d\n',obj.cd);
  fprintf(1,'uhe.ce: %dx%d\n',size(obj.ce,1),size(obj.ce,2));
  fprintf(1,'uhe.cf: %f\n',obj.cf);
  fprintf(1,'uhe.cg: %dx%d\n',size(obj.cg,1),size(obj.cg,2));
  fprintf(1,'uhe.cj: %d\n',obj.cj);
  fprintf(1,'uhe.dm: %f\n',obj.dm);
  fprintf(1,'uhe.dn: %f\n',obj.dn);
  fprintf(1,'uhe.id: %f\n',obj.id);
  fprintf(1,'uhe.ie: %d\n',obj.ie);
  fprintf(1,'uhe.ij: %d\n',obj.ij);
  fprintf(1,'uhe.ms: %d\n',obj.ms);
  fprintf(1,'uhe.ng: %d\n',obj.ng);
  fprintf(1,'uhe.nm: %s\n',obj.nm);
  fprintf(1,'uhe.nt: %s\n',obj.nt);
  fprintf(1,'uhe.pc: (%d, %f)\n',obj.pc{1},obj.pc{2});
  fprintf(1,'uhe.pe: %f\n',obj.pe);
  fprintf(1,'uhe.qb: %f\n',obj.qb);
  fprintf(1,'uhe.ss: %d\n',obj.ss);
  fprintf(1,'uhe.tm: %d\n',obj.tm);
  fprintf(1,'uhe.ve: %dx%d\n',size(obj.ve,1),size(obj.ve,2));
  fprintf(1,'uhe.vm: %f\n',obj.vm);
  fprintf(1,'uhe.vn: %f\n',obj.vn);
  fprintf(1,'uhe.yc: is a polynomial\n');
  fprintf(1,'uhe.ya: is a polynomial\n');
  fprintf(1,'uhe.yf: %dx%d\n',size(obj.yf,1),size(obj.yf,2));
end
