% @problema/construir.m builds optimization problem.
%
% Copyright (c) 2010 Leonardo Martins, Universidade Estadual de Campinas
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
function obj= construir(obj)
  % swap plants between ROR and regulation reservoir lists
  % obj= swap(obj);
  % system data
  uh= get(obj.si,'uh');
  % all plants should be regarded as having regulating reservoirs
  obj.si= set(obj.si,'nr', get(obj.si,'nu'));
  obj.si= set(obj.si,'nf', 0);
  obj.si= set(obj.si,'uf', []);
  obj.si= set(obj.si,'ur', (1:get(obj.si,'nu'))');
  for i= 1:get(obj.si,'nu')
    uh{i}= set(uh{i},'ie',0);
  end
  obj.si= set(obj.si,'uh',uh);
  % system dimensions
  nc= get(obj.si,'nc');
  ni= get(obj.si,'ni');
  nl= get(obj.si,'nl');
  np= get(obj.si,'np');
  nr= get(obj.si,'nr');
  ns= get(obj.si,'ns');
  nt= get(obj.si,'nt');
  nu= get(obj.si,'nu');
  % variable-space dimensions
  obj.na= nr*(ni-1);
  obj.nq= nu*ni*np;
  obj.nv= nu*ni;
  obj.nx= obj.na + obj.nq + obj.nv;
  obj.ny= nl*np*ni;
  obj.nz= nt*np*ni;
  obj.n = obj.nx + obj.ny + obj.nz;
  % constraint-space dimensions
  obj.ma= nu*ni;
  obj.mb= ns*np*ni;
  obj.mc= nc*np*ni;
  obj.m = obj.ma + obj.mb + obj.mc;
  % box constraints
  obj= construir_lb(obj);
  obj= construir_ub(obj);
  % hydro constraints
  obj= construir_bb(obj);
  obj= construir_A(obj);
  % power constraints
  obj= construir_d(obj);
  obj= construir_B(obj);
  obj= construir_C(obj);
  % check constraints for sanity
  obj= verificar(obj);
  % compute matrix structures
  obj= construir_J(obj);
  obj= construir_H(obj);
end