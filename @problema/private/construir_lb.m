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
  % system data
  dn= get(obj.si,'dn');
  in= get(obj.si,'in');
  uh= get(obj.si,'uh');
  ur= get(obj.si,'ur');
  ut= get(obj.si,'ut');
  vn= get(obj.si,'vn');
  % system dimensions
  ni= get(obj.si,'ni');
  np= get(obj.si,'np');
  nq= get(obj.si,'nq');
  nr= get(obj.si,'nr');
  nt= get(obj.si,'nt');
  nu= get(obj.si,'nu');  
  %
  % lower bounds on reservoir storage
  ls= zeros(nr,ni-1);
  for i= 1:nr
    ls(i,:)= vn(ur(i), 1:ni-1);
  end
  %  store data
  obj.ls= empacotar_s(obj,ls);
  %  clear temporary buffer
  clear ls;
  %
  % lower bounds on water release
  % water spill
  lv= zeros(nu,ni);
  % water discharge
  warning('SINopt:problema:xBounds','Lower bounds for water discharge relaxed');
  lq= cell(np,1);
  for l= 1:np
    lq{l}= zeros(nu,ni);
  end
  % pack data
  obj.lq= empacotar_q(obj,lq);
  obj.lv= empacotar_v(obj,lv);
  % clear temporary buffer
  clear lq;
  clear lv;
  %
  % lower bounds on transmission
  obj.ly= empacotar_y(obj,in);
  %
  % lower bounds on thermal power generation
  % three-dimensional memory allocation
  lz= cell(np, 1);
  for l= 1:np
    lz{l}= zeros(nt, ni); 
  end
  % fill in elements
  for t= 1:nt
    gn= get(ut{t},'gn');
    for l= 1:np
      for j= 1:ni
        lz{l}(t,j)= gn(l,j);
      end
    end
  end
  % pack data
  obj.lz= empacotar_z(obj,lz);
end