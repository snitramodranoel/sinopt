% @problema/set.m sets object property values.
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
function obj= set(obj, varargin)
  pargin = varargin;
  while (length(pargin) >= 2)
    propriedade= pargin{1};
    valor= pargin{2};
    % update list of arguments
    pargin= pargin(3:end);
    switch propriedade
      % problem data
      case 'A'
        obj.A= valor;
      case 'B'
        obj.B= valor;
      case 'C'
        obj.C= valor;
      case 'G'
        obj.G= valor;
      case 'Gu'
        obj.Gu= valor;
      case 'I'
        obj.I= valor;
      case 'Iu'
        obj.Iu= valor;
      case 'L'
        obj.L= valor;
      case 'M'
        obj.M= valor;
      case 'N'
        obj.N= valor;
      case 'Q'
        obj.Q= valor;
      case 'Ql'
        obj.Ql= valor;
      case 'V'
        obj.V= valor;
      case 'X'
        obj.X= valor;
      case 'b'
        obj.b= valor;
      case 'd'
        obj.d= valor;
      case 'ls'
        obj.ls= valor;
      case 'lq'
        obj.lq= valor;
      case 'lv'
        obj.lv= valor;
      case 'ly'
        obj.ly= valor;
      case 'lz'
        obj.lz= valor;
      case 'us'
        obj.us= valor;
      case 'uq'
        obj.uq= valor;
      case 'uv'
        obj.uv= valor;
      case 'uy'
        obj.uy= valor;
      case 'uz'
        obj.uz= valor;
      case 'lx'
        obj.lx= valor;
      case 'ux'
        obj.ux= valor;
      % objects
      case 'pf'
        obj.pf= valor;
      case 'si'
        obj.si= valor;
      % solver options
      case 'dv'
        obj.dv= valor;
      case 'km'
        obj.km= valor;
      case 'so'
        obj.so= valor;
      otherwise
        error('SINopt:problema:invalidProperty', ...
            '%s is not a valid property', propriedade);
    end
  end
end
