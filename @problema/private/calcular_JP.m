% @problema/private/calcular_JP.m computes Jacobian of P(x).
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
function JP= calcular_JP(obj,w)
  % system data
  uh= get(obj.si,'uh');
  % system dimensions
  ni= get(obj.si,'ni');
  np= get(obj.si,'np');
  ns= get(obj.si,'ns');
  nu= get(obj.si,'nu');
  n = nu*ni;
  % unpack x variables
  s= desempacotar_s(obj, extrair_s(obj,w));
  q= desempacotar_q(obj, extrair_q(obj,w));
  v= desempacotar_v(obj, extrair_v(obj,w));
  % allocate memory for row index vector
  li= zeros(n,1);
  % allocate memory for column index vectors
  cos= zeros(n,1);
  coq= cell(np,1);
  cov= zeros(n,1);
  for l= 1:np
    coq{l}= zeros(n,1);
  end
  % allocate memory for partial derivatives
  ds= zeros(n,1);
  dq= cell(np,1);
  dv= zeros(n,1);
  for l= 1:np
    dq{l}= zeros(n,1);
  end
  % compute JP(s), JP(v), and JP(q)(l), l = 1,2,...
  k= 0;
  for j= 1:ni
    for i= 1:nu
      k= k+1;
      % compute row and column indexes
      li(k)= get(uh{i},'ss') + (ns*(j-1));
      cos(k)= i + (nu*(j-1));
      cov(k)= n*(np+1) + cos(k);
      % compute partial derivatives for s and v
      ds(k)= dpds(uh{i}, s(i,j), q{l}(i,j));
      dv(k)= dpdv(uh{i}, v(i,j), q{1}(i,j));
      % compute partial derivatives for q(l), l = 1,2,...
      for l= 1:np
        dq{l}(k)= dqp(uh{i}, s(i,j), q{l}(i,j), v(i,j));
        % compute column index for dp/dq partial derivatives
        coq{l}(k)= n + n*(l-1) + cos(k);
      end
    end
  end
  % memory allocation
  co= zeros(obj.nx, 1);
  dp= zeros(obj.nx, 1);
  % concatenate column index vectors
  co(1:n)= cos;
  co(n*(np+1)+1:obj.nx)= cov;
  for l= 1:np
    co(n*(l-1)+1:n*l)= coq{l};
  end
  % concatenate partial derivative vectors
  dp(1:n)= ds;
  dp(n*(np+1)+1:obj.nx)= dv;
  for l= 1:np
    dp(n*(l-1)+1:n*l)= dq{l};
  end
  % build Jacobian
  JP= sparse(li, co, dp, obj.mb, n, n);
end