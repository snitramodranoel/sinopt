% @io/private/ite.m reads ITE files.
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
function obj= ite(obj, arquivo)
  % abre arquivo
  fid= fopen(arquivo,'r');
  frewind(fid);

  % [VERS]
  %  vers??o do arquivo
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[VERS]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? vers??o do arquivo
  v= fscanf(fid,'%f',1);
  % verifica vers??o do arquivo
  if v ~= 2.0
    fclose(fid);
    error('hydra:ler_ter:fileNotSupported', ...
          'HydroLab TER file version %1.1f is not supported', v);
  end

  % [NUMR]
  %  quantidade de linhas de interc??mbio
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NUMR]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  obj.si= set(obj.si,'nl',fscanf(fid,'%d',1));

  % [NUMI]
  %  quantidade de intervalos
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NUMI]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  ni= fscanf(fid,'%d',1);
  if ni ~= get(obj.si,'ni')
    error('hydra:sistema:ler_ite:numberMismatch', ...
          'wrong number of time intervals');
  end

  % [NUMS]
  %  quantidade de subsistemas
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NUMS]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  ns= fscanf(fid,'%d',1);
  % verifica a quantidade de subsistemas
  if ns ~= get(obj.si,'ns')
    error('hydra:sistema:ler_ite:numberMismatch', ...
          'wrong number of systems');
  end

  % [CONX]
  %  linhas de interc??mbio
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[CONX]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  obj.si= set(obj.si,'li',fscanf(fid,'%d',[2, get(obj.si,'nl')])');

  % [LIMA]
  %  limites m??ximos de interc??mbio por intervalo
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[LIMA]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  obj.si= set(obj.si,'im',...
    fscanf(fid,'%f',[get(obj.si,'nl'), get(obj.si,'ni')]));

  % [LIMI]
  %  limites m??nimos de interc??mbio por intervalo
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[LIMI]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  obj.si= set(obj.si,'in',...
    fscanf(fid,'%f',[get(obj.si,'nl'), get(obj.si,'ni')]));

  % [REAT]
  %  reat??ncias
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[REAT]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura do n??mero de ciclos
  nc= fscanf(fid,'%d',1);
  obj.si= set(obj.si,'nc',nc);
  % faz leitura dos dados
  rt= zeros(nc,get(obj.si,'nl'));
  for j= 1:nc
    rt(j,:)= fscanf(fid,'%f',[get(obj.si,'nl'), 1]);
  end
  obj.si= set(obj.si,'rt',rt);
  clear nc;
  clear rt;

  % fecha arquivo
  fclose(fid);
end