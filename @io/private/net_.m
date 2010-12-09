% @io/private/net_.m reads NET files.
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
function obj= net_(obj, arquivo)
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
    error('sinopt:io:net:fileNotSupported', ...
        'HydroLab NET file version %1.1f is not supported', v);
  end

  % [NLIN]
  %  number of transmission lines
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NLIN]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  nl= fscanf(fid,'%d',1);
  obj.si= set(obj.si,'nl',nl);

  % [NSUB]
  %  number of subsystems
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NSUB]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  ns= fscanf(fid,'%d',1);
  % sanity check
  if ns ~= get(obj.si,'ns')
    error('sinopt:io:net:numberMismatch', 'Wrong number of subsystems');
  end

  % [NCYC]
  %  number of network loops
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NCYC]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  nc= fscanf(fid,'%d',1);
  obj.si= set(obj.si,'nc',nc);

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
    error('sinopt:io:net:numberMismatch', 'Wrong number of stages');
  end

  % [NPAT]
  %  number of load levels per stage
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NPAT]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  np= zeros(ni,1);
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    np(j)= fscanf(fid,'%d',1);
  end
  % sanity check
  if norm(np - get(obj.si,'np'), inf)
    error('sinopt:io:net:numberMismatch','Wrong number of load levels');
  end

  % [TOPO]
  %  transmission lines
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[TOPO]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  obj.si= set(obj.si,'li',fscanf(fid,'%d',[2, nl])');

  % [LIMA]
  %  upper bounds on power transmission
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[LIMA]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  im= cell(ni,1);
  for j= 1:ni
    ub= zeros(nl,np(j));
    fscanf(fid,'%s',1); % bogus
    for k= 1:np(j)
      fscanf(fid,'%d',1); % bogus
      ub(:,k)= fscanf(fid,'%f',[nl,1]);
    end
    im{j}= ub;
  end
  obj.si= set(obj.si,'im',im);
  % clear temporary buffers
  clear im;
  clear ub;

  % [LIMI]
  %  lower bounds on power transmission
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[LIMI]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  in= cell(ni,1);
  for j= 1:ni
    lb= zeros(nl,np(j));
    fscanf(fid,'%s',1); % bogus
    for k= 1:np(j)
      fscanf(fid,'%d',1); % bogus
      lb(:,k)= fscanf(fid,'%f',[nl,1]);
    end
    in{j}= lb;
  end
  obj.si= set(obj.si,'in',in);
  % clear temporary buffers
  clear in;
  clear lb;

  % [REAT]
  %  reactances
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[REAT]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  rt= zeros(nc,get(obj.si,'nl'));
  for j= 1:nc
    rt(j,:)= fscanf(fid,'%f',[get(obj.si,'nl'), 1]);
  end
  obj.si= set(obj.si,'rt',rt);
  clear nc;
  clear rt;

  % close file
  fclose(fid);
end