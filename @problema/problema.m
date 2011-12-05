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
  obj.Q = []; % submatrix Q of A
  obj.Ql= {}; % list of submatrices Ql of Q
  obj.V = []; % submatrix V of A
  obj.X = []; % submatrix X of A
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
  obj.na= 0; % number of a variables
  obj.nq= 0; % number of q variables
  obj.nv= 0; % number of v variables
  obj.nx= 0; % number of x variables
  obj.ny= 0; % number of y variables
  obj.nz= 0; % number of z variables
  obj.n = 0; % total number of variables
  % Jacobian
  obj.J = [];
  obj.JP= [];
  % Hessian
  obj.H = [];
  obj.Hf= [];
  obj.Hg= [];
  obj.HP= [];
  % objects
  obj.pf= profiler();  % statistics
  obj.rs= resultado(); % results
  obj.si= sistema();   % power system
  % solver options
  obj.km=   128; % maximum number of iterations
  obj.dv= 'off'; % verbosity (off, iter, notify, final)
  obj.so= 'ipf'; % solution algorithm (ipf, ipo)
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
        error('SINopt:problema:invalidArgument', ...
              'Argument is not a valid @problema object');
      end
      % class instantiation
      obj= class(obj, 'problema');
    otherwise
      error('SINopt:problema:invalidArgument','Wrong number of arguments');
  end
end