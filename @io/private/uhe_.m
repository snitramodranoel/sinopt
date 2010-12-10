% @io/private/uhe_.m reads UHE files.
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
function obj= uhe_(obj, arquivo)
  % open file
  fid= fopen(arquivo,'r');
  frewind(fid);

  % [VERS]
  %  file version
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[VERS]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  v= fscanf(fid,'%f',1);
  % check for file version
  if v ~= 2.0
    fclose(fid);
    error('sinopt:io:uhe:fileNotSupported', ...
        'HydroLab UHE file version %1.1f is not supported', v);
  end

  % [NUHE]
  %  number of hydro plants
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NUHE]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  nu= fscanf(fid,'%i',1);
  % sanity check
  if nu ~= get(obj.si,'nu');
    error('sinopt:io:uhe:numberMismatch','Wrong number of hydro plants');
  end

  % memory allocation for hydro plants list
  uh= cell(nu,1);
  for j= 1:nu
    uh{j}= uhe();
  end

  % [NINT]
  %  number of stages
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NINT]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  ni= fscanf(fid,'%d',1);
  % sanity check
  if ni ~= get(obj.si,'ni')
    error('sinopt:io:uhe:numberMismatch', 'Wrong number of stages');
  end

  % [UHID]
  %  hydro plant identification information
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[UHID]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  for j= 1:nu
    % bogus
    fscanf(fid,'%s',1);
    fscanf(fid,'%s',1);
    fscanf(fid,'%s',1);
    fscanf(fid,'%s',1);
    fscanf(fid,'%s',1);
    fscanf(fid,'%s',1);
    % hydro plant identification
    uh{j}= set(uh{j}, 'nm', fgetl(fid));
  end

  % [NUMS]
  %  codes
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[NUMS]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  for j= 1:nu
    fscanf(fid,'%s',1); % bogus
    uh{j}= set(uh{j},'ss',fscanf(fid,'%i',1)); % subsystem
    uh{j}= set(uh{j},'cd',fscanf(fid,'%i',1)); % code
    uh{j}= set(uh{j},'cj',fscanf(fid,'%i',1)); % downstream reservoir code
    fgetl(fid); % bogus
  end

  % [TOPO]
  %  network topology
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[TOPO]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  nj= 0;
  for j= 1:nu
    fscanf(fid,'%s',1); % bogus
    % downstream reservoir's index
    ij = fscanf(fid,'%i',1);
    if ij ~= nu
      uh{j}= set(uh{j},'ij',ij+1);
      nj= nj + 1;
    else
      uh{j}= set(uh{j},'ij',0);
    end
  end
  % number of hydro plants with downstream reservoirs
  obj.si= set(obj.si,'nj',nj);
  % clean temporary buffer
  clear ij;
  clear nj;

  % build lists of upstream reservoirs
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
  % clean temporary buffers
  clear t;
  clear ij;
  clear im;

  % [PRIM]
  %  productivity data
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[PRIM]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  for j= 1:nu
    fscanf(fid,'%s',1); % bogus
    uh{j}= set(uh{j},'pe',fscanf(fid,'%f',1)); % productivity
    uh{j}= set(uh{j},'cf',fscanf(fid,'%f',1)); % mean tailrace elevation
    % perda de carga hidr??ulica
    pc= {0; 0.0};
    pc{1}= fscanf(fid,'%i',1);
    pc{2}= fscanf(fid,'%f',1);
    switch pc{1}
      case 1
        pc{2}= pc{2} / 100.0;
    end
    uh{j}= set(uh{j},'pc',pc);
    % maximum number of generators in sync
    uh{j}= set(uh{j},'ms',fscanf(fid,'%i',1));
    % type of maximum discharge computation
    uh{j}= set(uh{j},'tm',fscanf(fid,'%i',1));
  end
  % clean temporary buffers
  clear pc;

  % [TUGE]
  %  power generation
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[TUGE]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  for j= 1:nu
    fscanf(fid,'%s',1); % bogus
    % number of generators
    ng= fscanf(fid,'%i',1);
    uh{j}= set(uh{j},'ng',ng);
    % misc
    M= fscanf(fid,'%f',[7 ng])';
    cgs= get(uh{j},'cg');
    % consolidation
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
      % number of turbines
      nt= nt + get(cgs{k},'nt');
      % maximum discharge
      qef= qef + (get(cgs{k},'qe') * get(cgs{k},'nt'));
    end
    uh{j}= set(uh{j},'cg',cgs);
    uh{j}= set(uh{j},'nt',nt);
    uh{j}= set(uh{j},'qb',qef/nt);
  end

  % [TXID]
  %  availability
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[TXID]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  for j= 1:nu
    fscanf(fid,'%s',1); % bogus
    uh{j}= set(uh{j},'id',fscanf(fid,'%f',1)); % unavailability rate
  end

  % [VMDM]
  %  hydro operation constraints
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[VMDM]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  for j= 1:nu
    fscanf(fid,'%s',1);                        % bogus
    uh{j}= set(uh{j},'vn',fscanf(fid,'%f',1)); % minimum reservoir storage
    uh{j}= set(uh{j},'vm',fscanf(fid,'%f',1)); % maximum reservoir storage
    fscanf(fid,'%s',1);                        % bogus
    fscanf(fid,'%s',1);                        % bogus
    % maximum release
    dm= fscanf(fid,'%f',1);
    if dm > 1e10
      uh{j}= set(uh{j},'dm',Inf);
    else
      uh{j}= set(uh{j},'dm',dm);
    end
    % bogus
    fscanf(fid,'%s',1);
    % operating status
    uh{j}= set(uh{j},'ie',fscanf(fid,'%i',1));
    % clear temporary buffer
    clear dm;
  end

  % [POCV]
  %  forebay elevation polynomials
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[POCV]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  for j= 1:nu
    % bogus
    fscanf(fid,'%s',1);
    % polynomial
    M= fscanf(fid,'%f',[5 1]);
    poly= get(uh{j},'yc');
    poly= set(poly,'cf',M);
    uh{j}= set(uh{j},'yc',poly);
    % clear temporary buffers
    clear poly M;
  end

  % [POAC]
  %  reservoir area polynomials
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[POAC]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  for j= 1:nu
    % bogus
    fscanf(fid,'%s',1);
    % polynomial
    M= fscanf(fid,'%f',[5 1]);
    poly= get(uh{j},'ya');
    poly= set(poly,'cf',M);
    uh{j}= set(uh{j},'ya',poly);
    % clear temporary buffers
    clear poly M;
  end

  % [POCF]
  %  tailrace elevation polynomials
  linha= fscanf(fid,'%s\n',1);
  while not(strcmp('[POCF]',linha))
    linha= fscanf(fid,'%s\n',1);
  end
  % read data
  for j= 1:nu
    % bogus
    fscanf(fid,'%s',1);
    % polynomials
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
    % clear temporary buffer
    clear yf;
  end

  % update list of hydro plants
  obj.si= set(obj.si,'uh',uh);

  % close file
  fclose(fid);
end