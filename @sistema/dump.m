% @sistema/dump.m dumps object property values.
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
  fprintf(1,'sistema.af: %dx%d\n', size(obj.af,1), size(obj.af,2));
  fprintf(1,'sistema.ai: %d\n', obj.ai);
  fprintf(1,'sistema.dc: %dx%d\n', size(obj.dc,1), size(obj.dc,2));
  fprintf(1,'sistema.di: %d\n', obj.di);
  fprintf(1,'sistema.dn: %dx%d\n', size(obj.dn,1), size(obj.dn,2));
  fprintf(1,'sistema.ev: %dx%d\n', size(obj.ev,1), size(obj.ev,2));
  fprintf(1,'sistema.gp: %dx%d\n', size(obj.gp,1), size(obj.gp,2));
  fprintf(1,'sistema.im: %dx%d\n', size(obj.im,1), size(obj.im,2));
  fprintf(1,'sistema.in: %dx%d\n', size(obj.in,1), size(obj.in,2));
  fprintf(1,'sistema.li: %dx%d\n', size(obj.li,1), size(obj.li,2));
  fprintf(1,'sistema.mi: %d\n', obj.mi);
  fprintf(1,'sistema.nc: %d\n', obj.nc);
  fprintf(1,'sistema.nf: %d\n', obj.nf);
  fprintf(1,'sistema.ni: %d\n', obj.ni);
  fprintf(1,'sistema.nj: %d\n', obj.nj);
  fprintf(1,'sistema.nl: %d\n', obj.nl);
  fprintf(1,'sistema.np: %dx%d\n', size(obj.np,1), size(obj.np,2));
  fprintf(1,'sistema.nq: %dx%d\n', size(obj.nq,1), size(obj.nq,2));
  fprintf(1,'sistema.nr: %d\n', obj.nr);
  fprintf(1,'sistema.ns: %d\n', obj.ns);
  fprintf(1,'sistema.nt: %d\n', obj.nt);
  fprintf(1,'sistema.nu: %d\n', obj.nu);
  fprintf(1,'sistema.rt: %dx%d\n', size(obj.rt,1), size(obj.rt,2));
  fprintf(1,'sistema.th: %dx%d\n', size(obj.th,1), size(obj.th,2));
  fprintf(1,'sistema.ti: %dx%d\n', size(obj.ti,1), size(obj.ti,2));
  fprintf(1,'sistema.tm: %dx%d\n', size(obj.tm,1), size(obj.tm,2));
  fprintf(1,'sistema.tn: %dx%d\n', size(obj.tn,1), size(obj.tn,2));
  fprintf(1,'sistema.tp: %dx%d\n', size(obj.tp,1), size(obj.tp,2));
  fprintf(1,'sistema.uc: %dx%d\n', size(obj.uc,1), size(obj.uc,2));
  fprintf(1,'sistema.uh: %dx%d\n', size(obj.uh,1), size(obj.uh,2));
  fprintf(1,'sistema.uf: %dx%d\n', size(obj.uf,1), size(obj.uf,2));
  fprintf(1,'sistema.ur: %dx%d\n', size(obj.ur,1), size(obj.ur,2));
  fprintf(1,'sistema.ut: %dx%d\n', size(obj.ut,1), size(obj.ut,2));
  fprintf(1,'sistema.vf: %dx%d\n', size(obj.vf,1), size(obj.vf,2));
  fprintf(1,'sistema.vi: %dx%d\n', size(obj.vi,1), size(obj.vi,2));
  fprintf(1,'sistema.vm: %dx%d\n', size(obj.vm,1), size(obj.vm,2));
  fprintf(1,'sistema.vn: %dx%d\n', size(obj.vn,1), size(obj.vn,2));
end
