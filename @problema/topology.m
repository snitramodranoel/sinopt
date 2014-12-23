% TOPOLOGY builds topology lists of cascaded reservoirs.
%
%   OBJ = COMPRESS(OBJ) builds Lambda, Psi, and Omega
%
%   Copyright IBM Corporation 2014. All Rights Reserved.
function obj = topology(obj)
  % system data
  ll = get(obj.si, 'll');
  lo = get(obj.si, 'lo');
  lp = get(obj.si, 'lp');
  nu = get(obj.si, 'nu');
  uh = get(obj.si, 'uh'); % list of hydro plants
  uf = get(obj.si, 'uf'); % list of indexes of run-off-river hydro plants
  ur = get(obj.si, 'ur'); % list of indexes of reservoirs with variable storage

  % memory allocation
  for i = 1:nu
    ll{i} = [];
    lo{i} = [];
    lp{i} = [];
  end
  
  % build lists
  for i = 1:nu
    % check for any downstream plants
    j = get(uh{i}, 'ij');
    if j
      % update Omega(j)
      lo{j}(end+1) = i;
      % non-ROR?
      if find(ur==i, 1)
        if find(uf==j, 1) % check if downstream is ROR
          bld(i, j); % update Lambda, Psi lists
        end
      end
    end
  end

  % update system data
  obj.si = set(obj.si, 'll', ll);
  obj.si = set(obj.si, 'lo', lo);
  obj.si = set(obj.si, 'lp', lp);
  
  function bld(i,j)
    ll{j}(end+1) = i; % update Lambda(j)
    lp{i}(end+1) = j; % update Psi(i)
    % move down the cascade
    if find(uf==get(uh{j}, 'ij'), 1)
      bld(i, get(uh{j}, 'ij'));
    end
  end
end