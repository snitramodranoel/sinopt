% @io/private/ute_.m reads UTE files.
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
function obj= ute_(obj,arquivo)
  % open file
  fid= fopen(arquivo,'r');
  frewind(fid);

  % [VERS]
  %  file version
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[VERS]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  v= fscanf(fid,'%f',1);
  % check for file version
  if v ~= 2.1
    fclose(fid);
    error('sinopt:io:ute:fileNotSupported', ...
          'HydroLab UTE file version %1.1f is not supported', v);
  end

  % [NUTE]
  %  number of thermal plants
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NUTE]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  nt= fscanf(fid,'%d',1);
  obj.si= set(obj.si,'nt',nt);

  % [NINT]
  %  number of stages
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NINT]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  ni= fscanf(fid,'%d',1);
  % sanity check
  if ni ~= get(obj.si,'ni')
    error('sinopt:io:ute:numberMismatch', 'Wrong number of stages');
  end

  % [NPAT]
  %  number of load levels per stage
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NPAT]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  np= fscanf(fid,'%d',1);
  % sanity check
  if np ~= get(obj.si,'np');
    error('sinopt:io:ute:numberMismatch','Wrong number of load levels');
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
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[UTID]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read and store data
  for j= 1:nt
    fscanf(fid,'%s',1); % bogus
    ut{j}= set(ut{j},'nm',strtrim(fgetl(fid))); % identification
  end

  % [PRIM]
  %  codes
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[PRIM]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read and store data
  for j= 1:nt
    fscanf(fid,'%d',1); % bogus
    ut{j}= set(ut{j},'ss',fscanf(fid,'%d',1));
    ut{j}= set(ut{j},'cd',fscanf(fid,'%d',1));
    ut{j}= set(ut{j},'eo',fscanf(fid,'%d',1));
    fscanf(fid,'%d',1); % bogus
    fscanf(fid,'%f',1); % bogus
  end

  % [PUGT]
  %  installed capacity
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[PUGT]',linha))
    linha= fscanf(fid,'%s\n',1);
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

  % [TXID]
  %  availability rate
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[TXID]',linha))
    linha= fscanf(fid,'%s\n',1);
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
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[GMIN]',linha))
    linha= fscanf(fid,'%s\n',1);
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

  % [CUST]
  %  cost functions
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[CUST]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  for j= 1:nt
    % bogus
    fscanf(fid,'%s',1);
    % read polynomial data
    cf= fscanf(fid,'%f',[5 1]);
    % store polinomial data
    polinomio= set(get(ut{j},'cg'),'cf',cf);
    ut{j}= set(ut{j},'cg',polinomio);
    % clear temporary buffers
    clear polinomio;
    clear cf;
  end

  % [FCMX]
  %  capacity factor
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[FCMX]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    for p= 1:np
      fscanf(fid,'%d',1); % bogus
      tb= fscanf(fid,'%f',[nt,1]);
      for t= 1:nt
        fc{t}(p,j)= tb(t);
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