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
  % maximum spill factor
  beta= 10;
  % system data
  af= get(obj.si,'af');
  im= get(obj.si,'im');
  ni= get(obj.si,'ni');
  nl= get(obj.si,'nl');
  nq= get(obj.si,'nq');
  nt= get(obj.si,'nt');
  nu= get(obj.si,'nu');
  uh= get(obj.si,'uh');
  ut= get(obj.si,'ut');
  vm= get(obj.si,'vm');
  % unpack lower bounds
  ls= reshape(obj.ls,nu,ni);
  lq= reshape(obj.lq,nu,ni);
  lv= reshape(obj.lv,nu,ni);
  % allocate storage
  uq= zeros(nu,ni);
  uv= zeros(nu,ni);
  us= vm;
  % check for consistency in storage bounds
  for k= 1:nu
    ls(k,ni)= min(us(k,ni), ls(k,ni));
    % TODO: Print warning message
  end
  % release bounds
  for k= 1:nu
    % release upper bounds
    dm= get(uh{k},'dm');
    for j= 1:ni
      % compute maximum discharge
      %  (function of the number of available generators)
      qef= qm(uh{k},nq(k,j));
      % set maximum discharge
      uq(k,j)= qef;
      % compute maximum spill
      uv(k,j)= dm - qef;
      % check for consistency with lower bounds
      if uq(k,j) < lq(k,j)
        lv(k,j)= lv(k,j) + (lq(k,j) - uq(k,j));
        lq(k,j)= 0;
        % TODO: Print warning message
      end
    end
  end
  % upper bounds on water spill
  for k= 1:nu
    for j= 1:ni
      uv(k,j)= max([max(af(k,:)); beta*uq(k,j)]);
    end
  end
  % upper bounds on power transmission
  uy= im;
  % upper bounds thermal power generation
  uz= zeros(nt,ni);
  for t= 1:nt
    uz(t,:)= get(ut{t},'gm');
  end
  % data packing
  lq= reshape(lq,nu*ni,1);
  lv= reshape(lv,nu*ni,1);
  us= reshape(us,nu*ni,1);
  uq= reshape(uq,nu*ni,1);
  uv= reshape(uv,nu*ni,1);
  uy= reshape(uy,nl*ni,1);
  uz= reshape(uz,nt*ni,1);
  % data update
  obj.lq= lq;
  obj.lv= lv;
  obj.us= us;
  obj.uq= uq;
  obj.uv= uv;
  obj.uy= uy;
  obj.uz= uz;
end