% @problema/private/ipb.m - Ponto interior primal-dual em bloco
%
% Copyright (c) 2009 Leonardo Martins. Todos os direitos reservados.
%
% UNICAMP
% Fac. de Engenharia Elétrica e de Computação
% Departamento de Engenharia de Sistemas
%
% IPB
function obj= ipb(obj)
  %% dados do problema
  %  matrizes constantes
  A= obj.A;
  B= obj.B;
  C= obj.C;
  JQ= calcular_JQ(obj);
  JQt= JQ';
  %  transpostas
  At= A';
  Bt= B';
  Ct= C';
  %  limites
  xup= [obj.us; obj.uq; obj.uv];
  yup= obj.uy;
  zup= obj.uz;
  xlo= [obj.ls; obj.lq; obj.lv];
  ylo= obj.ly;
  zlo= obj.lz;
  %% parâmetros do algoritmo
  %  barreira
  mu= 0.0;                   %#ok<NASGU>
  ex= ones(obj.nx,1);        %#ok<NASGU>
  ey= ones(obj.ny,1);        %#ok<NASGU>
  ez= ones(obj.nz,1);        %#ok<NASGU>
  %  centralidade
  epsilon= 1.0;
  %  tamanho do passo
  tau= 0.95;                 %#ok<NASGU>
  ap= 0.0;                   %#ok<NASGU>
  ad= 0.0;                   %#ok<NASGU>
  %  convergência
  beta_p= 1e-5;
  beta_d= 1e-3;
  %% calcula solução inicial
  %  (primal)
  x= mean([xup'; xlo'])';
  y= mean([yup'; ylo'])';
  z= mean([zup'; zlo'])';
  %  (dual)
  la= zeros(obj.ma,1);
  lb= zeros(obj.mb,1);
  lc= zeros(obj.mc,1);
  %  (folgas primais)
  sx= max(abs(xup-x),2*10e3);
  sy= max(abs(yup-y),2*10e3);
  sz= max(abs(zup-z),2*10e3);
  tx= max(abs(x-xlo),2*10e3);
  ty= max(abs(y-ylo),2*10e3);
  tz= max(abs(z-zlo),2*10e3);
  %  (folgas duais)
  wx= max(abs(x),2*10e3);
  wy= max(abs(y),2*10e3);
  wz= max(abs(z),2*10e3);
  ux= wx;
  uy= wy;
  uz= wz;
  %% profiling
  obj.pf= inicializar(obj.pf, obj.km);
  pf_ad= get(obj.pf,'ad');
  pf_ap= get(obj.pf,'ap');
  pf_cg= get(obj.pf,'cg');
  pf_cs= get(obj.pf,'cs');
  pf_cw= get(obj.pf,'cw');
  pf_cy= get(obj.pf,'cy');
  pf_cz= get(obj.pf,'cz');
  pf_f= get(obj.pf,'f');
  pf_ga= get(obj.pf,'ga');
  pf_mu= get(obj.pf,'mu');
  pf_ry= get(obj.pf,'ry');
  pf_si= get(obj.pf,'si');
  %% verbosidade
  if (strcmp(obj.dv,'iter'))
    printc();
  end
  %% algoritmo pontos interiores primal-dual
  tic;
  for k= 1:obj.km
    % cálculos preliminares
    u= [x;y;z];
    f= calcular_f(obj,u);                  % f(z)
    gf= calcular_df(obj,u);                % gradiente de f(u)
    gfz= obter_vz(obj,gf);                 % gradiente de f(z)
    Hfz= obter_Dz(obj,calcular_Hf(obj,u)); % Hessiana de f(z)
    Ax= calcular_Ax(obj,u);
    By= calcular_By(obj,u);
    Cy= calcular_Cy(obj,u);
    Px= calcular_P(obj,u);                 % P(x)
    Qz= calcular_Q(obj,u);                 % Q(z)
    JP= calcular_JP(obj,u);                % Jacobiana de P(x)
    JPt= JP';
    HP= calcular_HP(obj,u,[la;lc;lb]);     % Hessiana de P(x)
    Six= 1./sx;                            % inversa de Sx
    Siy= 1./sy;                            % inversa de Sy
    Siz= 1./sz;                            % inversa de Sz
    Tix= 1./tx;                            % inversa de Tx
    Tiy= 1./ty;                            % inversa de Ty
    Tiz= 1./tz;                            % inversa de Tz
    % cálculo do parâmetro de barreira
    gamma= sx'*wx + sy'*wy + sz'*wz + tx'*ux + ty'*uy + tz'*uz;
    mu= gamma/(2*obj.n*sqrt(2*obj.n));
    % cálculo dos resíduos
    sigma_x= JPt*lb - At*la - wx + ux;
    sigma_y= uy - Bt*lb - Ct*lc - wy;
    sigma_z= JQt*lb - gfz - wz + uz;
    rho_la= obj.b - Ax;
    rho_lb= Px + Qz - By - obj.d;
    rho_lc= -Cy;
    rho_wx= xup - x - sx;
    rho_wy= yup - y - sy;
    rho_wz= zup - z - sz;
    rho_ux= x - tx - xlo;
    rho_uy= y - ty - ylo;
    rho_uz= z - tz - zlo;
    upsilon_sx= epsilon*mu*ex - sx.*wx;
    upsilon_sy= epsilon*mu*ey - sy.*wy;
    upsilon_sz= epsilon*mu*ez - sz.*wz;
    upsilon_tx= epsilon*mu*ex - tx.*ux;
    upsilon_ty= epsilon*mu*ey - ty.*uy;
    upsilon_tz= epsilon*mu*ez - tz.*uz;
    % agregações
    lambda= [la; lc; lb];
    omega=  [wx; wy; wz];
    zeta=   [ux; uy; uz];
    sigma=  [sigma_x; sigma_y; sigma_z];
    rho_l=  [rho_la; rho_lc; rho_lb];
    rho_w=  [rho_wx; rho_wy; rho_wz];
    rho_u=  [rho_ux; rho_uy; rho_uz];
    % gap de dualidade
    gap= rho_l'*lambda + rho_w'*omega - rho_u'*zeta + sigma'*u;
    % profiling
    pf_cg(k)= abs(gap) / (1+abs(f));
    pf_cs(k)= norm(sigma) / (1+norm(gf));
    pf_cy(k)= norm(rho_l) / (1+norm([obj.b;-obj.d;zeros(obj.mc,1)]));
    pf_cw(k)= norm(rho_w) / norm([xup; yup; zup]);
    pf_cz(k)= norm(rho_u) / norm([xlo; ylo; zlo]);
    pf_f(k) = f;
    pf_ga(k)= gamma;
    pf_mu(k)= mu;
    pf_ry(k)= norm(rho_l);
    pf_si(k)= norm(sigma);
    % verifica convergência
    % dual
    if (pf_cs(k)) <= beta_d
      if (pf_cg(k)) <= beta_d
        % primal
        if (pf_cy(k)) <= beta_p
          if (pf_cw(k)) <= beta_p
            if (pf_cz(k)) <= beta_p
              break;
            end
          end
        end
      end
    end
    % solução do sistema de equações normais
    %  (cálculos preliminares)
    Dx= calcular_Dx(obj, HP, Six.*wx, Tix.*ux);
    Dy= calcular_Dy(obj, Siy.*wy, Tiy.*uy);
    Dz= calcular_Dz(obj, Hfz, Siz.*wz, Tiz.*uz);
    cx= Six.*(upsilon_sx - wx.*rho_wx) - Tix.*(upsilon_tx - ux.*rho_ux);
    cy= Siy.*(upsilon_sy - wy.*rho_wy) - Tiy.*(upsilon_ty - uy.*rho_uy);
    cz= Siz.*(upsilon_sz - wz.*rho_wz) - Tiz.*(upsilon_tz - uz.*rho_uz);
    %  (inversas)
    Dix= inverter_Dx(obj,Dx);
    Diy= inverter_Dy(obj,Dy);
    Diz= inverter_Dz(obj,Dz);
    %  (atalhos)
    scx= sigma_x - cx;
    scy= sigma_y - cy;
    scz= sigma_z - cz;
    ADix= A*Dix;
    CDiy= C*Diy;
    JPDix= JP*Dix;
    BDiy= B*Diy;
    ADixAt= ADix*At;
    CDiyCt= CDiy*Ct;
    JPDixAt= JPDix*At;
    BDiyCt= BDiy*Ct;
    JQDiz= JQ*Diz;
    %  (matriz de coeficientes do cálculo de dlb)
    X= JPDixAt*(ADixAt\(ADix*JPt));
    Y= BDiyCt*(CDiyCt\(CDiy*Bt));
    Chi= JPDix*JPt + BDiy*Bt + JQDiz*JQt - X - Y;
    % lado direito do cálculo de dlb
    psi= JPDixAt*(ADixAt\(ADix*scx - rho_la)) ...
          - BDiyCt*(CDiyCt\(CDiy*scy - rho_lc)) ...
          - JPDix*scx + BDiy*scy - JQDiz*scz - rho_lb;
    %  (direções duais)
    dlb= Chi\psi;
    dla= ADixAt\(ADix*(scx + JPt*dlb) - rho_la);
    dlc= CDiyCt\(CDiy*(scy - Bt*dlb) - rho_lc);
    % cálculo das direções de busca
    %  (primais)
    dx= Dix*(scx - At*dla + JPt*dlb);
    dy= Diy*(scy - Bt*dlb - Ct*dlc);
    dz= Diz*(scz + JQt*dlb);
    %  (folgas primais)
    dsx= rho_wx - dx;
    dsy= rho_wy - dy;
    dsz= rho_wz - dz;
    dtx= rho_ux + dx;
    dty= rho_uy + dy;
    dtz= rho_uz + dz;
    %  (folgas duais)
    dwx= Six.*(upsilon_sx - wx.*dsx);
    dwy= Siy.*(upsilon_sy - wy.*dsy);
    dwz= Siz.*(upsilon_sz - wz.*dsz);
    dux= Tix.*(upsilon_tx - ux.*dtx);
    duy= Tiy.*(upsilon_ty - uy.*dty);
    duz= Tiz.*(upsilon_tz - uz.*dtz);
    % cálculo do tamanho do passo
    s=  [sx; sy; sz];
    t=  [tx; ty; tz];
    ds= [dsx; dsy; dsz];
    dt= [dtx; dty; dtz];
    dw= [dwx; dwy; dwz];
    du= [dux; duy; duz];
    %  (primal)
    aux= [1; -tau/min([ds./s; dt./t])];
    ap= min(aux(find(aux > 0)));
    %  (dual)
    aux= [1; -tau/min([dw./omega; du./zeta])];
    ad= min(aux(find(aux > 0)));
    % profiling
    pf_ad(k)= ad;
    pf_ap(k)= ap;
    % verbosidade
    if (strcmp(obj.dv,'iter'))
      printi();
    end
    % escolhe tamanho do passo
    alpha= min([ap;ad]);
    % cálculo da nova solução
    x= x + dx*alpha;
    y= y + dy*alpha;
    z= z + dz*alpha;
    sx= sx + dsx*alpha;
    sy= sy + dsy*alpha;
    sz= sz + dsz*alpha;
    tx= tx + dtx*alpha;
    ty= ty + dty*alpha;
    tz= tz + dtz*alpha;
    la= la + dla*alpha;
    lb= lb + dlb*alpha;
    lc= lc + dlc*alpha;
    wx= wx + dwx*alpha;
    wy= wy + dwy*alpha;
    wz= wz + dwz*alpha;
    ux= ux + dux*alpha;
    uy= uy + duy*alpha;
    uz= uz + duz*alpha;
  end
  %% profiling
  obj.pf= set(obj.pf,'k',k);
  obj.pf= set(obj.pf,'t',toc);
  if (k < obj.km)
    obj.pf= set(obj.pf, 'ad', pf_ad(1:k));
    obj.pf= set(obj.pf, 'ap', pf_ap(1:k));
    obj.pf= set(obj.pf, 'f',  pf_f(1:k));
    obj.pf= set(obj.pf, 'ga', pf_ga(1:k));
    obj.pf= set(obj.pf, 'mu', pf_mu(1:k));
    obj.pf= set(obj.pf, 'ry', pf_ry(1:k));
    obj.pf= set(obj.pf, 'si', pf_si(1:k));
  end
  %% verbosidade
  if (strcmp(obj.dv,'iter') || strcmp(obj.dv,'final'))
    printr();
  end
  %% desempacota solução
  ms= obter_ms(obj,u);
  mq= obter_mq(obj,u);
  mv= obter_mv(obj,u);
  my= obter_my(obj,u);
  %% calcula a geração hidrelétrica
  %  por usina
  ni= get(obj.si,'ni');
  ns= get(obj.si,'ns');
  nu= get(obj.si,'nu');
  uh= get(obj.si,'uh');
  mp= zeros(nu,ni);
  for j= 1:ni
    for i= 1:nu
      mp(i,j)= p(uh{i}, ms(i,j), mq(i,j), mv(i,j));
    end
  end
  %  por subsistema
  mpa= reshape(calcular_P(obj,u),ns,ni);
  mza= reshape(calcular_Q(obj,u),ns,ni);
  %% elabora despacho
  obj.dp= set(obj.dp,'ms',ms);
  obj.dp= set(obj.dp,'mq',mq);
  obj.dp= set(obj.dp,'mv',mv);
  obj.dp= set(obj.dp,'my',my);
  obj.dp= set(obj.dp,'mz',mza);
  obj.dp= set(obj.dp,'mp',mp);
  obj.dp= set(obj.dp,'ma',mpa);
  %% sub-funções verbosidade
  %  cabeçalho
  function printc()
    fprintf(1,'\n   K ');
    fprintf(1,'     F(U) ');
    fprintf(1,'   BPARAM ');
    fprintf(1,'    GAMMA ');
    fprintf(1,'    PSTEP ');
    fprintf(1,'    DSTEP ');
    fprintf(1,' PINFBLTY ');
    fprintf(1,' DINFBLTY ');
    fprintf(1,'    CONVS ');
    fprintf(1,'  CONVGAP ');
    fprintf(1,'    CONVY ');
    fprintf(1,'    CONVW ');
    fprintf(1,'    CONVZ ');
    fprintf(1,'  CMPLMIN ');
    fprintf(1,'  CMPLMED\n');
  end
  %  iteração
  function printi()
    compl= [sx.*wx; sy.*wy; sz.*wz; tx.*ux; ty.*uy; tz.*uz];
    compl= compl/max(compl);
    fprintf(1,' %3d  ', k);
    fprintf(1,'%5.2e  ', f);
    fprintf(1,'%5.2e  ', mu);
    fprintf(1,'%5.2e  ', pf_ga(k));
    fprintf(1,'%8.6f', pf_ap(k));
    if (pf_ap(k) <= pf_ad(k))
      fprintf(1,'* ');
    else
      fprintf(1,'  ');
    end
    fprintf(1,'%8.6f', pf_ad(k));
    if (pf_ad(k) <= pf_ap(k))
      fprintf(1,'* ');
    else
      fprintf(1,'  ');
    end
    fprintf(1,'%5.2e  ', pf_ry(k));
    fprintf(1,'%5.2e  ', pf_si(k));
    fprintf(1,'%5.2e  ', pf_cs(k));
    fprintf(1,'%5.2e  ', pf_cg(k));
    fprintf(1,'%5.2e  ', pf_cy(k));
    fprintf(1,'%5.2e  ', pf_cw(k));
    fprintf(1,'%5.2e  ', pf_cz(k));
    fprintf(1,'%8.5f  ', min(compl));
    fprintf(1,'%8.5f\n', mean(compl));
  end
  %  rodapé
  function printr()
    fprintf(1,'\n Objective f-value: %.2e\n', pf_f(k));
    fprintf(1,' Duality gap:       %.2e\n', pf_cg(k));
    fprintf(1,' Maximum violation: %.2e\n', max(abs([rho_l;rho_w;rho_u])));
    fprintf(1,'\n Elapsed time is %.1f seconds\n\n', get(obj.pf,'t'));
  end
end
