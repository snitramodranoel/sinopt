% @sistema/sistema.m stores power system data.
%
% Copyright (c) 2014 Leonardo Martins, Universidade Estadual de Campinas
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
function obj= sistema(varargin)
  obj.af= []; % inflows (i,j)                                   [m^3/s]
  obj.ai=  0; % start year
  obj.br= []; % branches reactances                             [PU]
  obj.bx= []; % branches resistances                            [PU]
  obj.dc= {}; % load [p(k,j)]                                   [MW]
  obj.di=  0; % start day
  obj.dn= []; % lower bound on release (i,j)                    [m^3/s]
  obj.ev= []; % evaporation coefficients (i,j)                  [mm]
  obj.gp= {}; % fixed generation [p(k,j)]                       [MW]
  obj.im= {}; % upper bounds on transmission lines [p(k,j)]     [MW]
  obj.in= {}; % lower bounds on transmission lines [p(k,j)]     [MW]
  obj.li= []; % network topology; lines in (from,to) form
  obj.ll= {}; % set of Lambda lists of closest upstream non-RORs
  obj.lo= {}; % set of Omega lists of directly upstream plants
  obj.lp= {}; % set of Psi lists of downstream RORs
  obj.mi=  0; % start month
  obj.nc=  1; % number of network loops
  obj.nf=  0; % number of run-off-river hydro plants
  obj.ni=  0; % number of discretized stages
  obj.nj=  0; % number of hydro plants with downstream reservoirs
  obj.nl=  0; % number of transmission lines
  obj.np=  1; % number of load levels per stage
  obj.nq= []; % maximum number of generators in operation (i,j)
  obj.nr=  0; % number of hydro plants with reservoir
  obj.ns=  0; % number of buses
  obj.nt=  0; % number of thermal plants
  obj.nu=  0; % number of hydro plants
  obj.rt= []; % reactances (o,l)                                [PU]
  obj.th= []; % duration of load levels for each stage          [h]
  obj.ti= []; % duration of stages                              [s]
  obj.tm= []; % maximum thermal power generation (t,j)          [MW]
  obj.tn= []; % minimum thermal power generation (t,j)          [MW]
  obj.tp= {}; % duration of load levels for each stage          [s]
  obj.tv=  1; % type of input inflows (natural, incremental)
  obj.uc= []; % consumptive water usage (i,j)                   [m^3/s]
  obj.uh= {}; % list of hydro plants
  obj.uf= []; % list of indexes of run-off-river hydro plants
  obj.ur= []; % list of indexes of hydro plants with reservoir
  obj.ut= {}; % list of thermal plants
  obj.vf= []; % final reservoir storage requirement             [hm^3]
  obj.vi= []; % initial reservoir storage state                 [hm^3]
  obj.vm= []; % maximum reservoir storage (i,j)                 [hm^3]
  obj.vn= []; % minimum reservoir storage (i,j)                 [hm^3]

  switch nargin
    % default
    case 0
      % object instantiation
      obj= class(obj, 'sistema');
    % cloning
    case 1
      if isa(varargin{1}, 'sistema')
         obj= varargin{1};
      else
         error('SINopt:sistema:invalidArgument', ...
             'Argument is not a valid @sistema object');
      end
        % object instantiation
        obj= class(obj, 'sistema');
    otherwise
      error('SINopt:sistema:invalidArgument','Wrong number of arguments');
  end
end