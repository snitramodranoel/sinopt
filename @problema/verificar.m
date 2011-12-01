% @problema/verificar.m performs basic sanity check on problem constraints.
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
function obj= verificar(obj)
  % system data
  af= get(obj.si,'af');
  dn= get(obj.si,'dn');
  ti= get(obj.si,'ti');
  tp= get(obj.si,'tp');
  uf= get(obj.si,'uf');
  % system dimensions
  nf= get(obj.si,'nf');
  ni= get(obj.si,'ni');
  np= get(obj.si,'np');
  %
  % bounds on reservoir storage
  if length(obj.ls) ~= length(obj.us)
    error('SINopt:problema:arrayDimensionsMismatch', ...
        'Storage bound array dimensions do not match');
  else
    indices= find(obj.us - obj.ls <= 0);
    for j= 1:length(indices)
      k= indices(j);
      % sanity check
      if obj.us(k) - obj.ls(k) < 0
        error('SINopt:problema:xBounds', ...
            'Storage bounds define an empty set @ s(%d)', k);
      end
    end
  end
  % clear temporary buffer
  clear indices;
  %
  % bounds on water spill
  if length(obj.lv) ~= length(obj.uv)
    error('SINopt:problema:arrayDimensionsMismatch', ...
        'Water spill bound array dimensions do not match');
  else
    indices= find(obj.uv - obj.lv <= 0, 1);
    if ~isempty(indices)
      error('SINopt:problema:xBounds', ...
          'Water spill bounds define an empty set @ v(%d)', indices(1));
    end
  end
  % clear temporary buffer
  clear indices;
  %
  % bounds on water discharge
  if length(obj.lq) ~= length(obj.uq)
    error('SINopt:problema:arrayDimensionsMismatch', ...
        'Water discharge bound array dimensions do not match');
  else
    indices= find(obj.uq - obj.lq <= 0);
    for j= 1:length(indices)
      k= indices(j);
      obj.lv(k)= obj.lv(k) + (obj.lq(k) - obj.uq(k));
      obj.lq(k)= 0;
      warning('SINopt:problema:xBounds', ...
          'Water discharge lower bounds relaxed @ q(%d)', k);
    end
  end
  % clear temporary buffers
  clear k;
  clear indices;
  %
  % bounds on power transmission
  if length(obj.ly) ~= length(obj.uy)
    error('SINopt:problema:arrayDimensionsMismatch', ...
        'Power transmission bound array dimensions do not match');
  else
    indices= find(obj.uy - obj.ly < obj.uy);
    for j= 1:length(indices)
      k= indices(j);
      if obj.uy - obj.ly < 0
        error('SINopt:problema:yBounds', ...
            'Power transmission bounds define an empty set @ y(%d)', k);
      end
    end
  end
  % clear temporary buffer
  clear indices;
  %
  % bounds on thermal power generation
  if length(obj.lz) ~= length(obj.uz)
    error('SINopt:problema:arrayDimensionsMismatch', ...
        'Thermal power generation bound array dimensions do not match');
  else
    indices= find(obj.uz - obj.lz < 0);
    if ~isempty(indices)
      for j= 1:length(indices)
        obj.lz(indices(j)) = obj.uz(indices(j));
        warning('SINopt:problema:zBounds', ...
            'Thermal power generation bounds define an empty set @ z(%d)', ...
            indices(j));
      end
    end
  end
  % clear temporary buffer
  clear indices;
  %
  % load level duration
  for j= 1:ni
    sp= 0;
    for l= 1:np
      sp= sp + tp{l}(j);
    end
    if sp ~= ti(j)
      error('SINopt:problema:timeMismatch', ...
          'Load level duration does not match stage duration @ j(%d)', j);
    end
  end
  %
  % lower bounds on release for upstream run-off-river plants
  for i= 1:nf
    up= upstream(obj.si,uf(i));
    if isempty(up)
      indices= find(af(uf(i),:) - dn(uf(i),:) < 0, 1);
      if ~isempty(indices)
        error('SINopt:problema:xBounds', ...
            'Infeasible minimum release @ r(%d,%d)', uf(i), indices(1));
      end
    end
    % clear temporary buffer
    clear indices;
  end
end