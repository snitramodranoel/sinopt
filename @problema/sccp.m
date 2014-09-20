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
function sccp(obj)
  % swap plants between ROR and regulation reservoir lists
  obj= swap(obj);

  % system dimensions
  nc= get(obj.si,'nc');
  ni= get(obj.si,'ni');
  nl= get(obj.si,'nl');
  np= get(obj.si,'np');
  nr= get(obj.si,'nr');
  ns= get(obj.si,'ns');
  nt= get(obj.si,'nt');
  nu= get(obj.si,'nu');
  % system data
  ut= get(obj.si,'ut');
  uh= get(obj.si,'uh');
  th= get(obj.si,'th');

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
  % box constraints
  build_lb;
  build_ub;
  % hydro constraints
  obj= construir_bb(obj);
  %obj= construir_A(obj);
  build_A;
  P = cell(nu);
  pl = cell(nu);
  build_P;
  % power constraints
  obj= construir_d(obj);
  obj= construir_B(obj);
  obj= construir_C(obj);
  % check for data sanity
  obj= verificar(obj);
  
  % 
  % build membership matrices
  %
  obj= construir_G(obj);
  obj= construir_I(obj);
  
  
  
  % Build functions
    function build_lb()
        % system data
        dn= get(obj.si,'dn');
        in= get(obj.si,'in');
        ur= get(obj.si,'ur');
        ut= get(obj.si,'ut');
        vn= get(obj.si,'vn');
        % system dimensions
        ni= get(obj.si,'ni');
        np= get(obj.si,'np');
        nr= get(obj.si,'nr');
        nt= get(obj.si,'nt');
        nu= get(obj.si,'nu');
        %
        % lower bounds on reservoir storage
        ls= zeros(nr,ni-1);        
        for i= 1:nr
            ls(i,:)= vn(ur(i), 1:ni-1);
        end
        %  store data
        obj.ls= empacotar_s(obj,ls);
        %  clear temporary buffer
        % clear ls;
  
        %
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
        % clear temporary buffer
        % clear lq;
        % clear lv;
        %
        % lower bounds on transmission
        obj.ly= empacotar_y(obj,in);
        %
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
        
        % 
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
        obj.lx = lx;
    end
    function build_ub()
         % system data
         af= get(obj.si,'af');
         im= get(obj.si,'im');
         nq= get(obj.si,'nq');
         uh= get(obj.si,'uh');
         ur= get(obj.si,'ur');
         ut= get(obj.si,'ut');
         vm= get(obj.si,'vm');
         % system dimensions
         ni= get(obj.si,'ni');
         np= get(obj.si,'np');
         nr= get(obj.si,'nr');
         nt= get(obj.si,'nt');
         nu= get(obj.si,'nu');
         % maximum water spill factor
         b= 10;
         %
         % upper bounds on reservoir storage
         us= zeros(nr,ni-1);
         for i= 1:nr
             us(i,:)= vm(ur(i),1:ni-1);
         end
         % store data
         obj.us= empacotar_s(obj,us);
         % clear temporary buffer
         % clear us;
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
                 uv(i,j)= min(max([maf; b*qm]), get(uh{i},'dm') - qm);
             end
         end
         % store data
         obj.uq= empacotar_q(obj,uq);
         obj.uv= empacotar_v(obj,uv);
         % clear temporary buffers
         clear qm;
         clear dm;
         %clear uq;
         %clear uv;
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
         obj.ux = ux;
    end
    function build_A()
        % system dimensions
        ni= get(obj.si,'ni');
        nj= get(obj.si,'nj');
        np= get(obj.si,'np');
        nr= get(obj.si,'nr');
        nu= get(obj.si,'nu');
        ti= get(obj.si,'ti');
        ur= get(obj.si,'ur');
        % build matrix A
        A = spalloc(obj.ma, obj.nx, 2*obj.na + ni*((nu+nj)*(np+1)));
        k = 1; % collumn control
        for j=1:ni
            for i=1:nu
                ror= get(uh{i},'ie');
                if ~ror
                    if j < ni
                      % v
                      lip = find(ur==i,1) + nu*(j-1);
                      A(lip,k) = 1/(ti(j)/10^6);
                      lin = find(ur==i,1) + nu*j;
                      A(lin,k) = -1/(ti(j+1)/10^6);
                      k = k + 1;
                    end
                end
                % q
                lip = nu*(j-1) + i;
                A(lip,k) = 1;
                if (get(uh{i},'ij') > 0)
                    lin = nu*(j-1) + get(uh{j},'ij'); 
                    A(lin,k) = -1;
                end
                k = k + 1;
                % s 
                lip = nu*(j-1) + i;
                A(lip,k) = 1;
                if (get(uh{i},'ij') > 0)
                    lin = nu*(j-1) + get(uh{j},'ij'); 
                    A(lin,k) = -1;
                end
                k = k + 1;
            end
        end
        obj.A = A;
        b = obj.b;
    end
    function build_P()
        % compute matrix P
        for i = 1:nu
            % forebay coefficients
            cm = get(get(uh{i},'yc'), 'cf');
            % tailrace coefficients
            yf = get(uh{i},'yf');
            cj = get(yf{1,2},'cf');
            % penstock loss coefficients
            pc = get(uh{i},'pc');
            cp = zeros(2,1);
            if pc{1} == 1
                cp(1) = 0;
                cp(2) = pc{2};
            elseif pc{1} == 2
                cp(1) = pc{2};
                cp(2) = 0;
            end
            pe= get(uh{i},'pe');
            vm= get(uh{1},'vm');
            dn= get(uh{1},'dn');
            li = [1 ; 2 ; 2 ; 2 ; 3];
            co = [2 ; 1 ; 2 ; 3 ; 2];
            vlu = pe*[cm(2)/2 ; cm(2)/2 ; -(cj(2)+cp(2)) ; -cj(2)/2 ; -cj(2)/2 ]; 
            P{i} = sparse(li,co,vlu,3,3,5);
            pl{i} = pe*[0 ; cm(1)-cj(1)-cp(1) ; 0 ];
        end
    end
% Pack and unpack functions
  
end