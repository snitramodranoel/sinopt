% @io/private/usi.m reads USI files.
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
function obj= usi(obj, arquivo)
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
  if v ~= 1.9
    fclose(fid);
    error('hydra:io:usi:fileNotSupported', ...
        'HydroLab USI file version %1.1f is not supported', v);
  end

  % [NUSI]
  %  n??mero de usinas
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NUSI]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? n??mero de usinas
  nu= fscanf(fid,'%i',1);
  % verifica a quantidade de uhe's
  if nu ~= get(obj.si,'nu');
    error('hydra:io:usi:numberMismatch','wrong number of objects');
  end

  % aloca mem??ria para a lista de uhe's
  uh= cell(nu,1);
  for j= 1:nu
    uh{j}= uhe();
  end

  % [NOME]
  %  nomes das usinas
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NOME]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? nomes das usinas
  % (1) ??ndice do aproveitamento no estudo
  % (2) categoria:
  %       1) hidrologia
  %       2) reservat??rio
  %       3) pt. controle
  % (3) c??digo do arquivo no hidr.dat
  % (4) c??digo ONS
  % (5) sigla ONS
  % (6) sigla agente
  % (7) nome da usina
  for j= 1:nu
    % bogus
    fscanf(fid,'%s',1);
    fscanf(fid,'%s',1);
    fscanf(fid,'%s',1);
    fscanf(fid,'%s',1);
    fscanf(fid,'%s',1);
    fscanf(fid,'%s',1);
    % nome da usina
    uh{j}= set(uh{j}, 'nm', fgetl(fid));
  end

  % [NUMS]
  %  c??digos das usinas
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NUMS]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? c??digos associados ??s usinas
  % (1) ??ndice do aproveitamento no estudo
  % (2) c??digo do subsistema
  % (3) c??digo Eletrobr??s da usina
  % (4) c??digo do aproveitamento a jusante
  % (5) c??digo do est??gio de opera????o da usina
  for j= 1:nu
    % bogus
    fscanf(fid,'%s',1);
    % c??digo do subsistema
    uh{j}= set(uh{j},'ss',fscanf(fid,'%i',1));
    % c??digo Eletrobr??s
    uh{j}= set(uh{j},'cd',fscanf(fid,'%i',1));
    % c??digo Eletrobr??s do aproveitamento a jusante
    uh{j}= set(uh{j},'cj',fscanf(fid,'%i',1));
    % bogus
    fgetl(fid);
  end

  % [TOPO]
  %  informa????es de topologia
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[TOPO]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? informa????es de topologia
  % (1) ??ndice do aproveitamento no estudo
  % (2) ??ndice do aproveitamento a jusante no estudo
  for j= 1:nu
    % bogus
    fscanf(fid,'%s',1);
    % ??ndice do aproveitamento a jusante no estudo
    ij = fscanf(fid,'%i',1);
    if ij ~= nu
      uh{j}= set(uh{j},'ij',ij+1);
    else
      uh{j}= set(uh{j},'ij',0);
    end
  end
  % limpa vari??vel
  clear ij;

  % monta lista de ??ndices de aproveitamentos de montante
  for j= 1:nu
    t= 0;
    im= get(uh{j},'im');
    for k= 1:nu
      ij= get(uh{k},'ij');
      if (j==ij)
        t= t+1;
        im(t)= k;
      end
    end
    uh{j}= set(uh{j},'im',im);
  end
  clear t;
  clear ij;
  clear im;

  % [PRIM]
  %  informa????es de produtividade
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[PRIM]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? informa????es de produtividade
  % (1) ??ndice do aproveitamento no estudo
  % (2) produtibilidade espec??fica
  % (3) cota m??dia do canal de fuga
  % (4) tipo de perda de carga
  %       1) %
  %       2) constante
  %       3) q^2
  % (5) valor da perda de carga
  % (6) n??mero m??nimo de m??quinas sincronizadas
  % (7) tipo de representa????o da turbinagem m??xima
  %       1) vari??vel com a altura de queda
  %       2) constante
  for j= 1:nu
    % bogus
    fscanf(fid,'%s',1);
    % produtibilidade espec??fica
    uh{j}= set(uh{j},'pe',fscanf(fid,'%f',1));
    % cota m??dia do canal de fuga
    uh{j}= set(uh{j},'cf',fscanf(fid,'%f',1));
    % perda de carga hidr??ulica
    pc= {0; 0.0};
    pc{1}= fscanf(fid,'%i',1);
    pc{2}= fscanf(fid,'%f',1);
    switch pc{1}
      case 1
        pc{2}= pc{2} / 100.0;
    end
    uh{j}= set(uh{j},'pc',pc);
    % n??mero m??nimo de m??quinas sincronizadas
    uh{j}= set(uh{j},'ms',fscanf(fid,'%i',1));
    % representa????o da turbinagem m??xima
    uh{j}= set(uh{j},'tm',fscanf(fid,'%i',1));
  end
  % limpa vari??vel
  clear pc;

  % [TUGE]
  %  informa????es de gera????o
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[TUGE]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? informa????es de gera????o
  % (1) ??ndice do aproveitamento no estudo
  % (2) n??mero de conjuntos geradores
  % (3) tipo da turbina
  %       1) Francis
  %       2) Kaplan
  %       3) Pelton
  % (4) n??mero de turbinas
  % (5) altura efetiva
  % (6) engolimento efetivo
  % (7) pot??ncia efetiva
  % (8) rendimento de cada gerador
  % (9) restri????o de pot??ncia m??nima
  for j= 1:nu
    % bogus
    fscanf(fid,'%s',1);
    % n??mero de conjuntos geradores
    ng= fscanf(fid,'%i',1);
    uh{j}= set(uh{j},'ng',ng);
    % dados do conjunto
    M= fscanf(fid,'%f',[7 ng])';
    cgs= get(uh{j},'cg');
    % sumariza????o
    nt= 0;
    qef= 0.0;
    for k= 1:ng
      cgs{k}= cg();
      cgs{k}= set(cgs{k},'tt',round(M(k,1)));
      cgs{k}= set(cgs{k},'nt',round(M(k,2)));
      cgs{k}= set(cgs{k},'he',M(k,3));
      cgs{k}= set(cgs{k},'qe',M(k,4));
      cgs{k}= set(cgs{k},'pe',M(k,5));
      cgs{k}= set(cgs{k},'rg',M(k,6));
      cgs{k}= set(cgs{k},'pm',M(k,7));
      % total de turbinas
      nt= nt + get(cgs{k},'nt');
      % engolimento efetivo total 
      qef= qef + (get(cgs{k},'qe') * get(cgs{k},'nt'));
    end
    uh{j}= set(uh{j},'cg',cgs);
    uh{j}= set(uh{j},'nt',nt);
    uh{j}= set(uh{j},'qb',qef/nt);
  end

  % [TXID]
  %  informa????es de indisponibilidade
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[TXID]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? informa????es de indisponibilidade
  % (1) ??ndice do aproveitamento no estudo
  % (2) ??ndice de disponibilidade
  for j= 1:nu
    % bogus
    fscanf(fid,'%s',1);
    % ??ndice de disponibilidade
    uh{j}= set(uh{j},'id',fscanf(fid,'%f',1));
  end

  % [VMDM]
  %  limites de opera????o hidr??ulica
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[VMDM]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? limites de opera????o hidr??ulica
  % (1) ??ndice de aproveitamento do estudo
  % (2) volume m??nimo
  % (3) volume m??ximo
  % (4) volume maximorum
  % (5) deflu??ncia m??nima
  % (6) deflu??ncia m??xima
  % (7) indica????o energ??tica do reservat??rio no banco
  % (8) indica????o energ??tica do reservat??rio no arquivo
  %       0) acumula????o
  %       1) fio d'??gua
  for j= 1:nu
    % bogus
    fscanf(fid,'%s',1);
    % volume m??nimo
    uh{j}= set(uh{j},'vn',fscanf(fid,'%f',1));
    % volume m??ximo
    uh{j}= set(uh{j},'vm',fscanf(fid,'%f',1));
    % bogus
    fscanf(fid,'%s',1);
    % bogus
    fscanf(fid,'%s',1);
    % deflu??ncia m??xima
    dm= fscanf(fid,'%f',1);
    if dm > 1e10
      uh{j}= set(uh{j},'dm',Inf);
    else
      uh{j}= set(uh{j},'dm',dm);
    end
    % bogus
    fscanf(fid,'%s',1);
    % indica????o energ??tica do reservat??rio
    uh{j}= set(uh{j},'ie',fscanf(fid,'%i',1));
    clear dm;
  end

  % [POCV]
  %  polin??mios de cota de montante
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[POCV]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? polin??mios de cota de montante
  % (1) ??ndice do aproveitamento no estudo
  % (2) polin??mio de quarto grau
  for j= 1:nu
    % bogus
    fscanf(fid,'%s',1);
    % polin??mio de cota de montante
    M= fscanf(fid,'%f',[5 1]);
    poly= get(uh{j},'yc');
    poly= set(poly,'cf',M);
    uh{j}= set(uh{j},'yc',poly);
    clear poly M;
  end

  % [POAC]
  %  polin??mios de ??rea
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[POAC]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? polin??mios de ??rea
  % (1) ??ndice do aproveitamento no estudo
  % (2) polin??mio de quarto grau
  for j= 1:nu
    % bogus
    fscanf(fid,'%s',1);
    % polin??mio de ??rea
    M= fscanf(fid,'%f',[5 1]);
    poly= get(uh{j},'ya');
    poly= set(poly,'cf',M);
    uh{j}= set(uh{j},'ya',poly);
    clear poly M;
  end

  % [POCF]
  %  polin??mios de cota de jusante
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[POCF]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % l?? polin??mios de cota de jusante
  % (1) ??ndice do aproveitamento no estudo
  % (2) n??mero de polin??mios
  % (3) polin??mio de quarto grau
  % (4) cota de refer??ncia
  for j= 1:nu
    % bogus
    fscanf(fid,'%s',1);
    % polin??mio de cota de jusante
    np= fscanf(fid,'%i',1);
    yf= cell(np,2);
    for k= 1:np
      M= fscanf(fid,'%f',[5 1]);
      ref= fscanf(fid,'%f',1);
      yf{k,1}= ref;
      yf{k,2}= polinomio();
      yf{k,2}= set(yf{k,2},'cf',M);
      clear M ref;
    end
    uh{j}= set(uh{j},'yf',yf);
    clear yf;
  end

  % atualiza lista de usinas
  obj.si= set(obj.si,'uh',uh);

  % fecha arquivo
  fclose(fid);
end