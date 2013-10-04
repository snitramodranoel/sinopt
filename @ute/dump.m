% @ute/dump.m dumps object property values.
%
% Copyright (c) 2013 Leonardo Martins, Universidade Estadual de Campinas
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
  fprintf(1, 'ute.bc: %dx%d\n', size(obj.bc,1), size(obj.bc,2));
  fprintf(1, 'ute.cd: %d\n', obj.cd);
  fprintf(1, 'ute.co: is a polynomial\n');
  fprintf(1, 'ute.df: %dx%d\n', size(obj.df,1), size(obj.df,2));
  fprintf(1, 'ute.eo: %d\n', obj.eo);
  fprintf(1, 'ute.fc: %dx%d\n', size(obj.fc,1), size(obj.fc,2));
  fprintf(1, 'ute.gn: %dx%d\n', size(obj.gn,1), size(obj.gn,2));
  fprintf(1, 'ute.id: %dx%d\n', size(obj.id,1), size(obj.id,2));
  fprintf(1, 'ute.nm: %s\n', obj.nm);
  fprintf(1, 'ute.pe: %dx%d\n', size(obj.pe,1), size(obj.pe,2));
  fprintf(1, 'ute.ss: %d\n', obj.ss);
end
