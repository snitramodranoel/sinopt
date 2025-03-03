% @io/private/ute_.m reads UTE files.
%
% Copyright (c) 2013 Leonardo Martins, Universidade Estadual de Campinas
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
function obj= ute_(obj)
  % open file
  fid= fopen(strcat(obj.fi,'.ute'),'r');
  frewind(fid);
  % [VERS]
  %  file version
  linha= fgetl(fid);
  while not(strcmp('[VERS]',linha))
    linha= fgetl(fid);
  end
  % read data
  v= fscanf(fid,'%f',1);
  % check for file version
  if v ~= 3.4
    fclose(fid);
    error('SINopt:io:fileNotSupported', ...
          'HydroLab UTE file version %1.1f is not supported', v);
  end
  % [NUTE]
  %  number of thermal plants
  linha= fgetl(fid);
  while not(strcmp('[NUTE]',linha))
    linha= fgetl(fid);
  end
  % read data
  nt= fscanf(fid,'%d',1);
  obj.si= set(obj.si,'nt',nt);
  % [NINT]
  %  number of stages
  linha= fgetl(fid);
  while not(strcmp('[NINT]',linha))
    linha= fgetl(fid);
  end
  % read data
  ni= fscanf(fid,'%d',1);
  % sanity check
  if ni ~= get(obj.si,'ni')
    error('SINopt:io:numberMismatch', 'Wrong number of stages');
  end
  % [NPAT]
  %  number of load levels per stage
  linha= fgetl(fid);
  while not(strcmp('[NPAT]',linha))
    linha= fgetl(fid);
  end
  % read data
  np= fscanf(fid,'%d',1);
  % sanity check
  if np ~= get(obj.si,'np');
    error('SINopt:io:numberMismatch','Wrong number of load levels');
  end
  % memory allocation
  ut= cell(get(obj.si,'nt'),1);
  fc= cell(nt,1);
  gn= cell(nt,1);
  id= cell(nt,1);
  pe= cell(nt,1);
  %
  for t= 1:nt
    ut{t}= ute();
    fc{t}= zeros(np,ni);
    gn{t}= zeros(np,ni);
    id{t}= zeros(np,ni);
    pe{t}= zeros(np,ni);
  end
  % [UTID]
  %  thermal plant identification
  linha= fgetl(fid);
  while not(strcmp('[UTID]',linha))
    linha= fgetl(fid);
  end
  % read and store data
  for j= 1:nt
    fscanf(fid,'%s',1); % bogus
    ut{j}= set(ut{j},'nm',strtrim(fgetl(fid))); % identification
  end
  % [PRIM]
  %  codes
  linha= fgetl(fid);
  while not(strcmp('[PRIM]',linha))
    linha= fgetl(fid);
  end
  % read and store data
  for j= 1:nt
    fscanf(fid,'%d',1); % bogus
    ut{j}= set(ut{j},'cd',fscanf(fid,'%d',1)); % Eletrobras code
    ut{j}= set(ut{j},'eo',fscanf(fid,'%d',1)); % operation status
    % number of connected buses
    nb= fscanf(fid,'%i',1);
    bc= zeros(nb,1);
    df= zeros(nb,1);
    for k= 1:nb
      bc(k)= fscanf(fid,'%i',1); % bus number
      df(k)= fscanf(fid,'%f',1); % distribution factor
      fgetl(fid); % bogus
    end
    ut{j}= set(ut{j},'bc',bc);
    ut{j}= set(ut{j},'df',df);
  end
  % clear temporary buffers
  clear nb;
  clear bc;
  clear df;
  % [PUTE]
  %  installed capacity
  linha= fgetl(fid);
  while not(strcmp('[PUTE]',linha))
    linha= fgetl(fid);
  end
  % read data
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    for p= 1:np
      fscanf(fid,'%d',1); % bogus
      tb= fscanf(fid,'%f',[nt,1]);
      for t= 1:nt
        pe{t}(p,j)= tb(t);
      end
      % clear temporary buffers
      clear tb;
    end
  end
  % [DISP]
  %  availability rate
  linha= fgetl(fid);
  while not(strcmp('[DISP]',linha))
    linha= fgetl(fid);
  end
  % read data
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    for p= 1:np
      fscanf(fid,'%d',1); % bogus
      tb= fscanf(fid,'%f',[nt,1]);
      for t= 1:nt
        id{t}(p,j)= tb(t);
      end
      % clear temporary buffers
      clear tb;
    end
  end
  % [GMIN]
  %  lower bounds on power generation
  linha= fgetl(fid);
  while not(strcmp('[GMIN]',linha))
    linha= fgetl(fid);
  end
  % read data
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    for p= 1:np
      fscanf(fid,'%d',1); % bogus
      tb= fscanf(fid,'%f',[nt,1]);
      for t= 1:nt
        gn{t}(p,j)= tb(t);
      end
      % clear temporary buffers
      clear tb;
    end
  end
  % [CUSP]
  %  cost functions
  linha= fgetl(fid);
  while not(strcmp('[CUSP]',linha))
    linha= fgetl(fid);
  end
  % read data
  for j= 1:nt
    % bogus
    fscanf(fid,'%s',1);
    % read polynomial data
    cf= fscanf(fid,'%f',[5 1]);
    % store polinomial data
    polinomio= set(get(ut{j},'co'),'cf',cf);
    ut{j}= set(ut{j},'co',polinomio);
    % clear temporary buffers
    clear polinomio;
    clear cf;
  end
  % [FCMX]
  %  capacity factor
  linha= fgetl(fid);
  while not(strcmp('[FCMX]',linha))
    linha= fgetl(fid);
  end
  % read data
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    for p= 1:np
      fscanf(fid,'%d',1); % bogus
      tb= fscanf(fid,'%f',[nt,1]);
      for t= 1:nt
        fc{t}(p,j)= tb(t)/100.0;
      end
      % clear temporary buffer
      clear tb;
    end
  end
  % update list of thermal plants
  for t= 1:nt
    ut{t}= set(ut{t},'fc',fc{t});
    ut{t}= set(ut{t},'gn',gn{t});
    ut{t}= set(ut{t},'id',id{t});
    ut{t}= set(ut{t},'pe',pe{t});
  end
  obj.si= set(obj.si,'ut',ut);
  % clear temporary buffers
  clear fc;
  clear gn;
  clear id;
  clear pe;
  % close file
  fclose(fid);
end