% @problema/swap.m swaps plants between ROR and regulating reservoir lists.
%
% Copyright (c) 2011 Leonardo Martins, Universidade Estadual de Campinas
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
function obj= swap(obj)
  % system data
  uh= get(obj.si,'uh');
  uf= get(obj.si,'uf');
  ur= get(obj.si,'ur');
  vm= get(obj.si,'vm');
  vn= get(obj.si,'vn');
  % system dimensions
  nf= get(obj.si,'nf');
  nr= get(obj.si,'nr');
  %
  % search for swappable plants 
  % ROR plants with filling reservoir over the planning horizon
  isf= []; % list of indexes to be swapped
  for i= 1:nf
    if min(vn(uf(i),:)) ~= max(vn(uf(i),:))
      isf= [isf; i]; %#ok<AGROW>
      uh{uf(i)}= set(uh{uf(i)}, 'ie', 0);
    end
  end
  % reservoir plants without storage capacity over the planning horizon
  isr= []; % list of indexes to be swapped
  for i= 1:nr
    if max(vm(ur(i),:)) == 0
      isr= [isr; i]; %#ok<AGROW>
      uh{ur(i)}= set(uh{ur(i)}, 'ie', 1);
    end
  end
  %
  % swap 'em
  % first, compute plant indexes
  sf= uf(isf);
  sr= ur(isr);
  % secondly, remove from original list
  uf(isf)= [];
  ur(isr)= [];
  % then, update list counters
  obj.si= set(obj.si, 'nf', nf - length(isf) + length(isr));
  obj.si= set(obj.si, 'nr', nr - length(isr) + length(isf));
  % finally, add to the new list
  obj.si= set(obj.si, 'uf', sort([uf; sr]));
  obj.si= set(obj.si, 'ur', sort([ur; sf]));
  obj.si= set(obj.si, 'uh', uh);
end