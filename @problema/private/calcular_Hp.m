% @problema/private/calcular_Hp.m computes Hessian of p(x).
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
function Hp= calcular_Hp(obj,w,lambda)
  % system data
  uh= get(obj.si,'uh');
  ur= get(obj.si,'ur');
  vf= get(obj.si,'vf');
  % system dimensions
  ni= get(obj.si,'ni');
  np= get(obj.si,'np');
  nq= get(obj.si,'nq');
  nu= get(obj.si,'nu');
  nr= get(obj.si,'nr');
  n = nu*ni;
  % unpack primal variables
  ss= desempacotar_s(obj, extrair_s(obj,w));
  qq= desempacotar_q(obj, extrair_q(obj,w));
  vv= desempacotar_v(obj, extrair_v(obj,w));
  % unpack dual variables
  yb= desempacotar_lambdab(obj, extrair_lambdab(obj,lambda));
  % allocate memory for partial derivatives
  dss= zeros(obj.na,1);
  dsq= zeros(obj.na*np,1);
  dqq= zeros(n*np,1);
  dqv= zeros(n*np,1);
  dvv= zeros(n,1);
  % compute Hessian
  k= 0;
  u= 0;
  r= 0;
  t= 0;
  for j= 1:ni
    % check for final stage
    if j < ni
      a= ss(:,j);
    else
      for i= 1:nr
        a(i)= vf(ur(i));
      end
    end
    % reset index of plants with a reservoir
    z = 0;
    % perform computations
    for i= 1:nu
      % vector buffers
      bc= get(uh{i}, 'bc');
      df= get(uh{i}, 'df');
      % scalar buffers
      v= vv(i,j);
      ror= get(uh{i},'ie');
      % check for power generation availability
      if nq(i,j) > 0
        zeta= 1;
      else
        zeta= 0;
      end
      % check for plants with a reservoir
      if ~ror
        z= z+1;
        % scalar buffer
        s= a(z);
        % check for final stage
        if j < ni
          r= r+1;
        end
      end
      % compute row, column indexes for dp/dvv partial derivatives
      u= u+1;
      for l= 1:np
        k= k+1;
        % scalar buffers
        q= qq{l}(i,j);
        % 
        y= 0.0;
        for b= 1:length(bc)
          y= y + yb{l}(bc(b),j) * df(b);
        end
        % check for plants with a reservoir
        if ~ror
          % check for final stage
          if j < ni
            t= t+1;
            % compute dp/dss and dp/dsq partial derivatives
            dss(r)= dss(r) + y * dpdss(uh{i},zeta,s,q);
            dsq(t)= y * dpdsq(uh{i},zeta,s);
          end
        end
        % compute partial derivatives
        dqq(k)= y * dpdqq(uh{i},zeta,q,v);
        dqv(k)= y * dpdqv(uh{i},zeta,q,v);
        dvv(u)= dvv(u) + y * dpdvv(uh{i},zeta,q,v);
      end
    end
  end
  % concatenate derivative value arrays
  Hp= [dss; dsq; dsq; dqq; dqv; dqv; dvv];
end