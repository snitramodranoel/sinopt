% @io/private/ter.m reads TER files.
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
function obj= ter(obj,arquivo)
  % abre arquivo
  fid= fopen(arquivo,'r');
  frewind(fid);

  % [VERS]
  %  vers?o do arquivo
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[VERS]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l? vers?o do arquivo
  v= fscanf(fid,'%f',1);
  % verifica vers?o do arquivo
  if v ~= 2.0
    fclose(fid);
    error('hydra:io:ter:fileNotSupported', ...
          'HydroLab TER file version %1.1f is not supported', v);
  end

  % [NUSI]
  %  n?mero de usinas
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NUSI]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l? n?mero de usinas
  obj.si= set(obj.si,'nt',fscanf(fid,'%d',1));

  % aloca objetos ute
  nt= get(obj.si,'nt');
  ut= cell(get(obj.si,'nt'),1);
  for j= 1:nt
    ut{j} = ute();
  end

  % [NOME]
  %  nomes das usinas
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NOME]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l? nomes das usinas
  % (1) ?ndice do aproveitamento no estudo
  % (2) nome da UTE
  for j= 1:nt
    % bogus
    fscanf(fid,'%s',1);
    % nome da usina
    ut{j}= set(ut{j},'nm',fgetl(fid));
  end

  % [CSSE]
  %  c?digos das usinas
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[CSSE]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l? c?digos das usinas
  % (1) ?ndice da usina no estudo
  % (2) c?digo do subsistema
  % (3) c?digo da usina
  % (4) est?gio de opera??o da usina
  for j= 1:nt
    % bogus
    fscanf(fid,'%d',1);
    ut{j}= set(ut{j},'ss',fscanf(fid,'%d',1));
    ut{j}= set(ut{j},'cd',fscanf(fid,'%d',1));
    ut{j}= set(ut{j},'eo',fscanf(fid,'%d',1));
  end

  % [POTI]
  %  pot?ncia instalada
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[POTI]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l? pot?ncia instalada
  % (1) ?ndice da usina no estudo
  % (2) pot?ncia instalada
  for j= 1:nt
    fscanf(fid,'%d',1);
    ut{j}= set(ut{j},'pi',fscanf(fid,'%f',1));
  end

  % [NIDN]
  %  n?mero de intervalos
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NIDN]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  ni= fscanf(fid,'%d',1);
  % verifica a quantidade de intervalos
  if ni ~= get(obj.si,'ni')
    error('hydra:io:ter:numberMismatch','wrong number of time intervals');
  end

  % [PUGT]
  %  pot?ncia efetiva
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[PUGT]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  for j= 1:nt
    fscanf(fid,'%d',1); % bogus
    ut{j}= set(ut{j},'pe',fscanf(fid,'%f',[get(obj.si,'ni'),1]));
  end
  
  % [TXID]
  %  taxa de indisponibilidade programada
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[TXID]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  for j= 1:nt
    fscanf(fid,'%d',1); % bogus
    ut{j}= set(ut{j},'ip',fscanf(fid,'%f',[get(obj.si,'ni'),1])*1e-2);
  end

  % [TEIF]
  %  taxa de indisponibilidade forcada
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[TEIF]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  for j= 1:nt
    fscanf(fid,'%d',1); % bogus
    ut{j}= set(ut{j},'if',fscanf(fid,'%f',[get(obj.si,'ni'),1])*1e-2);
  end

  % [GMIN]
  %  pot?ncia instalada
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[GMIN]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  for j= 1:nt
    fscanf(fid,'%d',1); % bogus
    ut{j}= set(ut{j},'gn',fscanf(fid,'%f',[get(obj.si,'ni'),1]));
  end

  % [CUST]
  %  custo de gera??o
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[CUST]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l? polin?mios de custo de gera??o
  % (1) ?ndice da usina no estudo
  % (2) polin?mio de quarto grau
  for j= 1:nt
    % bogus
    fscanf(fid,'%s',1);
    % polin?mio de custo de gera??o
    M= fscanf(fid,'%f',[5 1]);
    poli= get(ut{j},'cg');
    poli= set(poli,'cf',M);
    ut{j}= set(ut{j},'cg',poli);
    clear poli M;
  end

  % [FCMX]
  %  fator de capacidade m?xima
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[FCMX]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos dados
  for j= 1:nt
    fscanf(fid,'%d',1);
    ut{j}= set(ut{j},'fc',fscanf(fid,'%f',[get(obj.si,'ni'),1])*1e-2);
  end

  % atualiza lista de usinas
  obj.si= set(obj.si,'ut',ut);

  % fecha arquivo
  fclose(fid);
end