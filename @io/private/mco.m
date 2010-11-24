% @io/private/mco.m reads MCO files.
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
function obj= mco(obj, arquivo)
  % abre arquivo
  fid= fopen(arquivo,'r');
  frewind(fid);

  % [VERS]
  %  vers??o do arquivo
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[VERS]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  v= fscanf(fid,'%f',1);
  % verifica vers??o do arquivo
  if v ~= 1.2
    fclose(fid);
    error('hydra:io:mco:fileNotSupported', ...
          'HydroLab MCO file version %1.1f is not supported', v);
  end

  % [NINT]
  %  quantidade de intervalos
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NINT]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  ni= fscanf(fid,'%d',1);
  % verifica a quantidade de intervalos
  if ni ~= get(obj.si,'ni')
    error('hydra:io:mco:numberMismatch','wrong number of time intervals');
  end

  % [NMER]
  %  quantidade de subsistemas
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NMER]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  obj.si= set(obj.si,'ns',fscanf(fid,'%d',1));

  % [MSDT]
  %  valores de mercado por subsistema e intervalo
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[MSDT]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  dc= fscanf(fid,'%f',[get(obj.si,'ns'), get(obj.si,'ni')]);

  % [MAND]
  %  mercado de exporta????o
  %  (soma-se ao mercado do sudeste/centro-oeste)
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[MAND]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  ma= fscanf(fid,'%f',[1, get(obj.si,'ni')]);

  % [GPCH]
  %  gera????o de pequenas centrais hidrel??tricas
  %  (abate-se do submercado correspondente)
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[GPCH]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  gp= fscanf(fid,'%f',[get(obj.si,'ns'), get(obj.si,'ni')]);

  % corrige mercado
  dc= dc - gp;
  dc(1,:) = dc(1,:) + ma;
  obj.si= set(obj.si,'dc',dc);

  % fecha arquivo
  fclose(fid);
end