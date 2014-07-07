% @problema/private/ipbf.m defines a primal-dual filter line search
% interior-point algorithm with block-computation of search directions.
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
function obj= ipbf(obj)
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
  %% par??metros do algoritmo
  %  barreira
  mu= 0.0;
  ex= ones(obj.nx,1);
  ey= ones(obj.ny,1);
  ez= ones(obj.nz,1);
  %  centralidade
  epsilon= 1.0;
  %  converg??ncia
  epstolp= 1e-5;
  epstold= 1e-3;
  %% calcula solu????o inicial
  lmax= 1e+5;
  kappa_1= 1e-1;
  kappa_2= 1e-1;
  %  (primal)
  pxlo= min(kappa_1*max(ex,abs(xlo)), kappa_2*(xup-xlo));
  pylo= min(kappa_1*max(ey,abs(ylo)), kappa_2*(yup-ylo));
  pzlo= min(kappa_1*max(ez,abs(zlo)), kappa_2*(zup-zlo));
  pxup= min(kappa_1*max(ex,abs(xup)), kappa_2*(xup-xlo));
  pyup= min(kappa_1*max(ey,abs(yup)), kappa_2*(yup-ylo));
  pzup= min(kappa_1*max(ez,abs(zup)), kappa_2*(zup-zlo));
  x= mean([(xlo+pxlo)'; (xup-pxup)'])';
  y= mean([(ylo+pylo)'; (yup-pyup)'])';
  z= mean([(zlo+pzlo)'; (zup-pzup)'])';
  %  (dual/canaliza????o)
  wx= max(abs(x),2*10e+3);
  wy= max(abs(y),2*10e+3);
  wz= max(abs(z),2*10e+3);
  ux= max(abs(x),2*10e+3);
  uy= max(abs(y),2*10e+3);
  uz= max(abs(z),2*10e+3);
  %  (dual/restri????es de igualdade)
  df= calcular_df(obj,[x;y;z]);
  JP= calcular_JP(obj,[x;y;z]);
  Jg= calcular_Jg(obj,JP,JQ);
  l= (Jg*Jg')\(Jg*(-df + [ux;uy;uz] - [wx;wy;wz]));
  la= obter_vlambda_a(obj,l);
  lb= obter_vlambda_b(obj,l);
  lc= obter_vlambda_c(obj,l);
  if norm(la,inf) > lmax
    la= zeros(obj.ma,1);
  end
  if norm(lb,inf) > lmax
    lb= zeros(obj.mb,1);
  end
  if norm(lc,inf) > lmax
    lc= zeros(obj.mc,1);
  end
  %% profiling
  obj.pf= inicializar(obj.pf, obj.km);
  pf_ad= get(obj.pf,'ad');
  pf_ap= get(obj.pf,'ap');
  pf_cg= get(obj.pf,'cg');
  pf_cs= get(obj.pf,'cs');
  pf_cy= get(obj.pf,'cy');
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
    % c??lculo das folgas
    sx= xup - x;
    sy= yup - y;
    sz= zup - z;
    tx= x - xlo;
    ty= y - ylo;
    tz= z - zlo;
    % c??lculos preliminares
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
    % c??lculo do par??metro de barreira
    gamma= sx'*wx + sy'*wy + sz'*wz + tx'*ux + ty'*uy + tz'*uz;
    mu= gamma/(2*obj.n*sqrt(2*obj.n));
    % c??lculo dos res??duos
    sigma_x= JPt*lb - At*la - wx + ux;
    sigma_y= uy - Bt*lb - Ct*lc - wy;
    sigma_z= JQt*lb - gfz - wz + uz;
    rho_la= obj.b - Ax;
    rho_lb= Px + Qz - By - obj.d;
    rho_lc= -Cy;
    upsilon_sx= epsilon*mu*ex - sx.*wx;
    upsilon_sy= epsilon*mu*ey - sy.*wy;
    upsilon_sz= epsilon*mu*ez - sz.*wz;
    upsilon_tx= epsilon*mu*ex - tx.*ux;
    upsilon_ty= epsilon*mu*ey - ty.*uy;
    upsilon_tz= epsilon*mu*ez - tz.*uz;
    % agrega????es
    lambda= [la; lc; lb];
    omega=  [wx; wy; wz];
    zeta=   [ux; uy; uz];
    sigma=  [sigma_x; sigma_y; sigma_z];
    rho_l=  [rho_la; rho_lc; rho_lb];
    % gap de dualidade
    gap= rho_l'*lambda + sigma'*u;
    % profiling
    pf_cg(k)= abs(gap) / (1+abs(f));
    pf_cs(k)= norm(sigma) / (1+norm(gf));
    pf_cy(k)= norm(rho_l) / (1+norm([obj.b;-obj.d;zeros(obj.mc,1)]));
    pf_f(k) = f;
    pf_ga(k)= gamma;
    pf_mu(k)= mu;
    pf_ry(k)= norm(rho_l);
    pf_si(k)= norm(sigma);
    % verifica converg??ncia
    % dual
    if (pf_cs(k)) <= epstold
      if (pf_cg(k)) <= epstold
        % primal
        if (pf_cy(k)) <= epstolp
          break;
        end
      end
    end
    % solu????o do sistema de equa????es normais
    %  (c??lculos preliminares)
    Dx= calcular_Dx(obj, HP, Six.*wx, Tix.*ux);
    Dy= calcular_Dy(obj, Siy.*wy, Tiy.*uy);
    Dz= calcular_Dz(obj, Hfz, Siz.*wz, Tiz.*uz);
    cx= Six.*upsilon_sx - Tix.*upsilon_tx;
    cy= Siy.*upsilon_sy - Tiy.*upsilon_ty;
    cz= Siz.*upsilon_sz - Tiz.*upsilon_tz;
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
    %  (matriz de coeficientes do c??lculo de dlb)
    X= JPDixAt*(ADixAt\(ADix*JPt));
    Y= BDiyCt*(CDiyCt\(CDiy*Bt));
    Chi= JPDix*JPt + BDiy*Bt + JQDiz*JQt - X - Y;
    % lado direito do c??lculo de dlb
    psi= JPDixAt*(ADixAt\(ADix*scx - rho_la)) ...
          - BDiyCt*(CDiyCt\(CDiy*scy - rho_lc)) ...
          - JPDix*scx + BDiy*scy - JQDiz*scz - rho_lb;
    %  (dire????es duais)
    dlb= Chi\psi;
    dla= ADixAt\(ADix*(scx + JPt*dlb) - rho_la);
    dlc= CDiyCt\(CDiy*(scy - Bt*dlb) - rho_lc);
    % c??lculo das dire????es de busca
    %  (primais)
    dx= Dix*(scx - At*dla + JPt*dlb);
    dy= Diy*(scy - Bt*dlb - Ct*dlc);
    dz= Diz*(scz + JQt*dlb);
    %  (folgas duais)
    dwx= Six.*(upsilon_sx + wx.*dx);
    dwy= Siy.*(upsilon_sy + wy.*dy);
    dwz= Siz.*(upsilon_sz + wz.*dz);
    dux= Tix.*(upsilon_tx - ux.*dx);
    duy= Tiy.*(upsilon_ty - uy.*dy);
    duz= Tiz.*(upsilon_tz - uz.*dz);
    % c??lculo do tamanho do passo
    %  (primal)
    aux= [1; -0.95/min([-dx./sx; ...
                       -dy./sy; ...
                       -dz./sz; ...
                        dx./tx; ...
                        dy./ty; ...
                        dz./tz])];
    ap= min(aux(aux > 0));
    %  (dual)
    aux= [1; -0.95/min([[dwx;dwy;dwz]./omega; [dux;duy;duz]./zeta])];
    ad= min(aux(aux > 0));
    % profiling
    pf_ad(k)= ad;
    pf_ap(k)= ap;
    % verbosidade
    if (strcmp(obj.dv,'iter'))
      printi();
    end
    % escolhe tamanho do passo
    alpha= min([ap;ad]);
    % c??lculo da nova solu????o
    x= x + dx*alpha;
    y= y + dy*alpha;
    z= z + dz*alpha;
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
  %% unpack optimal solution
  ms= obter_ms(obj,u);
  mq= obter_mq(obj,u);
  mv= obter_mv(obj,u);
  my= obter_my(obj,u);
  %% calcula a gera????o hidrel??trica
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
  %  per 
  mpa= reshape(calcular_P(obj,u),ns,ni);
  mza= reshape(calcular_Q(obj,u),ns,ni);
  %% pack solution
  obj.dp= set(obj.dp,'ms',ms);
  obj.dp= set(obj.dp,'mq',mq);
  obj.dp= set(obj.dp,'mv',mv);
  obj.dp= set(obj.dp,'my',my);
  obj.dp= set(obj.dp,'mz',mza);
  obj.dp= set(obj.dp,'mp',mp);
  obj.dp= set(obj.dp,'ma',mpa);
  %% verbosity subfunctions
  %  header
  function printc()
    % first line
    fprintf(1,'\n     ');
    fprintf(1,'      OBJ ');
    fprintf(1,'  BARRIER ');
    fprintf(1,'          ');
    fprintf(1,'   COMPLEM');
    fprintf(1,'ENTARITY  ');
    fprintf(1,'     STEP ');
    fprintf(1,'LENGTH    ');
    fprintf(1,'    INFEAS');
    fprintf(1,'IBILITY   ');
    fprintf(1,'      CONV');
    fprintf(1,'ERGENCE   ');
    fprintf(1,'  DUALITY\n');
    % second line
    fprintf(1,'   K ');
    fprintf(1,' FUNCTION ');
    fprintf(1,'    PARAM ');
    fprintf(1,'    GAMMA ');
    % (complementarity)
    fprintf(1,'  MINIMUM ');
    fprintf(1,'  AVERAGE ');
    % (step)
    fprintf(1,'   PRIMAL ');
    fprintf(1,'     DUAL ');
    % (infeasibility)
    fprintf(1,'   PRIMAL ');
    fprintf(1,'     DUAL ');
    % (convergence)
    fprintf(1,'   PRIMAL ');
    fprintf(1,'     DUAL ');
    fprintf(1,'      GAP\n');
  end
  %  iteration
  function printi()
    compl= [sx.*wx; sy.*wy; sz.*wz; tx.*ux; ty.*uy; tz.*uz];
    compl= compl/max(compl);
    fprintf(1,' %3d  ', k);
    fprintf(1,'%5.2e  ', f);
    fprintf(1,'%5.2e  ', mu);
    fprintf(1,'%5.2e  ', pf_ga(k));
    fprintf(1,'%8.5f  ', min(compl));
    fprintf(1,'%8.5f  ', mean(compl));
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
    fprintf(1,'%5.2e  ', pf_cy(k));
    fprintf(1,'%5.2e  ', pf_cs(k));
    fprintf(1,'%5.2e\n', pf_cg(k));
  end
  %  rodap??
  function printr()
    fprintf(1,'\n Objective f-value: %.2e\n', pf_f(k));
    fprintf(1,' Duality gap:       %.2e\n', pf_cg(k));
    fprintf(1,' Maximum violation: %.2e\n', norm(rho_l,inf));
    fprintf(1,'\n Elapsed time is %.1f seconds\n\n', get(obj.pf,'t'));
  end
end
