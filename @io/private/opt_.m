% @io/private/opt_.m reads OPT files.
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
function obj= opt_(obj)
  % open file
  fid= fopen(strcat(obj.fi,'.opt'),'r');
  frewind(fid);
  % [VERS]
  %  file version
  linha= fgetl(fid);
  while not(strcmp('[VERS]',linha))
    linha= fgetl(fid);
  end
  % read file version
  v= fscanf(fid,'%f',1);
  % check for file version
  if v ~= 2.1
    fclose(fid);
    error('SINopt:io:fileNotSupported', ...
      'HydroLab OPT file version %1.1f is not supported', v);
  end
  % [ALGO]
  %  optimization algorithm to be run
  linha= fgetl(fid);
  while not(strcmp('[ALGO]',linha))
    linha= fgetl(fid);
  end
  % read algorithm
  obj.pb= set(obj.pb,'so',strtrim(lower(fgetl(fid))));
  % [MAXI]
  %  maximum number of iterations
  linha= fgetl(fid);
  while not(strcmp('[MAXI]',linha))
    linha= fgetl(fid);
  end
  % read maximum number of iterations
  obj.pb= set(obj.pb,'km',fscanf(fid,'%i',1));
  % [VERB]
  %  verbosity
  linha= fgetl(fid);
  while not(strcmp('[VERB]',linha))
    linha= fgetl(fid);
  end
  % read verbosity
  dvn= 0;
  dvs= strtrim(lower(fgetl(fid)));
  if (strcmp(dvs,'final'))
      dvn= 1;
  elseif (strcmp(dvs,'iter'))
      dvn= 5;
  % TODO: check for numerical values
  end
  obj.pb= set(obj.pb,'dv',dvn);
  % close file
  fclose(fid);
end