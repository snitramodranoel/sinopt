% @problema/problema.m defines optimization problem.
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
function obj= problema(varargin)
  % problem data
  obj.A = []; % matrix A
  obj.B = []; % matrix B
  obj.C = []; % matrix C
  obj.L = []; % submatrix L of C
  obj.M = []; % submatrix M of R
  obj.N = []; % submatrix N of B
  obj.R = []; % submatrix R of A
  obj.S = []; % submatrix S of A
  obj.sj= {}; % list of submatrices Sj of S
  obj.b = []; % b vector
  obj.d = []; % d vector
  %  lower bounds
  obj.ls= []; % s
  obj.lq= []; % q
  obj.lv= []; % v
  obj.ly= []; % y
  obj.lz= []; % z
  %  upper bounds
  obj.us= []; % s
  obj.uq= []; % q
  obj.uv= []; % v
  obj.uy= []; % y
  obj.uz= []; % z
  %  constraint-space dimensions
  obj.ma= 0; % number of Ax constraints
  obj.mb= 0; % number of By constraints
  obj.mc= 0; % number of Cy constraints
  obj.m = 0; % total number of equality constraints
  %  variable-space dimensions
  obj.nx= 0; % number of x variables
  obj.ny= 0; % number of y variables
  obj.nz= 0; % number of z variables
  obj.n = 0; % total number of variables
  % cache
  obj.Jg= []; % g(u) function Jacobian matrix
  % objects
  obj.dp= despacho(); % results
  obj.pf= profiler(); % statistics
  obj.si= sistema();  % power system
  % solver options
  obj.km=   256; % maximum number of iterations
  obj.dv= 'off'; % verbosity (off, iter, notify, final)
  obj.kh=  'on'; % Kirchhoff's Second Law (on, off)
  obj.so= 'ipf'; % solution algorithm (ipf, ipbf, sqp)
  obj.tr=  'on'; % power transmission (on, off)
  % instantiation
  switch nargin
    % default
    case 0
      % class instantiation
      obj= class(obj, 'problema');
    % cloning
    case 1
      if isa(varargin{1}, 'problema')
        obj= varargin{1};
      else
        error('sinopt:problema:invalidArgument', ...
              'Argument is not a valid PROBLEMA object');
      end
      % class instantiation
      obj= class(obj, 'problema');
    otherwise
      error('sinopt:problema:invalidArgument', ...
          'Wrong number of arguments');
  end
end