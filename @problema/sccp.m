% @problema/sccp.m sequencial concave convex programming for qinopt problem.
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
function [x,y,z] = sccp(obj)
  % swap plants between ROR and regulation reservoir lists
  obj= swap(obj);

  % system dimensions
  nc= get(obj.si,'nc');
  ni= get(obj.si,'ni');
  nl= get(obj.si,'nl');
  np= get(obj.si,'np');
  nq= get(obj.si,'nq');
  nr= get(obj.si,'nr');
  ns= get(obj.si,'ns');
  nt= get(obj.si,'nt');
  nu= get(obj.si,'nu');
  % system data
  ut= get(obj.si,'ut');
  uh= get(obj.si,'uh');
  th= get(obj.si,'th');
  vi= get(obj.si,'vi');
  vf= get(obj.si,'vf');

  % variable-space dimensions
  obj.na= nr*(ni-1);
  obj.nq= nu*ni*np;
  obj.nv= nu*ni;
  obj.nx= obj.na + obj.nq + obj.nv;
  obj.ny= nl*np*ni;
  obj.nz= nt*np*ni;
  obj.n = obj.nx + obj.ny + obj.nz;
  % constraint-space dimensions
  obj.ma= nu*ni;
  obj.mb= ns*np*ni;
  obj.mc= nc*np*ni;
  obj.m = obj.ma + obj.mb + obj.mc;

  % scaling factors
  hsf = 1e-4;
  psf = 1e-7;
  
  % box constraints
  build_lb;
  build_ub;

  % hydro constraints
  b = [];
  build_b(hsf);
  A = [];
  build_A(hsf);
  
  % production coefficients
  P = []; Pc = [];
  build_P();
  dPc = sparse((1:obj.nx)', (1:obj.nx)', Pc, obj.nx, obj.nx, obj.nx);

  % cost coefficients
  Q = []; ql = []; qc = [];
  build_Q(psf);

  % power constraints
  d = []; B = []; C = []; I = []; G = [];
  build_d(psf);
  build_B(psf);
  build_C(psf);
  build_I(psf);
  build_G(psf);
  %build_R(psf);
  % check for data sanity
  obj= verificar(obj);
  
  % 
  % build elementar linear mappings
  %
  T1 = build_Tx(ones(obj.nx,1));
  IT1 = I * T1;

  build_J; % build Jacobian constant elements
  build_H; % build Hessian constant elements
  
  %
  % setup Ipopt
  %
  % set up callbacks
  funcs.objective= @(x) compute_f(x);
  funcs.constraints= @(x) compute_g(x);
  funcs.gradient= @(x) compute_df(x);
  funcs.jacobian= @(x) compute_Jg(x);
  funcs.jacobianstructure= @jacobianstructure;
  funcs.hessian= @(x,sigma,lambda) tril(compute_H(x,sigma,lambda));
  funcs.hessianstructure= @hessianstructure;
  % set up variable bounds
  options.lb= [lx; obj.ly; obj.lz];
  options.ub= [ux; obj.uy; obj.uz];
  % set up constraint bounds
  options.cl= [b; zeros(obj.mc,1); -d];
  options.cu= options.cl;
  % set up initial primal solution
  w0= mean([options.lb'; options.ub'])';
  % set up initial dual solution
  options.zl= max(abs(w0),10);
  options.zu= max(abs(w0),10);
  options.lambda= ones(obj.m,1);
  % set up solver options
  options.ipopt.bound_relax_factor= 1e-06;
  options.ipopt.constr_viol_tol= 1e-06;
  options.ipopt.linear_solver= 'mumps';
  options.ipopt.max_iter= obj.km;
  %options.ipopt.mu_strategy= 'adaptive';
  options.ipopt.print_level= obj.dv;
  options.ipopt.tol= 1e-06;
  
  options.ipopt.jac_c_constant = 'no';
  options.ipopt.hessian_constant = 'no';

  %
  % solve problem
  [w,~]= ipopt(w0,funcs,options);
  % compute solution

  x = extract_x(w);
  y = extrair_y(obj,w);
  z = extrair_z(obj,w);
  %%%%
  %%%% Build functions
  %%%%
  
  %
  % Objective function computation
  %
  function psi= compute_f(w)
    % unpack z variables
    wz= extrair_z(obj,w);
    % compute complementary thermal power generation costs
    psi= wz'*Q*wz + ql'*wz + qc'*ones(obj.nz,1);
  end

  %
  % Constraints computation
  %
  function g= compute_g(w)
    wx = extract_x(w);
    wy = extrair_y(obj,w);
    wz = extrair_z(obj,w);
    
    Tx = build_Tx(wx);
    
    g= [A*wx; ...
        C*wy; ...
        B*wy - I*Tx*(0.5*P*wx + Pc) - G*wz];
  end

  %
  % Objective function gradient computation
  %
  function df= compute_df(w)
    % unpack z variables
    wz= extrair_z(obj,w);
    df= [zeros(obj.nx+obj.ny, 1); 2*Q*wz + ql];
  end

  %
  % Jacobian constraint matrix computation
  %
  function Jg= compute_Jg(w)
    Tx = build_Tx(extract_x(w));
    Jg = obj.J;
    Jg(obj.ma+obj.mc+1:obj.m, 1:obj.nx)= -I*(Tx*P + T1*dPc);
  end

  %
  % Lagrangian Hessian matrix computation
  %
  function H= compute_H(~,sigma,lambda)
    Hg = sparse([], [], [], obj.nx, obj.nx, 0);
    for k = 1:obj.mb
      Hg = Hg + lambda(obj.ma+obj.mc+k) * diag(IT1(k,:));
    end
    [li, co, vl] = find(Hg*P);
    H= sparse([obj.Hf(:,1); li], ...
        [obj.Hf(:,2); co], ...
        [sigma * obj.Hf(:,3); -vl], ...
        obj.n, obj.n, length(obj.Hf(:,1)) + length(li));
  end

  % 
  % Jacobian matrix structure provision
  %
  function s= jacobianstructure()
    [rj,cj,vj]= find(obj.J);
    [rp,cp,vp] = find(I*T1*(P + dPc));
    %
    rp = rp + obj.ma + obj.mc;
    %
    rows = [rj; rp];
    cols = [cj; cp];
    values = [vj; -vp];
    s= sparse(rows, cols, values, obj.m, obj.n, length(rows));
  end

  %
  % Lagrangian Hessian matrix structure provision
  %
  function s= hessianstructure()
    s= tril(sparse([obj.Hf(:,1); obj.Hg(:,1)], ...
        [obj.Hf(:,2); obj.Hg(:,2)], ...
        [obj.Hf(:,3); obj.Hg(:,3)], ...
        obj.n, obj.n, length(obj.Hf(:,3)) + length(obj.Hg(:,3))));
  end
  
  %%%%
  %%%% Build functions
  %%%%

  %
  % Build matrix Q of fuel cost functions
  %
  function build_Q(sf)
    % memory allocation
    qq= zeros(obj.nz, 1);
    ql= zeros(obj.nz, 1);
    qc= zeros(obj.nz, 1);

    c = zeros(nt,3);
    for i = 1:nt
      cf = get(get(ut{i},'co'),'cf');
      c(i,1) = cf(3);
      c(i,2) = cf(2);
      c(i,3) = cf(1);
    end
  
    % build scaling factor matrix    
    k= 0;
    for j= 1:ni
      for i= 1:nt
        k= k+1;
        qq(k) = c(i,1) * th{1}(j) * sf;
        ql(k) = c(i,2) * th{1}(j) * sf;
        qc(k) = c(i,3) * th{1}(j) * sf;
      end
    end
    
    Q = sparse(1:obj.nz, 1:obj.nz, qq, obj.nz, obj.nz, obj.nz);
  end

  %
  % Build vector b of water inflows
  %
  function build_b(sf)
    % system data
    af= get(obj.si,'af');
    tv= get(obj.si,'tv');
    uc= get(obj.si,'uc');
    ur= get(obj.si,'ur');
    % system dimensions
    ti= get(obj.si,'ti');  
    % compute initial vector
    b= zeros(nu,ni);
    for k= 1:nu
      up= upstream(obj.si, k);
      for j= 1:ni
        b(k,j)= af(k,j);
        if (tv == 1)
          for i= 1:length(up)
            b(k,j)= b(k,j) - af(up(i),j);
          end
        end
      end
    end
    % compute consumptive use
    b= b - uc;
    % compute initial, final fixed reservoir states
    % only hydro plants with a reservoir
    for i= 1:nr
      b(ur(i),1) = b(ur(i),1) + vi(ur(i))*(ti(1)*1e-6)^(-1);
      b(ur(i),ni)= b(ur(i),ni) - vf(ur(i))*(ti(ni)*1e-6)^(-1);
    end
    % data packing
    b= reshape(b*sf, nu*ni, 1);
  end
  
  %
  % Build matrix A of reservoir dynamics equations
  %
  function build_A(sf)
    % system dimensions
    nj= get(obj.si,'nj');
    ti= get(obj.si,'ti');
    % build matrix A
    A = spalloc(obj.ma, obj.nx, 2*obj.na + ni*((nu+nj)*(np+1)));
    k = 1; % column control
    for j=1:ni
      for i=1:nu
        ror= get(uh{i},'ie');
        if ~ror
          if j < ni
            % storage
            lip = nu*(j-1) + i;
            A(lip,k) = (ti(j)*1e-6)^(-1) * sf;
            lin = nu*j + i;
            A(lin,k) = -(ti(j+1)*1e-6)^(-1) * sf;
            k = k + 1;
          end
        end
        % discharge
        lip = nu*(j-1) + i;
        A(lip,k) = 1 * sf;
        if (get(uh{i},'ij') > 0)
          lin = nu*(j-1) + get(uh{i},'ij'); 
          A(lin,k) = -1 * sf;
        end
        k = k + 1;
        % spillage
        lip = nu*(j-1) + i;
        A(lip,k) = 1 * sf;
        if (get(uh{i},'ij') > 0)
          lin = nu*(j-1) + get(uh{i},'ij'); 
          A(lin,k) = -1 * sf;
        end
        k = k + 1;
      end
    end
  end

  %
  % Build hydro production function matrix and vector coefficients 
  %
  function build_P()
    P = sparse([], [], [], obj.nx, obj.nx, 0);
    Ph = cell(nu*ni, 1);
    Phl = cell(nu*ni, 1);
    % compute matrix P and vector Pc of hydro production coefficients
    k = 1;
    for j = 1:ni
      for i = 1:nu
        pe= get(uh{i}, 'pe'); % efficiency coefficient
        ror= get(uh{i}, 'ie'); % reservoir status
        if nq(i,j) > 0
          zeta= 1;
        else
          zeta= 0;
        end
        cm = get(get(uh{i},'yc'), 'cf'); % forebay coefficients
        cp = get(get(uh{i},'yp'), 'cf'); % penstock loss coefficients
        % tailrace coefficients
        yf = get(uh{i},'yf');
        cj = get(yf{1,2},'cf');
        % build coefficient matrix blocks
        if ror
          li = [1; 1; 2];
          co = [1; 2; 1];
          vl = -pe * zeta * [2*(cj(2)+cp(2)); cj(2); cj(2)];
          Ph{k} = sparse(li, co, vl, 2, 2, 3);
          Phl{k} = pe * zeta * [cm(2)*vi(i) + cm(1) - cj(1) - cp(1); 0];
        else
          if j < ni
            li = [1; 2; 2; 2; 3];
            co = [2; 1; 2; 3; 2];
            vl = -pe * zeta * [-cm(2); -cm(2); 2*(cj(2)+cp(2)); cj(2); cj(2)];
            Ph{k} = sparse(li, co, vl, 3, 3, 5);
            Phl{k} = pe * zeta * [0; cm(1)-cj(1)-cp(1); 0];
          else
            li = [1; 1; 2];
            co = [1; 2; 1];
            vl = -pe * zeta * [2*(cj(2)+cp(2)); cj(2); cj(2)];
            Ph{k} = sparse(li, co, vl, 2, 2, 3);
            Phl{k} = pe * zeta * [cm(2)*vf(i) + cm(1) - cj(1) - cp(1); 0];
          end
        end
        k = k + 1;
      end
    end
    % build vector of linear coefficients
    Pc = vertcatlst(Phl, 1);
    % build matrix of quadratic coefficients
    P = blkdiaglst(Ph, 1);
  end

  %
  % Build hydro generation distribution matrix
  %
  function build_I(sf)
    % sum up number of bus-plant assignments
    nbc= 0;
    for i= 1:nu
      nbc= nbc + length(get(uh{i}, 'bc'));
    end
    % compute number of nonzero elements in the matrix
    nze= nbc * ni * np;
    % memory allocation
    li= zeros(nze,1);
    co= zeros(nze,1);
    vl= zeros(nze,1);
    % assign distribution factors to membership matrix elements
    k= 0;
    for l= 1:np
      for j= 1:ni
        for i= 1:nu
          bc= get(uh{i}, 'bc');
          df= get(uh{i}, 'df');
          for bus= 1:length(bc)
            k= k+1;
            li(k)= ns*(ni*(l-1) + (j-1)) + bc(bus); % row
            co(k)= nu*(ni*(l-1) + (j-1)) + i;       % column
            vl(k)= sf * th{l}(j) * df(bus);         % distribution factor
          end
        end
      end
    end
    % build sparse matrix
    I = sparse(li, co, vl, obj.mb, nu*ni*np);
  end

  %
  % Build thermal generation distribution matrix
  %
  function build_G(sf)
    % sum up number of bus-plant assignments
    nbc= 0;
    for t= 1:nt
      nbc= nbc + length(get(ut{t}, 'bc'));
    end
    % compute number of nonzero elements in the matrix
    nze= nbc * ni * np;
    % memory allocation
    li= zeros(nze,1);
    co= zeros(nze,1);
    vl= zeros(nze,1);
    % assign distribution factors to membership matrix elements
    k= 0;
    for l= 1:np
      for j= 1:ni
        for t= 1:nt
          bc= get(ut{t}, 'bc');
          df= get(ut{t}, 'df');
          for bus= 1:length(bc)
            k= k+1;
            li(k)= ns*(ni*(l-1) + (j-1)) + bc(bus); % row
            co(k)= nt*(ni*(l-1) + (j-1)) + t;       % column
            vl(k)= sf * th{l}(j) * df(bus);         % distribution factor
          end
        end
      end
    end
    % build sparse matrix
    G = sparse(li, co, vl, obj.mb, obj.nz);
  end

  %
  % Build load vector
  %
  function build_d(sf)
    % load data
    dc= get(obj.si,'dc');
    gp= get(obj.si,'gp');
    % memory allocation
    d= zeros(obj.mb,1);  
    % compute load (in MWh)
    i= 0;
    for l= 1:np
      for j= 1:ni
        for k= 1:ns
          i= i+1;
          % load equals gross load minus fixed generation
          d(i)= sf * th{l}(j) * (dc{l}(k,j) - gp{l}(k,j));
        end
      end
    end
  end

  %
  % Build transmission network bus-line incidence matrix
  %
  function build_B(sf)
    % build network topology submatrix
    obj= construir_N(obj);
    % memory allocation
    B= spalloc(obj.mb, obj.ny, 2*obj.ny);
    % build matrix
    i= 1;
    k= 1;
    for l= 1:np
      for j= 1:ni
        B(k:k+ns-1, i:i+nl-1)= sf * th{l}(j) * obj.N;
        i= i+nl;
        k= k+ns;
      end
    end
  end

  %
  % Build basic loop reactance matrix
  %
  function build_C(sf)
    % build loop matrix
    obj= construir_L(obj);
    % memory allocation
    C= spalloc(obj.mc, obj.ny, nnz(obj.L)*np*ni);
    % build matrix
    i= 1;
    k= 1;
    for l= 1:np
      for j= 1:ni
        C(k:k+nc-1, i:i+nl-1)= sf * th{l}(j) * obj.L;
        i= i+nl;
        k= k+nc;
      end
    end
  end

  %
  % Build lower bounds
  %
  function build_lb()
    % system data
    dn= get(obj.si,'dn');
    in= get(obj.si,'in');
    ur= get(obj.si,'ur');
    vn= get(obj.si,'vn');

    % lower bounds on reservoir storage
    ls= zeros(nr,ni-1);        
    for i= 1:nr
      ls(i,:)= vn(ur(i), 1:ni-1);
    end
    
    %  store data
    obj.ls= empacotar_s(obj,ls);
  
    % lower bounds on water release
    % water spill
    lv= zeros(nu,ni);
    % water discharge
    lq= cell(np,1);
    for l= 1:np
      lq{l}= dn;
    end
    % pack data
    obj.lq= empacotar_q(obj,lq);
    obj.lv= empacotar_v(obj,lv);

    % lower bounds on transmission
    obj.ly= empacotar_y(obj,in);

    % lower bounds on thermal power generation
    % three-dimensional memory allocation
    lz= cell(np, 1);
    for l= 1:np
      lz{l}= zeros(nt, ni);
    end
    
    % fill in elements
    for t= 1:nt
      gn= get(ut{t},'gn');
      for l= 1:np
        for j= 1:ni
          lz{l}(t,j)= gn(l,j);
        end
      end
    end
    
    % pack data
    obj.lz= empacotar_z(obj,lz);
    
    % build lx
    lx = zeros(obj.nx,1);
    k = 1;
    for j=1:ni
      for i=1:nu
        ror= get(uh{i},'ie');
        if ~ror
          if j < ni
            lx(k) = ls(find(ur==i, 1), j);
            k = k + 1;
          end
        end
        lx(k) = lq{1}(i,j); k = k + 1;
        lx(k) = lv(i,j); k = k + 1;
      end
    end
  end

  %
  % Build upper bounds
  %
  function build_ub()
    % system data
    af= get(obj.si,'af');
    im= get(obj.si,'im');
    ur= get(obj.si,'ur');
    vm= get(obj.si,'vm');
    % maximum water spill factor
    beta= 10;
    %
    % upper bounds on reservoir storage
    us= zeros(nr,ni-1);
    for i= 1:nr
      us(i,:)= vm(ur(i),1:ni-1);
    end
    % store data
    obj.us= empacotar_s(obj,us);
    %
    % upper bounds on water release
    % memory allocation
    uq= cell(np,1);
    uv= zeros(nu,ni);
    lq= desempacotar_q(obj,obj.lq);
    for l= 1:np
      uq{l}= zeros(nu,ni);
    end
    for i= 1:nu
      % maximum incremental inflow
      maf= max(af(i,:));
      % upper limit
      for j= 1:ni
        % compute maximum water discharge
        % as a function of the number of available generators
        qm= qef(uh{i}, nq(i,j));
        if (qm <= lq{1}(i,j))
          qm= lq{1}(i,j) + 1;
        end
        % copy maximum water discharge over levels
        for l= 1:np
          uq{l}(i,j)= qm;
        end
        % compute maximum water spill
        uv(i,j)= min(max([maf; beta*qm]), get(uh{i},'dm') - qm);
      end
    end
    % store data
    obj.uq= empacotar_q(obj,uq);
    obj.uv= empacotar_v(obj,uv);
    % clear temporary buffers
    clear qm;
    clear dm;
    clear lq;
    %
    % upper bounds on power transmission
    obj.uy= empacotar_y(obj,im);
    %
    % upper bounds thermal power generation
    uz= cell(np, 1);
    for l= 1:np
      uz{l}= zeros(nt, ni);
    end
    % fill in elements
    for t= 1:nt
      gm= get(ut{t},'gm');
      for l= 1:np
        for j= 1:ni
          uz{l}(t,j)= gm(l,j);
        end
      end
    end
    % pack data
    obj.uz= empacotar_z(obj,uz);
         
    % 
    ux = zeros(obj.nx,1);
    k = 1;
    for j=1:ni
      for i=1:nu
        ror= get(uh{i},'ie');
        if ~ror
          if j < ni
            ux(k) = us(find(ur==i, 1), j);
            k = k + 1;
          end
        end
        ux(k) = uq{1}(i,j); k = k + 1;
        ux(k) = uv(i,j); k = k + 1;
      end
    end
  end

  %
  % Build Jacobian matrix with constant elements
  %
  function build_J()
    obj.J= sparse([], [], [], obj.m, obj.n, 0);
    %
    obj.J(1:obj.ma, 1:obj.nx)= A;
    obj.J(obj.ma+obj.mc+1:obj.m, obj.nx+1:obj.nx+obj.ny)= B;
    obj.J(obj.ma+1:obj.ma+obj.mc, obj.nx+1:obj.nx+obj.ny)= C;
    obj.J(obj.ma+obj.mc+1:obj.m, obj.nx+obj.ny+1:obj.n)= -G;
  end

  %
  % Build Lagrangian Hessian matrix
  %
  function build_H()
    [rq, cq, vq] = find(2*Q);
    %
    Hg = sparse([], [], [], obj.nx, obj.nx, 0);
    for k = 1:obj.mb
      Hg = Hg + diag(IT1(k,:));
    end
    [rp, cp, vp] = find(Hg*P);
    %
    rq = rq + obj.nx + obj.ny;
    cq = cq + obj.nx + obj.ny;
    %
    obj.Hf= [rq, cq, vq];
    obj.Hg= [rp, cp, -vp];
  end

  %
  % Build Tx ladder matrix
  %
  function Tx = build_Tx(wx)
    n = 1;
    m = 1;
    rows = zeros(obj.nx, 1);
    cols = (1:obj.nx)';
    for j = 1:ni
      for k= 1:nu
        ror= get(uh{k},'ie');
        % volume variables
        if ~ror
          if j < ni
            rows(n)= m;
            n= n+1;
          end
        end
        % discharge variables
        for l= 1:np
          rows(n)= m;
          n= n+1;
        end
        % spillage variables
        rows(n)= m;
        n= n+1;
        m= m+1;
      end
    end
    Tx = sparse(rows, cols, wx, nu*ni, obj.nx, obj.nx);
  end
  

  %%%%%%%
  %%%%%%% Pack and unpack functions
  %%%%%%%

  %
  % Hydro variables extraction
  %
  function wx = extract_x(w)
    wx= w(1:obj.nx);
  end

  %%%%%%%
  %%%%%%% Utility functions
  %%%%%%%
  
  %
  % Build block diagonal matrix from list
  %
  function BDM = blkdiaglst(L,r)
    BDM = [];
    for j = 1:r
      for i = 1:length(L)
        BDM = blkdiag(BDM, L{i});
      end
    end
  end

  %
  % Vertically concatenate vectors from list
  %
  function VCV = vertcatlst(L,r)
    VCV = [];
    for j = 1:r
      for i = 1:length(L)
        VCV = vertcat(VCV, L{i});
      end
    end
  end
end