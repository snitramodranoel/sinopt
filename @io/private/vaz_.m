% @io/private/vaz_.m reads VAZ files.
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
function obj= vaz_(obj, arquivo)
  % open file
  fid= fopen(arquivo,'r');
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
  if v ~= 2.0
    fclose(fid);
    error('sinopt:io:vaz:fileNotSupported', ...
          'HydroLab VAZ file version %1.1f is not supported', v);
  end
  % [NUHE]
  %  number of hydro plants
  linha= fgetl(fid);
  while not(strcmp('[NUHE]',linha))
    linha= fgetl(fid);
  end
  % read data
  nu= fscanf(fid,'%d',1);
  % sanity check
  if nu ~= get(obj.si,'nu')
    error('sinopt:io:vaz:numberMismatch','Wrong number of hydro plants');
  end
  % [NINT]
  %  number of hydro plants
  linha= fgetl(fid);
  while not(strcmp('[NINT]',linha))
    linha= fgetl(fid);
  end
  % read data
  ni= fscanf(fid,'%d',1);
  % sanity check
  if ni ~= get(obj.si,'ni')
    error('sinopt:io:vaz:numberMismatch','Wrong number of stages');
  end
  % [VAZO]
  %  inflows
  linha= fgetl(fid);
  while not(strcmp('[VAZO]',linha))
    linha= fgetl(fid);
  end
  % memory allocation
  af= zeros(nu,ni);
  % read data
  for j= 1:ni
    fscanf(fid,'%s',1); % bogus
    af(:,j)= fscanf(fid,'%f',[nu,1]);
  end
  % store data
  obj.si= set(obj.si,'af',af);
  % clear temporary buffer
  clear af;
  % close file
  fclose(fid);
end