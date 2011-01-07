% @problema/private/calcular_P.m evaluates P(.) function.
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
function P= calcular_P(obj,w)
  % system data
  uh= get(obj.si,'uh');
  vf= get(obj.si,'vf');
  % system dimensions
  ni= get(obj.si,'ni');
  np= get(obj.si,'np');
  ns= get(obj.si,'ns');
  nu= get(obj.si,'nu');
  % unpack x variables
  s=  desempacotar_s(obj, extrair_s(obj,w));
  q=  desempacotar_q(obj, extrair_q(obj,w));
  v=  desempacotar_v(obj, extrair_v(obj,w));
  % memory allocation
  P = zeros(obj.mb,1);
  Pl= cell(np,1);
  % compute P()
  n= ns*ni;
  for l= 1:np
    Pl{l}= zeros(ns,ni);
    % compute P(j), j=1,2,...
    for j= 1:ni
      % check for final stage
      if j < ni
        a= s(:,j);
      else
        a= vf;
      end
      % compute hydro power generation
      for i= 1:nu
        k= get(uh{i},'ss');
        Pl{l}(k,j)= Pl{l}(k,j) + p(uh{i}, a(i), q{l}(i,j), v(i,j));
      end
    end
    % pack
    P(n*(l-1)+1:n*l)= reshape(Pl{l}, n, 1);
  end
end