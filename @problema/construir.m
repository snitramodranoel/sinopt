% @problema/construir.m builds optimization problem.
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
function obj= construir(obj)
  % system dimensions
  nc= get(obj.si,'nc');
  ni= get(obj.si,'ni');
  nl= get(obj.si,'nl');
  ns= get(obj.si,'ns');
  nt= get(obj.si,'nt');
  nu= get(obj.si,'nu');
  % variable-space dimensions
  obj.nx= 3*nu*ni;
  obj.ny= nl*ni;
  obj.nz= nt*ni;
  obj.n = obj.nx + obj.ny + obj.nz;
  % constraint-space dimensions
  obj.ma= nu*ni;
  obj.mb= ns*ni;
  obj.mc= nc*ni;
  obj.m = obj.ma + obj.mb + obj.mc;
  % box constraints
  obj= construir_lb(obj);
  obj= construir_ub(obj);
  % hydro constraints
  obj= construir_bring(obj);
  obj= construir_A(obj);
  % power constraints
  obj= construir_d(obj);
  obj= construir_B(obj);
  obj= construir_C(obj);
  % g(u) function Jacobian matrix
  obj.Jg= spalloc(obj.m, obj.n, ni*(11*nu + nl*(2 + nc) + ns) - 2*nu);
  obj.Jg(1:obj.ma, 1:obj.nx)= obj.A;
  obj.Jg(obj.ma+obj.mc+1:obj.m, obj.nx+1:obj.nx+obj.ny)= obj.B;
  obj.Jg(obj.ma+1:obj.ma+obj.mc, obj.nx+1:obj.nx+obj.ny)= obj.C;
end