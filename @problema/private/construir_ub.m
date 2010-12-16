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
  nl= get(obj.si,'nl');
  np= get(obj.si,'np');
  nq= get(obj.si,'nq');
  nt= get(obj.si,'nt');
  nu= get(obj.si,'nu');
  uh= get(obj.si,'uh');
  ut= get(obj.si,'ut');
  vm= get(obj.si,'vm');
  %% upper bounds on reservoir storage
  obj.us= reshape(vm, nu*ni, 1);
  %% upper bounds on water release
  %  memory allocation
  uq= cell(np, 1);
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
  %  memory allocation for one-dimensional data packing
  obj.uq= zeros(nu*np*ni, 1);
  obj.uv= reshape(uv, nu*ni, 1);
  %  store data
  n= nu*ni;
  for l= 1:np
    obj.uq(n*(l-1)+1 : n*l)= reshape(uq{l}, n, 1);
  end
  %  clear temporary buffers
  clear n;
  clear dm;
  clear uq;
  clear uv;
  clear qef;
  %% upper bounds on power transmission
  %  memory allocation for one-dimensional data packing
  obj.uy= zeros(obj.ny, 1);
  %  fill in elements
  n= nl*ni;
  for l= 1:np
    obj.uy(n*(l-1)+1 : n*l)= reshape(im{l}, n, 1);
  end
  % clear temporary buffer
  clear n;
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
  % memory allocation for one-dimensional data packing
  obj.uz= zeros(obj.nz, 1);
  % store data
  n= nt*ni;
  for l= 1:np
    obj.uz(n*(l-1)+1 : n*l)= reshape(uz{l}, n, 1);
  end
  % clear temporary buffer
  clear n;
  clear gm;
  clear uz;
  %% sanity check overlapping bounds
  if     ~isempty(find(obj.us - obj.ls <= 0, 1))
    error('sinopt:problema:construir_ub:invalidInput','Interior set is empty');
  elseif ~isempty(find(obj.uq - obj.lq <= 0, 1))
    error('sinopt:problema:construir_ub:invalidInput','Interior set is empty');
  elseif ~isempty(find(obj.uv - obj.lv <= 0, 1))
    error('sinopt:problema:construir_ub:invalidInput','Interior set is empty');
  elseif ~isempty(find(obj.uy - obj.ly <= 0, 1))
    error('sinopt:problema:construir_ub:invalidInput','Interior set is empty');
  elseif ~isempty(find(obj.uz - obj.lz <= 0, 1))
    error('sinopt:problema:construir_ub:invalidInput','Interior set is empty');
  end
end