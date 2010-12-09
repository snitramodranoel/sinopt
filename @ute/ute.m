% @ute/ute.m stores thermal plant data.
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
function obj = ute(varargin)
  obj.cd=           0; % code
  obj.cg= polinomio(); % cost function      [R$/MWh]
  obj.eo=           0; % operation status
  obj.fc=          {}; % capacity factor    [0,1]
  obj.gn=          {}; % minimum generation [MW]
  obj.id=          {}; % availability rate  [0,1]
  obj.nm=          ''; % name
  obj.pe=          {}; % effective power    [MW]
  obj.ss=           0; % subsystem
  
  switch nargin
      % default
      case 0
          % class instantiation
          obj= class(obj, 'ute');
      % cloning
      case 1
          if isa(varargin{1}, 'ute')
              obj= varargin{1};
          else
              error('sinopt:ute:invalidArgument','Not a valid UTE object');
          end
          % class instantiation
          obj= class(obj, 'ute');
      otherwise
          error('sinopt:ute:invalidArgument', 'Wrong number of arguments');
  end
end
