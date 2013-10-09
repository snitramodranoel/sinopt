% @problema/dump.m dumps object property values.
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
  fprintf(1, 'problema.dv: %s\n', obj.dv);
  fprintf(1, 'problema.km: %d\n', obj.km);
  fprintf(1, 'problema.so: %s\n', obj.so);
  fprintf(1, 'problema.ls: %dx%d\n', size(obj.ls,1), size(obj.ls,2));
  fprintf(1, 'problema.lq: %dx%d\n', size(obj.lq,1), size(obj.lq,2));
  fprintf(1, 'problema.lv: %dx%d\n', size(obj.lv,1), size(obj.lv,2));
  fprintf(1, 'problema.ly: %dx%d\n', size(obj.ly,1), size(obj.ly,2));
  fprintf(1, 'problema.lz: %dx%d\n', size(obj.lz,1), size(obj.lz,2));
  fprintf(1, 'problema.A : %dx%d\n', size(obj.A,1), size(obj.A,2));
  fprintf(1, 'problema.B : %dx%d\n', size(obj.B,1), size(obj.B,2));
  fprintf(1, 'problema.C : %dx%d\n', size(obj.C,1), size(obj.C,2));
  fprintf(1, 'problema.G : %dx%d\n', size(obj.G,1), size(obj.G,2));
  fprintf(1, 'problema.I : %dx%d\n', size(obj.I,1), size(obj.I,2));
  fprintf(1, 'problema.L : %dx%d\n', size(obj.L,1), size(obj.L,2));
  fprintf(1, 'problema.M : %dx%d\n', size(obj.M,1), size(obj.M,2));
  fprintf(1, 'problema.N : %dx%d\n', size(obj.N,1), size(obj.N,2));
  fprintf(1, 'problema.Q : %dx%d\n', size(obj.Q,1), size(obj.Q,2));
  fprintf(1, 'problema.Ql: %dx%d\n', size(obj.Ql,1), size(obj.Ql,2));
  fprintf(1, 'problema.V : %dx%d\n', size(obj.V,1), size(obj.V,2));
  fprintf(1, 'problema.X : %dx%d\n', size(obj.X,1), size(obj.X,2));
  fprintf(1, 'problema.ma: %d\n', obj.ma);
  fprintf(1, 'problema.mb: %d\n', obj.mb);
  fprintf(1, 'problema.mc: %d\n', obj.mc);
  fprintf(1, 'problema.m : %d\n', obj.m);
  fprintf(1, 'problema.na: %d\n', obj.na);
  fprintf(1, 'problema.nq: %d\n', obj.nq);
  fprintf(1, 'problema.nv: %d\n', obj.nv);
  fprintf(1, 'problema.nx: %d\n', obj.nx);
  fprintf(1, 'problema.ny: %d\n', obj.ny);
  fprintf(1, 'problema.nz: %d\n', obj.nz);
  fprintf(1, 'problema.n : %d\n', obj.n);
  fprintf(1, 'problema.us: %dx%d\n', size(obj.us,1), size(obj.us,2));
  fprintf(1, 'problema.uq: %dx%d\n', size(obj.uq,1), size(obj.uq,2));
  fprintf(1, 'problema.uv: %dx%d\n', size(obj.uv,1), size(obj.uv,2));
  fprintf(1, 'problema.uy: %dx%d\n', size(obj.uy,1), size(obj.uy,2));
  fprintf(1, 'problema.uz: %dx%d\n', size(obj.uz,1), size(obj.uz,2));
  fprintf(1, 'problema.b : %dx%d\n', size(obj.b,1), size(obj.b,2));
  fprintf(1, 'problema.d : %dx%d\n', size(obj.d,1), size(obj.d,2));
end