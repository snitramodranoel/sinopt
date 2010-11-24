% @cg/cg.m stores data for turbine/generator sets.
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
function obj= cg(varargin)
  obj.he= 0.0; % water head of the set                [m]
  obj.nt=   0; % number of turbines
  obj.tt=   0; % type of turbine:
               %  (1) Francis;
               %  (2) Kaplan;
               %  (3) Pelton
  obj.pe= 0.0; % power capacity per turbine           [MW]
  obj.pm= 0.0; % minimum power generation per turbine [MW]
  obj.qe= 0.0; % discharge per turbine                [m^3/s]
  obj.rg= 0.0; % generator's efficiency rate          [0,1]

  switch nargin
      % default
      case 0
          % instanciamento
          obj= class(obj, 'cg');
      % clonagem
      case 1
          if isa(varargin{1}, 'cg')
              obj= varargin{1};
          else
              error('sinopt:cg:invalidArgument', ...
                  'Argument is not a valid CG object');
          end
          % instanciamento
          obj= class(obj, 'cg');
      otherwise
          error('sinopt:cg:invalidArgument', ...
              'Wrong number of arguments');
  end
end