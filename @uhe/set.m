% @uhe/set.m sets object property values.
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
function obj= set(obj, varargin)
  pargin = varargin;
  while (length(pargin) >= 2)
    propriedade= pargin{1};
    valor= pargin{2};
    % atualiza vetor de argumentos
    pargin= pargin(3:end);
    switch propriedade
      case 'bc'
        obj.bc= valor;
      case 'cd'
        obj.cd= valor;
      case 'cf'
        obj.cf= valor;
      case 'cg'
        obj.cg= valor;
      case 'cj'
        obj.cj= valor;
      case 'df'
        obj.df= valor;
      case 'dm'
        obj.dm= valor;
      case 'dn'
        obj.dn= valor;
      case 'id'
        obj.id= valor;
      case 'ie'
        obj.ie= valor;
      case 'ij'
        obj.ij= valor;
      case 'im'
        obj.im= valor;
      case 'ms'
        obj.ms= valor;
      case 'ng'
        obj.ng= valor;
      case 'nm'
        obj.nm= valor;
      case 'nt'
        obj.nt= valor;
      case 'pc'
        obj.pc= valor;
      case 'pe'
        obj.pe= valor;
      case 'qb'
        obj.qb= valor;
      case 'tm'
        obj.tm= valor;
      case 'vm'
        obj.vm= valor;
      case 'vn'
        obj.vn= valor;
      case 'yc'
        obj.yc= valor;
      case 'ya'
        obj.ya= valor;
      case 'yp'
        obj.yp= valor;
      case 'yf'
        obj.yf= valor;
      otherwise
        error('SINopt:uhe:invalidProperty', ...
          '%s is not a valid property', propriedade);
    end
  end
end