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
function obj= net_(obj)
  % open file
  fid= fopen(strcat(obj.fi,'.net'),'r');
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
  if v ~= 3.0
    fclose(fid);
    error('SINopt:io:fileNotSupported', ...
        'HydroLab NET file version %1.1f is not supported', v);
  end
  % [NSUB]
  %  number of subsystems
  linha= fgetl(fid);
  while not(strcmp('[NSUB]',linha))
    linha= fgetl(fid);
  end
  % read data
  ns= fscanf(fid,'%d',1);
  % sanity check
  if ns ~= get(obj.si,'ns')
    error('SINopt:io:numberMismatch', 'Wrong number of subsystems');
  end
  % [NCYC]
  %  number of network loops
  linha= fgetl(fid);
  while not(strcmp('[NCYC]',linha))
    linha= fgetl(fid);
  end
  % read data
  nc= fscanf(fid,'%d',1);
  % store data
  obj.si= set(obj.si,'nc',nc);
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
  if np ~= get(obj.si,'np')
    error('SINopt:io:numberMismatch','Wrong number of load levels');
  end
  % [NLIN]
  %  number of transmission lines
  linha= fgetl(fid);
  while not(strcmp('[NLIN]',linha))
    linha= fgetl(fid);
  end
  % read data
  nl= fscanf(fid,'%d',1);
  % store data
  obj.si= set(obj.si,'nl',nl);
  % [TOPO]
  %  transmission lines
  linha= fgetl(fid);
  while not(strcmp('[TOPO]',linha))
    linha= fgetl(fid);
  end
  % read and store data
  obj.si= set(obj.si,'li',fscanf(fid,'%d',[2, nl])');
  % [LIMA]
  %  upper bounds on power transmission
  linha= fgetl(fid);
  while not(strcmp('[LIMA]',linha))
    linha= fgetl(fid);
  end
  % memory allocation
  im= cell(np,1);
  for l= 1:np
    im{l}= zeros(nl,ni);
  end
  % read data
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    for l= 1:np
      fscanf(fid,'%d',1); % bogus
      for k= 1:nl
        im{l}(k,j)= fscanf(fid,'%f',1);
      end
    end
  end
  % store data
  obj.si= set(obj.si,'im',im);
  % clear temporary buffers
  clear im;
  % [LIMI]
  %  lower bounds on power transmission
  linha= fgetl(fid);
  while not(strcmp('[LIMI]',linha))
    linha= fgetl(fid);
  end
  % memory allocation
  in= cell(np,1);
  for l= 1:np
    in{l}= zeros(nl,ni);
  end
  % read data
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    for l= 1:np
      fscanf(fid,'%d',1); % bogus
      for k= 1:nl
        in{l}(k,j)= fscanf(fid,'%f',1);
      end
    end
  end
  % store data
  obj.si= set(obj.si,'in',in);
  % clear temporary buffers
  clear in;
  % [REAT]
  %  reactances
  linha= fgetl(fid);
  while not(strcmp('[REAT]',linha))
    linha= fgetl(fid);
  end
  % memory allocation
  rt= zeros(nc,get(obj.si,'nl'));
  % read data
  for j= 1:nc
    rt(j,:)= fscanf(fid,'%f',[get(obj.si,'nl'), 1]);
  end
  % store data
  obj.si= set(obj.si,'rt',rt);
  % clear temporary buffer
  clear rt;
  % close file
  fclose(fid);
end