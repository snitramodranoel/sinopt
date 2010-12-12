% @io/private/hco_.m reads HCO files.
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
function obj= hco_(obj,arquivo)
  % open file
  fid= fopen(arquivo,'r');
  frewind(fid);

  % [VERS]
  %  file version
  linha= fscanf(fid,'%s\n',1);
  while ~(strcmp('[VERS]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read
  v= fscanf(fid,'%f',1);
  % check for file version
  if v ~= 2.0
    fclose(fid);
    error('sinopt:io:hco:fileNotSupported', ...
      'HydroLab HCO file version %1.1f is not supported', v);
  end

  % [DATA]
  %  start date
  linha= fscanf(fid,'%s\n',1);
  while ~(strcmp('[DATA]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read
  % (1) day, (2) month, (3) year
  obj.si= set(obj.si,'di',fscanf(fid,'%d',1));
  obj.si= set(obj.si,'mi',fscanf(fid,'%d',1));
  obj.si= set(obj.si,'ai',fscanf(fid,'%d',1));
  
  % [NUHE]
  %  number of hydro plants
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NUHE]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read
  nu= fscanf(fid,'%d',1);
  obj.si= set(obj.si,'nu',nu);

  % [NINT]
  %  number of stages
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NINT]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read
  ni= fscanf(fid,'%d',1);
  obj.si= set(obj.si,'ni',ni);

  % [NPAT]
  %  number of load levels
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NPAT]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read
  np= fscanf(fid,'%d',1);
  obj.si= set(obj.si,'np',np);

  % [VOIF]
  %  initial and final reservoir storage requirements
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[VOIF]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read
  % (1) initial
  % (2) final
  voif= fscanf(fid,'%f',[2, get(obj.si,'nu')]);
  obj.si= set(obj.si,'vi',voif(1,:)');
  obj.si= set(obj.si,'vf',voif(2,:)');
  % clear temporary buffer
  clear voif;

  % [VMAX]
  %  maximum reservoir storage
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[VMAX]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read
  vm= zeros(nu,ni);
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    vm(:,j)= fscanf(fid,'%f',[nu,1]);
  end
  obj.si= set(obj.si,'vm', vm);
  % clear temporary buffer
  clear vm;

  % [VMIN]
  %  minimum reservoir storage
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[VMIN]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read
  vn= zeros(nu,ni);
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    vn(:,j)= fscanf(fid,'%f',[nu,1]);
  end
  obj.si= set(obj.si,'vn', vn);
  % clear temporary buffer
  clear vn;
  
  % [EVAP]
  %  evaporation coefficients
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[EVAP]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read
  ev= zeros(nu,ni);
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    ev(:,j)= fscanf(fid,'%f',[nu,1]);
  end
  obj.si= set(obj.si,'ev', ev);
  % clear temporary buffer
  clear ev;

  % [USOC]
  %  consumptive use of reservoir water
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[USOC]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read
  uc= zeros(nu,ni);
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    uc(:,j)= fscanf(fid,'%f',[nu,1]);
  end
  obj.si= set(obj.si,'uc', uc);
  % clear temporary buffer
  clear uc;

  % [DEFM]
  %  minimum water release
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[DEFM]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read
  dn= zeros(nu,ni);
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    dn(:,j)= fscanf(fid,'%f',[nu,1]);
  end
  obj.si= set(obj.si,'dn', dn);
  % clear temporary buffer
  clear dn;

  % [NMAQ]
  %  maximum number of generators available
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NMAQ]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read
  nq= zeros(nu,ni);
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    nq(:,j)= fscanf(fid,'%d',[nu,1]);
  end
  obj.si= set(obj.si,'nq', nq);
  % clear temporary buffer
  clear nq;

  % [DINT]
  %  duration of stages
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[DINT]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read
  ti= zeros(ni,1);
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    ti(:,j)= fscanf(fid,'%d',1);
  end
  obj.si= set(obj.si,'ti', ti);
  % clear temporary buffer
  clear ti;

  % [DPAT]
  %  load levels duration for each stage
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[DPAT]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read
  tp= zeros(np,ni);
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    tp(:,j)= fscanf(fid,'%d',[np,1]);
  end
  obj.si= set(obj.si,'tp', tp);
  % clear temporary buffer
  clear tp;

  % fecha arquivo
  fclose(fid);
end