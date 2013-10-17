% @io/private/bus_.m reads BUS files.
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
function obj= bus_(obj)
  % open file
  fid= fopen(strcat(obj.fi,'.bus'),'r');
  frewind(fid);
  % [VERS]
  %  file version
  linha= fgetl(fid);
  while not(strcmp('[VERS]',linha))
    linha= fgetl(fid);
  end
  % read
  v= fscanf(fid,'%f',1);
  % check for file version
  if v ~= 1.0
    fclose(fid);
    error('SINopt:io:fileNotSupported', ...
          'HydroLab MCO file version %1.1f is not supported', v);
  end
  % [NBUS]
  %  number of buses
  linha= fgetl(fid);
  while not(strcmp('[NBUS]',linha))
    linha= fgetl(fid);
  end
  % read
  ns= fscanf(fid,'%d',1);
  obj.si= set(obj.si,'ns',ns);
  % [NINT]
  %  number of stages
  linha= fgetl(fid);
  while not(strcmp('[NINT]',linha))
    linha= fgetl(fid);
  end
  % read
  ni= fscanf(fid,'%d',1);
  % sanity check
  if ni ~= get(obj.si,'ni')
    error('SINopt:io:numberMismatch','Wrong number of stages');
  end
  % [NPAT]
  %  number of load levels per stage
  linha= fgetl(fid);
  while not(strcmp('[NPAT]',linha))
    linha= fgetl(fid);
  end
  % read
  np= fscanf(fid,'%d',1);
  % sanity check
  if np ~= get(obj.si,'np');
    error('SINopt:io:numberMismatch','Wrong number of load levels');
  end
  % [LOAD]
  %  load per bus, load level, and stage
  linha= fgetl(fid);
  while not(strcmp('[LOAD]',linha))
    linha= fgetl(fid);
  end
  % memory allocation
  dc= cell(np,1);
  for l= 1:np
    dc{l}= zeros(ns,ni);
  end
  % read
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    for l= 1:np
      fscanf(fid,'%d',1); % bogus
      for k= 1:ns
        dc{l}(k,j)= fscanf(fid,'%f',1);
      end
    end
  end
  % store data
  obj.si= set(obj.si,'dc',dc);
  % clear temporary buffer
  clear dc;
  % [GENR]
  %  generation given per bus, load level, and stage
  linha= fgetl(fid);
  while not(strcmp('[GENR]',linha))
    linha= fgetl(fid);
  end
  % memory allocation
  gp= cell(np,1);
  for l= 1:np
    gp{l}= zeros(ns,ni);
  end
  % read
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    for l= 1:np
      fscanf(fid,'%d',1); % bogus
      for k= 1:ns
        gp{l}(k,j)= fscanf(fid,'%f',1);
      end
    end
  end
  % store data
  obj.si= set(obj.si,'gp',gp);
  % clear temporary buffer
  clear gp;
  % close file
  fclose(fid);
end