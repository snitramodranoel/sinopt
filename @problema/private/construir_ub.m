% @problema/private/construir_ub.m builds upper bounds vector.
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
function obj = construir_ub(obj)
  % maximum water spill factor
  beta= 10;
  % system data
  af= get(obj.si,'af');
  im= get(obj.si,'im');
  ni= get(obj.si,'ni');
  np= get(obj.si,'np');
  nq= get(obj.si,'nq');
  nt= get(obj.si,'nt');
  nu= get(obj.si,'nu');
  uh= get(obj.si,'uh');
  ut= get(obj.si,'ut');
  vm= get(obj.si,'vm');
  %% upper bounds on reservoir storage
  obj.us= empacotar_s(obj, vm(:,1:ni-1));
  %% upper bounds on water release
  %  memory allocation
  uq= cell(np,1);
  uv= zeros(nu,ni);
  for l= 1:np
    uq{l}= zeros(nu,ni);
  end
  for k= 1:nu
    % maximum incremental inflow
    maf= max(af(k,:));
    % upper limit
    for j= 1:ni
      % compute maximum water discharge 
      % as a function of the number of available generators
      qef= qm(uh{k}, nq(k,j));
      for l= 1:np
        uq{l}(k,j)= qef;
      end
      % compute maximum water spill
      uv(k,j)= max([maf; beta*qef]);
    end
  end
  %  store data
  obj.uq= empacotar_q(obj,uq);
  obj.uv= empacotar_v(obj,uv);
  %  clear temporary buffers
  clear dm;
  clear uq;
  clear uv;
  clear qef;
  %% upper bounds on power transmission
  obj.uy= empacotar_y(obj,im);
  %% upper bounds thermal power generation
  uz= cell(np, 1);
  for l= 1:np
    uz{l}= zeros(nt, ni); 
  end
  %  fill in elements
  for t= 1:nt
    gm= get(ut{t},'gm');
    for l= 1:np
      for j= 1:ni
        uz{l}(t,j)= gm(l,j);
      end
    end
  end
  % pack data
  obj.uz= empacotar_z(obj,uz);
end