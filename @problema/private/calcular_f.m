% @problema/private/f.m evaluates f(z).
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
function f= calcular_f(obj,w)
  % system data
  ut= get(obj.si,'ut');
  % system dimensions
  ni= get(obj.si,'ni');
  np= get(obj.si,'np');
  nt= get(obj.si,'nt');
  th= get(obj.si,'th');
  % unpack z variables
  z=  desempacotar_z(obj, extrair_z(obj,w));
  % compute complementary thermal power generation costs
  f= 0.0;
  for k= 1:nt
    co= get(ut{k},'co');
    for j= 1:ni
      for l= 1:np
        f= f + calcular(co, z{l}(k,j), th{l}(j) * 1e-3);
      end
    end
  end
end