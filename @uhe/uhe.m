% @uhe/uhe.m stores hydro plant data.
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
function obj = uhe(varargin)
  obj.am= zeros(12,1); % monthly long-term mean inflows [m^3/s]
  obj.as= zeros(52,1); % weekly long-term mean inflows [m^3/s]
  obj.cd=           0; % Eletrobras code
  obj.cf=         0.0; % mean tailrace elevation [m]
  obj.cg=          {}; % list of turbine/generator sets
  obj.cj=           0; % downstream reservoir Eletrobras code
  obj.dm=         0.0; % maximum water release [m^3/s]
  obj.dn=         0.0; % minimum water release [m^3/s]
  obj.id=         1.0; % availability rate
  obj.ie=           0; % operation status
  obj.ij=           0; % downstream reservoir
  obj.im=          []; % list of immediately upstream reservoirs 
  obj.ms=           1; % minimum number of generators in sync
  obj.ng=           0; % number of generators
  obj.nm=          ''; % name
  obj.nt=           0; % number of turbines
  obj.pc=    {0; 0.0}; % penstock loss
  obj.pe=         0.0; % produtibilidade espec??fica (MW/m??/s/m)
  obj.qb=         0.0; % average maximum water discharge per turbine
  obj.ss=           0; % subsystem
  obj.tm=           2; % type of maximum discharge function
  obj.vm=         0.0; % maximum reservoir storage [hm^3]
  obj.vn=         0.0; % minimum reservoir storage [hm^3]
  obj.ya= polinomio(); % forebay elevation x reservoir area polynomial
  obj.yc= polinomio(); % reservoir storage x forebay elevation polynomial
  obj.yf=          {}; % water release x tailrace elevation polynomials

  switch nargin
      % default
      case 0
          % class instantiation
          obj= class(obj, 'uhe');
      % cloning
      case 1
          if isa(varargin{1}, 'uhe')
              obj= varargin{1};
          else
              error('sinopt:uhe:invalidArgument', ...
                  'Argument is not a valid UHE object');
          end
          % class instantiation
          obj= class(obj, 'uhe');
      otherwise
          error('sinopt:uhe:invalidArgument', ...
              'Wrong number of arguments');
  end
end