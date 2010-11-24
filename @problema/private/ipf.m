% @problema/private/ipf.m defines a primal-dual filter line search
% interior-point algorithm.
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
function obj= ipf(obj)
  %% input data 
  %  inflows and load demand
  b= [obj.b; zeros(obj.mc,1); -obj.d];
  %  lower and upper bounds
  l= [obj.ls; obj.lq; obj.lv; obj.ly; obj.lz];
  u= [obj.us; obj.uq; obj.uv; obj.uy; obj.uz];
  %  Jacobian of Q(z)
  JQ= calcular_JQ(obj);
  %% algorithm parameters
  %  barrier
  mu= 0.0;                   % barrier parameters
  e= ones(obj.n,1);          % unit vector
  %  filter
  F= filtro();
  %  :inertia correction
  deltaw_last= 0;
  %  :backtracking
  eta_phi= 1e-04;
  gamma_alfa= 5e-02;
  gamma_theta= 1e-05;
  gamma_phi= 1e-05;
  s_phi= 2.3;
  s_theta= 1.1;
  %  :second-order correction
  kappasoc= 0.99;
  %  step size
  tau= 0.95;                 % border ratio
  alfa= 0.00;                % primal step
  alfad= 0.00;               % dual step
  %  convergence
  epstolp= 1e-5;             % tol. converg?ncia primal
  epstold= 1e-5;             % tol. converg?ncia dual
  %% initial solution
  ymax= 1e+5;
  %  primal variables
  x= mean([l'; u'])';
  %  slack variables
  s= max(u-x,10);
  t= max(x-l,10);
  %  box constraints dual variables
  w= max(abs(x),10);
  z= max(abs(x),10);
  %  equality constraints dual variables
  %    evaluate f(.) and g(.) on the initial solution
  f= calcular_f(obj,x);
  g= calcular_g(obj,x);
  %    compute first-order derivatives of f(.) and g(.)
  gf= calcular_df(obj,x);
  JP= calcular_JP(obj,x);
  Jg= calcular_Jg(obj,JP,JQ);
  y= (Jg*Jg')\(Jg*(-gf + z - w));
  if (norm(y,inf) > ymax) % check for degree of linear independence
    y= zeros(obj.m,1);
  end
  %% verbosity
  if (strcmp(obj.dv,'iter'))
    printc();
  end
  %% algorithm
  %  set up filter parameters
  theta= norm([g - b; x + s - u; x - t - l]);
  thetamax= 1e+04*max(1,norm(theta));
  thetamin= 1e-04*max(1,norm(theta));
  %  initialize filter
  F= limpar(F,thetamax);
  tic;
  for k= 1:obj.km
    % iterative bound relaxation
    for i= 1:obj.n
      % lower bounds
      if (t(i) < eps*mu)
        l(i)= l(i) - (eps^(3/4))*max(1,abs(l(i)));
      end
      % upper bounds
      if (s(i) < eps*mu)
        u(i)= u(i) + (eps^(3/4))*max(1,abs(u(i)));
      end
    end
    % complementarities
    sw= s'*w;
    tz= t'*z;
    SW= s.*w;
    TZ= t.*z;
    gamma= sw + tz;
    % preliminary matrix computations
    Jgt= Jg';
    Si= 1./s; % compute the inverse of S
    Ti= 1./t; % compute the inverse of T
    % compute Hessian of barrier parameters
    SiW= Si.*w;
    TiZ= Ti.*z;
    % compute barrier parameter
    mu= gamma/(obj.n*sqrt(obj.n));
    % compute residuals
    sigma= -(Jgt*y + gf + w - z);
    rho= -(g - b);
    rho_w= -(x + s - u);
    rho_z= -(l + t - x);
    ups_s= -(SW - mu*e);
    ups_t= -(TZ - mu*e);
    % check for convergence
    Ed= norm(sigma)/(1+norm(gf));
    Eg= abs(rho'*y + rho_w'*w - rho_z'*z + sigma'*x)/(1+abs(f));
    Ep= theta/(1+norm(b));
    % dual convergence
    if (Ed <= epstold)
      % primal convergence
      if (Ep <= epstolp)
        break;
      end
    end
    % compute Hessian of Lagrangian
    H= calcular_D(obj,x,y,SiW,TiZ);
    % compute coefficient matrix
    ctrlic= 0;
    deltac= 0;
    deltaw= 0;
    N= spalloc(obj.n+obj.m, obj.n+obj.m, nzmax(H) + nzmax(Jg)*2 + obj.m);
    while true
      N(1:obj.n, 1:obj.n)= H + deltaw*speye(obj.n);
      N(1:obj.n, obj.n+1:end)= Jgt;
      N(obj.n+1:end, 1:obj.n)= Jg;
      N(obj.n+1:end, obj.n+1:end)= -deltac*speye(obj.m);
      % compute factorization of coefficient matrix
      [L,D]= ldlsparse(N);
      % check if matrix inertia is (n,m,0)
      d= spdiags(D,0);
      inn= length(find(d > 0));
      inm= length(find(d < 0));
      inz= length(find(d == 0));
      if (inn ~= obj.n) || (inm ~= obj.m)
        % inertia correction
        %  (bottom-right block)
        if ~(inz)
          deltac= sqrt(eps)*mu^(1/4);
        else
          deltac= 0;
        end
        %  (Hessian of barrier Lagrangian function)
        if ~(ctrlic) % if this is the first correction
          if ~(deltaw_last)
            deltaw= 1e-04;
          else
            deltaw= max(1e-20, deltaw_last);
          end
        else % otherwise
          if ~(deltaw_last)
            deltaw= 100*deltaw;
          else
            deltaw= 8*deltaw;
          end
        end
        % increase inertia correction counter
        ctrlic= ctrlic + 1;
      else
        if (deltaw > 0)
          deltaw_last= deltaw;
        end
        break;
      end
    end
    L= L + speye(obj.n + obj.m);
    % compute search directions
    d= L'\((L*D)\[sigma-Si.*(ups_s-w.*rho_w)+Ti.*(ups_t-z.*rho_z); rho]);
    dx= d(1:obj.n);
    dy= d(obj.n+1:end);
    ds= rho_w - dx;
    dt= rho_z + dx;
    dw= Si.*(ups_s - w.*ds);
    dz= Ti.*(ups_t - z.*dt);
    % compute step size
    %  (primal step)
    aux= [1; -tau/min([ds./s; dt./t])];
    alfamax= min(aux(aux>0));
    %  (dual step)
    aux= [1; -tau/min([dw./w; dz./z])];
    alfad= min(aux(aux>0));
    % set backtracking line search parameters
    phi= f - mu*(sum(log(t)) + sum(log(s)));
    %  (control variables)
    ctrlfa= false;
    ctrlfr= false;
    ctrlsc= 0;
    soc= true;
    %  (barrier function gradient)
    gphidx= [gf; - mu*Si; - mu*Ti]' * [dx; ds; dt];
    %  (original solution)
    xt= x + alfamax*dx;
    st= s + alfamax*ds;
    tt= t + alfamax*dt;
    %  (minimum step size)
    alfamin= gamma_alfa*gamma_theta;
    % backtracking
    alfa= alfamax;
    j= 0;
    while true
      switchc= false;
      armijoc= false;
      % evaluate original solution
      gt= calcular_g(obj, xt);
      phit= calcular_f(obj,xt) - mu*(sum(log(t)) + sum(log(s)));
      thetat= norm([gt - b; xt + st - u; xt - tt - l]);
      % check for filter acceptability
      if ~filtrar(F,thetat,phit)
        % (fist case)
        if (theta <= thetamin)
          % check for switching condition
          %  (first part)
          if (gphidx < 0)
            % update minimum step size
            alfamin= gamma_alfa * ...
                       min([gamma_theta; 0; 0]);
            %  (second part)
            if (alfa*(-gphidx)^(s_phi) > theta^(s_theta))
              switchc= true;
              % check for Armijo condition
              if (phit < phi + eta_phi*alfa*gphidx)
                armijoc= true;
                if ctrlsc > 0
                  alfa= alfasoc;
                end
                break;
              end
            end
          end
        % (second case)
        else
          % update minimum step size
          if (gphidx < 0)
            alfamin= gamma_alfa * ...
                       min([gamma_theta; 0]);
          end
          % evaluate progress of the original solution
          if (thetat <= (1 - gamma_theta)*theta) || ...
               (phit <= phi - gamma_phi*theta)
            if (ctrlsc > 0)
              alfa= alfasoc;
            end
            break;
          end
        end
      end
      % check for need for second-order correction
      if (j < 1) && (thetat >= theta)
        if (ctrlsc > 0)
          if (thetat > kappasoc*thetasoc)
            % abort second-order correction
            soc= false;
          else
            thetasoc= thetat;
          end
        else
          thetasoc= theta;
          rhosc= rho;
          alfasoc= alfa;
        end
        % compute correction
        if (soc)
          rhosc= b - gt - alfasoc*rhosc;
          % compute corrected search direction
          d= L'\((L*D)\[sigma - Si.*ups_s + Ti.*ups_t; rhosc]);
          dxs= d(1:obj.n);
          dss= rho_w - dxs;
          dts= rho_z + dxs;
          % compute step size
          aux= [1; -tau/min([dss./s; dts./t])];
          alfasoc= min(aux(aux>0));
          % compute new corrected solution
          xt= x + alfasoc*dxs;
          st= s + alfasoc*dss;
          tt= t + alfasoc*dts;
          % increase second-order corrections counter
          ctrlsc= ctrlsc + 1;
          continue;
        end
      end
      % decrease step size
      alfa= alfa/2;
      if (alfa < alfamin)
        % if step size is too small, request feasibility restoration
        ctrlfr= true;
        break;
      else
        xt= x + alfa*dx;
        st= s + alfa*ds;
        tt= t + alfa*dt;
        j= j + 1;
      end
    end
    % check if feasibility restoration is required
    if (ctrlfr)
      % TODO: restaurar factibilidade
      error('Feasibility restoration required');
    else
      % compute new solution
      x= xt;
      s= st;
      t= tt;
      y= y + dy*alfa;
      w= w + dw*alfad;
      z= z + dz*alfad;
    end
    % check if filter augmentation is necessary
    if ~(switchc && armijoc)
      ctrlfa= true;
    else
      if ~((0 > gphidx) && ...
             (alfa*(-gphidx)^s_phi > theta^s_theta) && ...
             (phit < phi + eta_phi*alfa*gphidx))
        ctrlfa= true;
      end
    end
    % augment filter
    if (ctrlfa)
      F= adicionar(F, (1-gamma_theta)*theta, phi-gamma_phi*theta);
    end
    % verbosity
    if (strcmp(obj.dv,'iter'))
      printi();
    end
    % evaluate objective function and constraints
    f= calcular_f(obj,x);
    g= calcular_g(obj,x);
    % compute first-order derivatives of new solution
    gf= calcular_df(obj,x);
    JP= calcular_JP(obj,x);
    Jg= calcular_Jg(obj,JP,JQ);
    % update infeasibility measurement
    theta= norm([g-b; x+s-u; x-t-l]);
  end
  timing= toc;
  %% verbosity
  if (strcmp(obj.dv,'iter') || strcmp(obj.dv,'final'))
    printr();
  end
  %% store optimal solution
  %  unpack variables
  ms= obter_ms(obj,x);
  mq= obter_mq(obj,x);
  mv= obter_mv(obj,x);
  my= obter_my(obj,x);
  %  compute power generation
  ni= get(obj.si,'ni');
  ns= get(obj.si,'ns');
  nu= get(obj.si,'nu');
  uh= get(obj.si,'uh');
  %  (by hydro plant)
  mp= zeros(nu,ni);
  for j= 1:ni
    for i= 1:nu
      mp(i,j)= p(uh{i}, ms(i,j), mq(i,j), mv(i,j));
    end
  end
  %  (by subsystem)
  mpa= reshape(calcular_P(obj,x),ns,ni);
  mza= reshape(calcular_Q(obj,x),ns,ni);
  %  data update
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
    fprintf(1,'          ');
    %  (barrier)
    fprintf(1,'  BARRIER ');
    fprintf(1,'          ');
    %  (filter)
    fprintf(1,' FILTER LI');
    fprintf(1,'NE-SEARCH ');
    %  (step size)
    fprintf(1,'     STEP ');
    fprintf(1,'LENGTH    ');
    %  (infeasibility)
    fprintf(1,'    INFEAS');
    fprintf(1,'IBILITY   ');
    %  (convergence)
    fprintf(1,'      CONV');
    fprintf(1,'ERGENCE CR');
    fprintf(1,'ITERIA\n');
    %
    % second line
    fprintf(1,'   K ');
    fprintf(1,' FUNCTION ');
    fprintf(1,'  DLTYGAP ');
    fprintf(1,'    PARAM ');
    fprintf(1,'    GAMMA ');
    % (filter)
    fprintf(1,'  IC  AUGM');
    fprintf(1,'T SOC FRP ');
    % (step size)
    fprintf(1,'   PRIMAL ');
    fprintf(1,'     DUAL ');
    % (infeasibility)
    fprintf(1,'   PRIMAL ');
    fprintf(1,'     DUAL ');
    % (convergence)
    fprintf(1,'   PRIMAL ');
    fprintf(1,'     DUAL ');
    fprintf(1,'   CMPLTY\n');
  end
  %  iteration
  function printi()
    fprintf(1,' %3d  ', k);
    fprintf(1,'%5.2e  ', f);
    %  (gap)
    fprintf(1,'%5.2e  ', Eg);
    %  (barrier)
    fprintf(1,'%5.2e  ', mu);
    fprintf(1,'%5.2e  ', gamma);
    %  (inertia correction)
    if (ctrlic > 0)
      fprintf(1,'%3d    ',ctrlic);
    else
      fprintf(1,' No    ');
    end
    %  (filter augmentation)
    if (ctrlfa)
      fprintf(1,'Yes ');
    else
      fprintf(1,' No ');
    end
    %  (second-order correction)
    if (ctrlsc > 0)
      fprintf(1,'%3d ',ctrlsc);
    else
      fprintf(1,' No ');
    end
    %  (feasibility restoration phase)
    if (ctrlfr)
      fprintf(1,'Yes  ');
    else
      fprintf(1,' No  ');
    end
    %  (step size)
    fprintf(1,'%8.6f  ', alfa);
    fprintf(1,'%8.6f  ', alfad);
    %  (infeasibility)
    fprintf(1,'%5.2e  ', theta);
    fprintf(1,'%5.2e  ', norm(sigma));
    %  (convergence)
    fprintf(1,'%5.2e  ', Ep);
    fprintf(1,'%5.2e  ', Ed);
    fprintf(1,'%5.2e\n', 0);
  end
  %  footer
  function printr()
    fprintf(1,'\n Objective f-value: %.2e\n', f);
    fprintf(1,' Duality gap:       %.2e\n', Eg);
    fprintf(1,' Maximum violation: %.2e\n', norm([rho;rho_w;rho_z], inf));
    fprintf(1,'\n Elapsed time is %.1f seconds\n\n', timing);
  end
end