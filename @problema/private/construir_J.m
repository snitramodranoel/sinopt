% @problema/private/construir_J.m builds structure of Jacobian of g(w).
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
function obj= construir_J(obj)
  % compute number of constant Jacobian elements
  nze= nnz(obj.A) + nnz(obj.B) + nnz(obj.C) + obj.nz;
  % compute constant elements
  J= spalloc(obj.m, obj.n, nze);
  J(1:obj.ma, 1:obj.nx)= obj.A;
  J(obj.ma+obj.mc+1:obj.m, obj.nx+1:obj.nx+obj.ny)= obj.B;
  J(obj.ma+1:obj.ma+obj.mc, obj.nx+1:obj.nx+obj.ny)= obj.C;
  J(obj.ma+obj.mc+1:obj.m, obj.nx+obj.ny+1:obj.n)= -obj.G;
  %
  [rows,cols,vlus]= find(J);
  % memory allocation
  obj.J= zeros(length(rows),3);
  obj.J(:,1)= rows;
  obj.J(:,2)= cols;
  obj.J(:,3)= vlus;
  %
  obj= construir_Jp(obj);
end