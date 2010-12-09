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
function ropt_(obj,arquivo)
  % open file
  fid= fopen(arquivo,'w+');
  % system dimensions
  ni= get(obj.si,'ni');
  nl= get(obj.si,'nl');
  np= get(obj.si,'np');
  ns= get(obj.si,'ns');
  nt= get(obj.si,'nt');
  nu= get(obj.si,'nu');
  % problem data
  af= get(obj.si,'af');                % incremental inflows
  ai= get(obj.si,'ai');                % start year
  di= get(obj.si,'di');                % start day
  mi= get(obj.si,'mi');                % start month
  uh= get(obj.si,'uh');                % list of hydro plants
  uq= reshape(get(obj.pb,'uq'),nu,ni); % maximum discharge
  ti= get(obj.si,'ti');                % duration of stages
  vi= get(obj.si,'vi');                % initial reservoir storage states
  % optimal solution
  s= get(get(obj.pb,'dp'),'s');        % reservoir storage
  q= get(get(obj.pb,'dp'),'q');        % water discharge
  v= get(get(obj.pb,'dp'),'v');        % water spill
  y= get(get(obj.pb,'dp'),'y');        % power flow
  z= get(get(obj.pb,'dp'),'z');        % thermal power generation
  la= get(get(obj.pb,'dp'),'la');
  lb= get(get(obj.pb,'dp'),'lb');

  % build list of dates
  data= cell(ni+1,1);
  data{1}= datestr(datenum(ai,mi,(di-1)));
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
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    fprintf(fid,'\t%d\n',np(j));
  end
  
  % [DATA]
  % start date
  fprintf(fid,'\n[DATA]\n');
  fprintf(fid,'  %2d %2d %4d\n',di,mi,ai);

  % [VOLA]
  % reservoir storage
  fprintf(fid,'\n[VOLA]\n');
  for j= 1:ni+1
    fprintf(fid,'  %s ',data{j});
    for k= 1:nu
      if (j>1)
        fprintf(fid,'\t%8.2f ',s(k,j-1));
      else
        fprintf(fid,'\t%8.2f ',vi(k));
      end
    end
    fprintf(fid,'\n');
  end

  % [VOLU]
  % reservoir storage (in % of total capacity)
  fprintf(fid,'\n[VOLU]\n');
  for j= 1:ni+1
    fprintf(fid,'  %s ',data{j});
    for k= 1:nu
      ie= get(uh{k},'ie');
      vm= get(uh{k},'vm');
      vn= get(uh{k},'vn');
      switch ie
        case 0
          if (j>1)
            fprintf(fid,'\t%8.2f ', ((s(k,j-1)-vn)/(vm-vn))*100);
          else
            fprintf(fid,'\t%8.2f ', ((vi(k)-vn)/(vm-vn))*100);
          end
        case 1
          fprintf(fid,'\t%8.2f ', 0);
      end
    end
    fprintf(fid,'\n');
  end
  % clear temporary buffers
  clear vm;
  clear vn;

  % [DFLU]
  % water released
  fprintf(fid,'\n[DFLU]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np(j)
      fprintf(fid,'             \t%2d ',l);
      for k= 1:nu
        fprintf(fid,'\t%8.2f ',q{j}(k,l)+v(k,j));
      end
      fprintf(fid,'\n');
    end
  end

  % [TURB]
  % water discharged
  fprintf(fid,'\n[TURB]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np(j)
      fprintf(fid,'             \t%2d ',l);
      for k= 1:nu
        fprintf(fid,'\t%8.2f ',q{j}(k,l));
      end
      fprintf(fid,'\n');
    end
  end

  % [VINC]
  % incremental inflows
  fprintf(fid,'\n[VINC]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for k= 1:nu
      fprintf(fid,'\t%8.2f ',af(k,j));
    end
    fprintf(fid,'\n');
  end

  % [VMOT]
  % forebay 
  fprintf(fid,'\n[VMOT]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np(j)
      fprintf(fid,'             \t%2d ',l);
      for k= 1:nu
        um= 0.0;
        im= get(uh{k},'im');
        for t= 1:length(im)
          um= um + q{j}(t,l) + v(t,j);
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
    for l= 1:np(j)
      fprintf(fid,'             \t%2d ',l);
      for k= 1:nu
        fprintf(fid,'\t%8.2f ',uq{j}(k,l));
      end
      fprintf(fid,'\n');
    end
  end

  % [VERT]
  % water spilled
  fprintf(fid,'\n[VERT]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for k= 1:nu
      fprintf(fid,'\t%8.2f ', v(k,j));
    end
    fprintf(fid,'\n');
  end

  % [GUHE]
  % power generation at hydro plants
  fprintf(fid,'\n[GUHE]\n');
  for j= 1:ni 
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np(j)
      fprintf(fid,'             \t%2d ',l);
      for k= 1:nu
        fprintf(fid,'\t%8.2f ',p(uh{k},s(k,j),q{j}(k,l),v(k,j)));
      end
      fprintf(fid,'\n');
    end
  end

  % [GUTE]
  % power generation at thermal plants
  fprintf(fid,'\n[GUTE]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np(j)
      fprintf(fid,'             \t%2d ',l);
      for k= 1:nt
        fprintf(fid,'\t%8.2f ',z{j}(k,l));
      end
      fprintf(fid,'\n');
    end
  end

  % [GHSS]
  % hydro power generation in subsystems
  fprintf(fid,'\n[GHSS]\n');

  % [GTSS]
  % thermal power generation in subsystems
  fprintf(fid,'\n[GTSS]\n');

  % [INTC]
  % power transmission
  fprintf(fid,'\n[INTC]\n');
  for j= 1:ni
    fprintf(fid,'  %s ',data{j+1});
    for l= 1:np(j)
      fprintf(fid,'             \t%2d ',l);
      for k= 1:nl
        fprintf(fid,'\t%8.2f ',y{j}(k,l));
      end
      fprintf(fid,'\n');
    end
  end

  % [CMOP]
  % marginal costs
  fprintf(fid,'\n[CMOP]\n');

  % [VLOR]
  % water value
  fprintf(fid,'\n[VLOR]\n');

  % [BENF]
  % transmission benefits
  fprintf(fid,'\n[BENF]\n');

  % [STAT]
  % optimization statistics
  fprintf(fid,'\n[STAT]\n');

  % close file
  fclose(fid);
end