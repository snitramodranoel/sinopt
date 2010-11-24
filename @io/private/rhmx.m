% @io/private/rhmx.m writes RHMX files.
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
function rhmx(obj,arquivo)
  % abre arquivo
  fid= fopen(arquivo,'w+');
  % dados de dimens??o do sistema
  ni= get(obj.si,'ni');
  nl= get(obj.si,'nl');
  ns= get(obj.si,'ns');
  nu= get(obj.si,'nu');
  % dados do problema
  af= get(obj.si,'af');
  ai= get(obj.si,'ai');
  vd= reshape(get(obj.pb,'d'),ns,ni);
  ls= reshape(get(obj.pb,'ls'),nu,ni);
  mi= get(obj.si,'mi');
  nq= get(obj.si,'nq');
  uh= get(obj.si,'uh');
  uq= reshape(get(obj.pb,'uq'),nu,ni);
  us= reshape(get(obj.pb,'us'),nu,ni);
  vi= get(obj.si,'vi');
  % despacho
  dp= get(obj.pb,'dp');
  ma= get(dp,'ma');
  ms= get(dp,'ms');
  mq= get(dp,'mq');
  mv= get(dp,'mv');
  my= get(dp,'my');
  mz= get(dp,'mz');
  mp= get(dp,'mp');

  % monta lista de datas
  dma= cell(ni+1,1);
  k= datenum(ai,(mi-1),1);
  for j= 1:ni+1
    dma{j} = datestr(k,'dd/mm/yyyy');
    k = datenum(ai,(mi+j-1),1);
  end

  % header
  fprintf(fid,'// HYDRA\n');
  fprintf(fid,'// Resultados da otimiza????o\n');

  % [NUNI]
  % usinas e intervalos
  fprintf(fid,'\n[NUNI]\n');
  fprintf(fid,' %d %d\n',nu,ni);

  % [MIAI]
  % in??cio do horizonte
  fprintf(fid,'\n[MIAI]\n');
  fprintf(fid,' %d %d\n',mi,ai);

  % [VOLA]
  % volume armazenado
  fprintf(fid,'\n[VOLA]\n');
  for j= 1:ni+1
    fprintf(fid,'%s ',dma{j});
    for k= 1:nu
      if (j>1)
        fprintf(fid,'%8.2f ',ms(k,j-1));
      else
        fprintf(fid,'%8.2f ',vi(k));
      end
    end
    fprintf(fid,'\n');
  end

  % [VOLU]
  % volume ??til
  fprintf(fid,'\n[VOLU]\n');
  for j= 1:ni+1
    fprintf(fid,'%s ',dma{j});
    for k= 1:nu
      ie= get(uh{k},'ie');
      vm= get(uh{k},'vm');
      vn= get(uh{k},'vn');
      switch ie
        case 0
          if (j>1)
            fprintf(fid,'%8.2f ', ((ms(k,j-1)-vn)/(vm-vn))*100);
          else
            fprintf(fid,'%8.2f ', ((vi(k)-vn)/(vm-vn))*100);
          end
        case 1
          fprintf(fid,'%8.2f ', 0);
      end
    end
    fprintf(fid,'\n');
  end
  clear vm;
  clear vn;

  % [DFLU]
  % vaz??o deflu??da total
  fprintf(fid,'\n[DFLU]\n');
  for j= 1:ni
    fprintf(fid,'%s ',dma{j+1});
    for k= 1:nu
      fprintf(fid,'%8.2f ',mq(k,j)+mv(k,j));
    end
    fprintf(fid,'\n');
  end

  % [TURB]
  % vaz??o turbinada total
  fprintf(fid,'\n[TURB]\n');
  for j= 1:ni
    fprintf(fid,'%s ',dma{j+1});
    for k= 1:nu
      fprintf(fid,'%8.2f ',mq(k,j));
    end
    fprintf(fid,'\n');
  end

  % [VINC]
  % vaz??o incremental
  fprintf(fid,'\n[VINC]\n');
  for j= 1:ni
    fprintf(fid,'%s ',dma{j+1});
    for k= 1:nu
      fprintf(fid,'%8.2f ',af(k,j));
    end
    fprintf(fid,'\n');
  end

  % [VMOT]
  % vaz??o de montante
  fprintf(fid,'\n[VMOT]\n');
  for j= 1:ni
    fprintf(fid,'%s ',dma{j+1});
    for k= 1:nu
      um= 0.0;
      im= get(uh{k},'im');
      for t= 1:length(im)
        um= um + mq(t,j) + mv(t,j);
      end
      fprintf(fid,'%8.2f ',um);
    end
    fprintf(fid,'\n');
  end
  clear im;
  clear um;

  % [QMAX]
  % turbinagem m??xima
  fprintf(fid,'\n[QMAX]\n');
  for j= 1:ni
    fprintf(fid,'%s ',dma{j+1});
    for k= 1:nu
      fprintf(fid,'%8.2f ',uq(k,j));
    end
    fprintf(fid,'\n');
  end

  % [VERT]
  % vaz??o vertida por usina e intervalo
  fprintf(fid,'\n[VERT]\n');
  for j= 1:ni
    fprintf(fid,'%s ',dma{j+1});
    for k= 1:nu
      if abs(mv(k,j)) < 1e-03
        fprintf(fid,'%8.2f ', 0);
      else
        fprintf(fid,'%8.2f ', mv(k,j));
      end
    end
    fprintf(fid,'\n');
  end

  % [GERH]
  % gera????o hidr??ulica por usina e intervalo
  fprintf(fid,'\n[GERH]\n');
  for j= 1:ni 
    fprintf(fid,'%s ',dma{j+1});
    for k= 1:nu
      fprintf(fid,'%8.2f ',mp(k,j));
    end
    fprintf(fid,'\n');
  end

  % [NMAQ]
  % n??mero de m??quinas em opera????o
  fprintf(fid,'\n[NMAQ]\n');
  for j= 1:ni
    fprintf(fid,'%s ',dma{j+1});
    for k= 1:nu
      fprintf(fid,'%5d    ',nq(k,j));
    end
    fprintf(fid,'\n');
  end

  % [RSYS]
  % (1) gera????o hidrel??trica total
  % (2) gera????o termel??trica total
  % (3) mercado atendido
  % (4) energia armazenada
  fprintf(fid,'\n[RSYS]\n');
  for j= 1:ni
    fprintf(fid,'%s ',dma{j+1});
    fprintf(fid,'%8.2f ',sum(mp(:,j)));
    fprintf(fid,'%8.2f ',sum(mz(:,j)));
    fprintf(fid,'%8.2f ',sum(vd(:,j)));
    % TODO: calcular energia armazenada
    fprintf(fid,'%8.2f ',0);
    fprintf(fid,'\n');
  end

  % [RSUB]
  % resultados de opera????o por sub-sistema
  % para cada subsistema:
  % (1) gera????o hidrel??trica        [MWm]
  % (2) gera????o termel??trica        [MWm]
  % (3) mercado de energia atendido [MWm]
  % (4) energia armazenada          [MWm]
  % (5) custo marginal de opera????o  [R$/MWh]
  % (6) custo total                 [R$]
  % (7) d??ficit                     [MWm]
  % e, ao final, 
  % (8) gera????o total de Itaipu,    [MWm]
  fprintf(fid,'\n[RSUB]\n');
  for j= 1:ni
    fprintf(fid,'%s ',dma{j+1});
    for k= 1:ns
      fprintf(fid,'%8.2f ',ma(k,j));
      fprintf(fid,'%8.2f ',mz(k,j));
      fprintf(fid,'%8.2f ',vd(k,j));
      % TODO: calcular energia armazenada
      fprintf(fid,'%8.2f ',0.0);
      % TODO: calcular custo marginal de opera????o
      fprintf(fid,'%8.2f ',0.0);
      % TODO: calcular custo total
      fprintf(fid,'%8.2f ',0.0);
      % TODO: calcular d??ficit  
      fprintf(fid,'%8.2f ',0.0);
    end
    % TODO: calcular gera????o total de Itaipu
    fprintf(fid,'%8.2f',0.0);
    fprintf(fid,'\n');
  end

  % [RINC]
  % resultado dos interc??mbios por conex??o
  % (1)  SECO->F2
  % (2)  F2->SECO
  % (3)  SECO->NE
  % (4)  NE->SECO
  % (5)  F->SECO
  % (6)  SECO->F
  % (7)  F->N
  % (8)  N->F
  % (9)  F->NE
  % (10) NE->F
  % (11) F2->S
  % (12) S->F2
  % (13) IT->SECO
  % (14) IT->F2
  fprintf(fid,'\n[RINC]\n');
  for j= 1:ni
    fprintf(fid,'%s ',dma{j+1});
    % TODO: mapear arcos redundantes
    for k= 1:nl
      fprintf(fid,'%8.2f ',my(k,j));
    end
    fprintf(fid,'\n');
  end

  % fecha arquivo
  fclose(fid);
end