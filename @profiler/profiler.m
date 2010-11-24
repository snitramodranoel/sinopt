% @profiler/profiler.m stores optimization statistics.
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
function obj= profiler(varargin)
  obj.ad= []; % dual steps
  obj.ap= []; % primal steps
  obj.cg= []; % duality gap convergence criterion
  obj.cs= []; % sigma convergence criterion
  obj.cw= []; % omega convergence criterion
  obj.cy= []; % lambda convergence criterion
  obj.cz= []; % zeta convergence criterion
  obj.f=  []; % objective function value
  obj.ga= []; % complementarity
  obj.k=   0; % number of iterations
  obj.mu= []; % barrier parameter
  obj.ry= []; % primal residual norm
  obj.si= []; % dual residual norm
  obj.t=   0; % time elapsed

  switch nargin
    % default
    case 0
      % class instantiation
      obj= class(obj, 'profiler');
    % cloning
    case 1
      if isa(varargin{1}, 'profiler')
        obj= varargin{1};
      else
        error('sinopt:profiler:invalidArgument', ...
              'Argument is not a valid PROFILER object');
      end
      % class instantiation
      obj= class(obj, 'profiler');
    otherwise
      error('sinopt:profiler:invalidArgument', ...
          'Wrong number of arguments');
  end
end