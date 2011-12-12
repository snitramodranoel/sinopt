% @io/private/ropt_.m writes ROPT files.
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
function ropt_(obj)
  % open file
  fid= fopen(strcat(obj.fi,'.ropt'),'w+');
  % system dimensions
  ni= get(obj.si,'ni');
  nl= get(obj.si,'nl');
  np= get(obj.si,'np');
  nq= get(obj.si,'nq');
  ns= get(obj.si,'ns');
  nt= get(obj.si,'nt');
  nu= get(obj.si,'nu');
  % problem data
  af= get(obj.si,'af'); % incremental inflows
  ai= get(obj.si,'ai'); % start year
  di= get(obj.si,'di'); % start day
  mi= get(obj.si,'mi'); % start month
  uh= get(obj.si,'uh'); % list of hydro plants
  ti= get(obj.si,'ti'); % duration of stages
  tp= get(obj.si,'tp'); % duration of load levels
  vi= get(obj.si,'vi'); % initial reservoir storage states
  vf= get(obj.si,'vf'); % final reservoir storage requirements
  % optimal solution
  s= get(obj.rs,'s');   % reservoir storage
  q= get(obj.rs,'q');   % water discharge
  v= get(obj.rs,'v');   % water spill
  y= get(obj.rs,'y');   % power flow
  z= get(obj.rs,'z');   % power generation at thermal plants
  P= get(obj.rs,'P');   % total hydro power generation
  Q= get(obj.rs,'Q');   % total thermal power generation
  la= get(obj.rs,'la'); % water value
  lb= get(obj.rs,'lb'); % marginal costs
  uq= get(obj.rs,'uq'); % maximum water discharge
  % build list of dates
  data= cell(ni+1,1);
  data{1}= datestr(datenum(ai,mi,(di-1)),'dd/mm/yyyy');
  k= datenum(ai,mi,di);
  for j= 1:ni
    data{j+1} = datestr(k,'dd/mm/yyyy');
    k = addtodate(k,ti(j),'second');
  end
  % clear temporary buffer
  clear k;
  % header
  fprintf(fid,'// SINopt\n');
  fprintf(fid,'// Resultados\n');
  % [VERS]
  % file version
  fprintf(fid,'\n[VERS]\n');
  fprintf(fid,' 2.0\n');
  % [NUHE]
  % number of hydro plants
  fprintf(fid,'\n[NUHE]\n');
  fprintf(fid,' %3d\n',nu);
  % [NUTE]
  % number of thermal plants
  fprintf(fid,'\n[NUTE]\n');
  fprintf(fid,' %3d\n',nt);
  % [NSUB]
  %  number of subsystems
  fprintf(fid,'\n[NSUB]\n');
  fprintf(fid,' %3d\n',ns);
  % [NLIN]
  % number of power transmission lines
  fprintf(fid,'\n[NLIN]\n');
  fprintf(fid,' %3d\n',nl);
  % [NINT]
  % number of stages of the optimization horizon
  fprintf(fid,'\n[NINT]\n');
  fprintf(fid,' %3d\n',ni);
  % [NPAT]
  % number of power transmission lines
  fprintf(fid,'\n[NPAT]\n');
  fprintf(fid,' %3d\n',np);
  % [DATA]
  % start date
  fprintf(fid,'\n[DATA]\n');
  fprintf(fid,'  %2d %2d %4d\n',di,mi,ai);
  % [VOLA]
  % reservoir storage
  fprintf(fid,'\n[VOLA]\n');
  for j= 1:ni+1
    k= 0;
    fprintf(fid,'  %s     ',data{j});
    for i= 1:nu
      ror= get(uh{i},'ie');
      if ~ror
        k= k+1;
        if (j > 1)
          if (j < ni+1)
            fprintf(fid,'\t%8.2f ',s(k,j-1));
          else
            fprintf(fid,'\t%8.2f ',vf(i));
          end
        else
          fprintf(fid,'\t%8.2f ',vi(i));
        end
      else
        fprintf(fid,'\t%8.2f ',vi(i));
      end
    end
    fprintf(fid,'\n');
  end
  % clear temporary buffers
  clear i;
  clear j;
  clear k;
  clear ror;
  % [VOLU]
  % reservoir storage (in % of total capacity)
  fprintf(fid,'\n[VOLU]\n');
  for j= 1:ni+1
    k= 0;
    fprintf(fid,'  %s     ',data{j});
    for i= 1:nu
      ror= get(uh{i},'ie');
      vm = get(uh{i},'vm');
      vn = get(uh{i},'vn');
      if ~ror
        k= k+1;
        if (j > 1)
          if (j < ni+1)
            fprintf(fid,'\t%8.2f ', 100*((s(k,j-1)-vn)/(vm-vn)));
          else
            fprintf(fid,'\t%8.2f ', 100*((vf(i)-vn)/(vm-vn)));
          end
        else
          fprintf(fid,'\t%8.2f ', 100*((vi(i)-vn)/(vm-vn)));
        end
      else
        fprintf(fid,'\t%8.2f ', 100*(vi(i)/vm));
      end
    end
    fprintf(fid,'\n');
  end
  % clear temporary buffers
  clear i;
  clear j;
  clear k;
  clear vm;
  clear vn;
  clear ror;
  % [DFLU]
  % water released
  fprintf(fid,'\n[DFLU]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np
      if l > 1
        fprintf(fid,'            \t%2d ',l);
      else
        fprintf(fid,'\t%2d ',l);
      end
      for i= 1:nu
        fprintf(fid,'\t%8.2f ',q{l}(i,j)+v(i,j));
      end
      fprintf(fid,'\n');
    end
  end
  % clear temporary buffers
  clear j;
  clear l;
  clear i;
  % [TURB]
  % water discharged
  fprintf(fid,'\n[TURB]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np
      if l > 1
        fprintf(fid,'            \t%2d ',l);
      else
        fprintf(fid,'\t%2d ',l);
      end
      for i= 1:nu
        fprintf(fid,'\t%8.2f ',q{l}(i,j));
      end
      fprintf(fid,'\n');
    end
  end
  % clear temporary buffers
  clear j;
  clear l;
  clear i;
  % [VINC]
  % incremental inflows
  fprintf(fid,'\n[VINC]\n');
  for j= 1:ni
    fprintf(fid,'  %s     ',data{j+1});
    for i= 1:nu
      fprintf(fid,'\t%8.2f ',af(i,j));
    end
    fprintf(fid,'\n');
  end
  % clear temporary buffers
  clear j;
  clear i;
  % [VMOT]
  % forebay 
  fprintf(fid,'\n[VMOT]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np
      if l > 1
        fprintf(fid,'            \t%2d ',l);
      else
        fprintf(fid,'\t%2d ',l);
      end
      for i= 1:nu
        um= 0.0;
        im= get(uh{i},'im');
        for t= 1:length(im)
          um= um + q{l}(t,j) + v(t,j);
        end
        fprintf(fid,'\t%8.2f ',um);
      end
      fprintf(fid,'\n');
    end
  end
  % clear temporary buffers
  clear t;
  clear im;
  clear um;
  % [QMAX]
  % maximum water discharge
  fprintf(fid,'\n[QMAX]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np
      if l > 1
        fprintf(fid,'            \t%2d ',l);
      else
        fprintf(fid,'\t%2d ',l);
      end
      for i= 1:nu
        fprintf(fid,'\t%8.2f ',uq{l}(i,j));
      end
      fprintf(fid,'\n');
    end
  end
  % clear temporary buffers
  clear j;
  clear l;
  clear i;
  % [VERT]
  % water spilled
  fprintf(fid,'\n[VERT]\n');
  for j= 1:ni
    fprintf(fid,'  %s     ',data{j+1});
    for i= 1:nu
      fprintf(fid,'\t%8.2f ', v(i,j));
    end
    fprintf(fid,'\n');
  end
  % clear temporary buffers
  clear j;
  clear i;
  % [GUHE]
  % power generation at hydro plants
  fprintf(fid,'\n[GUHE]\n');
  for j= 1:ni 
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np
      if l > 1
        fprintf(fid,'            \t%2d ',l);
      else
        fprintf(fid,'\t%2d ',l);
      end
      k= 0;
      for i= 1:nu
        ror= get(uh{i},'ie');
        % check for power generation availability
        if nq(i,j) > 0
          zeta= 1;
        else
          zeta= 0;
        end
        % check for plants with a reservoir
        if ~ror
          k= k+1;
          if (j < ni)
            fprintf(fid,'\t%8.2f ',p(uh{i},zeta,s(k,j),q{l}(i,j),v(i,j)));
          else
            fprintf(fid,'\t%8.2f ',p(uh{i},zeta,vf(i),q{l}(i,j),v(i,j)));
          end
        else
          fprintf(fid,'\t%8.2f ',p(uh{i},zeta,vi(i),q{l}(i,j),v(i,j)));
        end
      end
      fprintf(fid,'\n');
    end
  end
  % clear temporary buffers
  clear i;
  clear j;
  clear k;
  clear l;
  clear ror;
  % [GUTE]
  % power generation at thermal plants
  fprintf(fid,'\n[GUTE]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np
      if l > 1
        fprintf(fid,'            \t%2d ',l);
      else
        fprintf(fid,'\t%2d ',l);
      end
      for t= 1:nt
        fprintf(fid,'\t%8.2f ', z{l}(t,j));
      end
      fprintf(fid,'\n');
    end
  end
  % clear temporary buffers
  clear j;
  clear l;
  clear t;
  % [GHSS]
  % total hydro power generation
  fprintf(fid,'\n[GHSS]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np
      if l > 1
        fprintf(fid,'            \t%2d ',l);
      else
        fprintf(fid,'\t%2d ',l);
      end
      for k= 1:ns
        fprintf(fid,'\t%8.2f ',P{l}(k,j));
      end
      fprintf(fid,'\n');
    end
  end
  % clear temporary buffers
  clear j;
  clear l;
  clear k;
  % [GTSS]
  % total thermal power generation
  fprintf(fid,'\n[GTSS]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np
      if l > 1
        fprintf(fid,'            \t%2d ',l);
      else
        fprintf(fid,'\t%2d ',l);
      end
      for k= 1:ns
        fprintf(fid,'\t%8.2f ',Q{l}(k,j));
      end
      fprintf(fid,'\n');
    end
  end
  % clear temporary buffers
  clear j;
  clear l;
  clear k;
  % [INTC]
  % power transmission
  fprintf(fid,'\n[INTC]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np
      if l > 1
        fprintf(fid,'            \t%2d ',l);
      else
        fprintf(fid,'\t%2d ',l);
      end
      for k= 1:nl
        fprintf(fid,'\t%8.2f ',y{l}(k,j));
      end
      fprintf(fid,'\n');
    end
  end
  % clear temporary buffers
  clear j;
  clear l;
  clear k;
  % [CMOP]
  % marginal costs
  fprintf(fid,'\n[CMOP]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np
      if l > 1
        fprintf(fid,'            \t%2d ',l);
      else
        fprintf(fid,'\t%2d ',l);
      end
      for k= 1:ns
        fprintf(fid,'\t%8.2f ',lb{l}(k,j)/(tp{l}(j)/3.6e+3));
      end
      fprintf(fid,'\n');
    end
  end
  % clear temporary buffers
  clear j;
  clear l;
  clear k;
  % [VLOR]
  % water value
  fprintf(fid,'\n[VLOR]\n');
  for j= 1:ni
    fprintf(fid,'  %s     ',data{j+1});
    for i= 1:nu
      fprintf(fid,'\t%8.2f ',la(i,j));
    end
    fprintf(fid,'\n');
  end
  % clear temporary buffers
  clear j;
  clear i;
  % close file
  fclose(fid);
end