% @io/private/hco.m reads HCO files.
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
function obj= hco(obj,arquivo)
  % open file
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
  if v ~= 1.1
    fclose(fid);
    error('hydra:io:hco:fileNotSupported', ...
      'HydroLab HCO file version %1.1f is not supported', v);
  end

  % [NUNI]
  %  n??mero de uhes e intervalos de tempo
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NUNI]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? n??mero de usinas e intervalos de tempo
  % (1) n??mero de usinas
  % (2) n??mero de intervalos de tempo
  obj.si= set(obj.si,'nu',fscanf(fid,'%i',1));
  obj.si= set(obj.si,'ni',fscanf(fid,'%i',1));

  % [MIAI]
  %  m??s e ano iniciais
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[MIAI]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? m??s e ano iniciais
  % (1) m??s inicial
  % (2) ano inicial
  obj.si= set(obj.si,'mi',fscanf(fid,'%i',1));
  obj.si= set(obj.si,'ai',fscanf(fid,'%i',1));

  % [VOIF]
  %  volumes inicial e final
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[VOIF]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? volumes inicial e final
  % (1) volume inicial
  % (2) volume final
  voif= fscanf(fid,'%f',[2, get(obj.si,'nu')]);
  obj.si= set(obj.si,'vi',voif(1,:)');
  obj.si= set(obj.si,'vf',voif(2,:)');
  clear voif;

  % [VMSZ]
  %  volumes m??ximos sazonais
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[VMSZ]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? volumes m??ximos sazonais
  obj.si= set(obj.si,'vz',fscanf(fid,'%f',[12, get(obj.si,'nu')])');

  % [VMAX]
  %  volume m??ximo
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[VMAX]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? volume m??ximo
  obj.si= set(obj.si,'vm', ...
    fscanf(fid,'%f',[get(obj.si,'nu'), get(obj.si,'ni')]));

  % [VMIN]
  %  volume m??nimo
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[VMIN]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? volume m??nimo
  obj.si= set(obj.si,'vn', ...
    fscanf(fid,'%f',[get(obj.si,'nu'), get(obj.si,'ni')]));
  
  % [EVSZ]
  %  coeficientes sazonais de evapora????o
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[EVSZ]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % bogus
  fscanf(fid,'%d',1);
  % l?? coeficientes sazonais de evapora????o
  obj.si= set(obj.si,'ez',fscanf(fid,'%f',[12, get(obj.si,'nu')])');

  % [EVAP]
  %  coeficientes de evapora????o por usina e intervalo
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[EVAP]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos coeficientes de evapora????o
  obj.si= set(obj.si,'ev', ...
    fscanf(fid,'%f',[get(obj.si,'nu'), get(obj.si,'ni')]));

  % [UCSZ]
  %  valores sazonais de uso consuntivo
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[UCSZ]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % uso consuntivo deve ser considerado?
  boo= fscanf(fid,'%d',1);
  % l?? valores sazonais de uso consuntivo
  obj.si= set(obj.si,'uz',fscanf(fid,'%f',[12, get(obj.si,'nu')])');

  % [USOC]
  %  valores de uso consuntivo
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[USOC]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos valores de uso consuntivo
  uc= fscanf(fid,'%f',[get(obj.si,'nu'), get(obj.si,'ni')]);
  if (boo)
    obj.si= set(obj.si,'uc',uc);
  else
    obj.si= set(obj.si,'uc',0*uc); 
  end
  clear uc;
  clear boo;

  % [DEFM]
  %  deflu??ncia m??nima por usina e intervalo de tempo
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[DEFM]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura dos valores de deflu??ncia minima
  obj.si= set(obj.si,'dn', ...
    fscanf(fid,'%f',[get(obj.si,'nu'), get(obj.si,'ni')]));

  % [NMAQ]
  %  n??mero m??ximo de m??quinas dispon??veis
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NMAQ]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura do n??mero m??ximo de m??quinas
  obj.si= set(obj.si,'nq', ...
    fscanf(fid,'%f',[get(obj.si,'nu'), get(obj.si,'ni')]));

  % [MENS]
  %  valores de mercado e tamanho de intervalo de tempo
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[MENS]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % faz leitura de tamanho de intervalo
  %  (ignora-se valores de mercado)
  ti= fscanf(fid,'%f',[2, get(obj.si,'ni')])';
  obj.si= set(obj.si,'ti',ti(:,2)');
  clear ti;

  % fecha arquivo
  fclose(fid);
end