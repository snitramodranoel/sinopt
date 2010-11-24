% sinopt.m solves long-term hydrothermal scheduling problems.
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
function sinopt(estudo, varargin)
  % load data
  oio= io();
  oio= ler(oio,estudo);
  sis= get(oio,'si');
  % problem setup
  prb= problema();
  prb= set(prb,'si',sis);
  prb= construir(prb);
  % configure solver
  pargin = varargin;
  while (length(pargin) >= 2)
    att= pargin{1};
    vlu= pargin{2};
    % update list of arguments
    pargin= pargin(3:end);
    switch att
      case 'iterations'
        prb= set(prb,'km',vlu);
      case 'solver'
        prb= set(prb,'so',vlu);
      case 'verbosity'
        prb= set(prb,'dv',vlu);
      otherwise
        error('sinopt:invalidOption', '%s is not a valid option', att);
    end
  end
  % solve problem
  prb= resolver(prb);
  oio= set(oio,'pb',prb);
  % output optimization results
  escrever(oio,estudo);
end
