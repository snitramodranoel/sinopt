% @problema/private/construir_lb.m builds lower bounds vector.
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
function obj = construir_lb(obj)
  % minimum reservoir storage factor
  beta= 0.999;
  % system data
  dn= get(obj.si,'dn');
  in= get(obj.si,'in');
  ni= get(obj.si,'ni');
  nl= get(obj.si,'nl');
  nt= get(obj.si,'nt');
  nu= get(obj.si,'nu');
  ut= get(obj.si,'ut');
  vf= get(obj.si,'vf');
  vm= get(obj.si,'vm');
  vn= get(obj.si,'vn');
  % lower bounds on reservoir storage
  ls= vn;
  for i= 1:nu
    for j= 1:ni-1
      if ~(vm(i,j) - ls(i,j) > 0)
        ls(i,j)= beta*vm(i,j);
      end
    end
  end
  % final storage requirements
  ls(:,ni)= vf;
  % lower bounds on water discharge
  lq= dn;
  % lower bounds on water spill
  lv= zeros(nu*ni,1);
  % lower bounds on transmission
  ly= in;
  % lower bounds on thermal power generation
  lz= zeros(nt,ni);
  for t= 1:nt
    lz(t,:)= get(ut{t},'gn');
  end
  % data packing
  ls= reshape(ls,nu*ni,1);
  lq= reshape(lq,nu*ni,1);
  ly= reshape(ly,nl*ni,1);
  lz= reshape(lz,nt*ni,1);
  % data update
  obj.ls= ls;
  obj.lq= lq;
  obj.lv= lv;
  obj.ly= ly;
  obj.lz= lz;
end
