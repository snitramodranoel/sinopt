% @sistema/set.m sets object property values.
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
      case 'af'
        obj.af= valor;
      case 'ai'
        obj.ai= valor;
      case 'br'
        obj.br= valor;
      case 'bx'
        obj.bx= valor;
      case 'dc'
        obj.dc= valor;
      case 'di'
        obj.di= valor;
      case 'dn'
        obj.dn= valor;
      case 'ev'
        obj.ev= valor;
      case 'ez'
        obj.ez= valor;
      case 'gp'
        obj.gp= valor;
      case 'im'
        obj.im= valor;
      case 'in'
        obj.in= valor;
      case 'li'
        obj.li= valor;
      case 'll'
        obj.ll= valor;
      case 'lo'
        obj.lo= valor;
      case 'lp'
        obj.lp= valor;
      case 'mi'
        obj.mi= valor;
      case 'nc'
        obj.nc= valor;
      case 'nf'
        obj.nf= valor;
      case 'ni'
        obj.ni= valor;
      case 'nj'
        obj.nj= valor;
      case 'nl'
        obj.nl= valor;
      case 'np'
        obj.np= valor;
      case 'nq'
        obj.nq= valor;
      case 'nr'
        obj.nr= valor;
      case 'ns'
        obj.ns= valor;
      case 'nt'
        obj.nt= valor;
      case 'nu'
        obj.nu= valor;
      case 'rt'
        obj.rt= valor;
      case 'th'
        obj.th= valor;
      case 'ti'
        obj.ti= valor;
      case 'tm'
        obj.tm= valor;
      case 'tn'
        obj.tn= valor;
      case 'tp'
        obj.tp= valor;
      case 'tv'
        obj.tv= valor;
      case 'uc'
        obj.uc= valor;
      case 'uh'
        obj.uh= valor;
      case 'uf'
        obj.uf= valor;
      case 'ur'
        obj.ur= valor;
      case 'ut'
        obj.ut= valor;
      case 'uz'
        obj.uz= valor;
      case 'vf'
        obj.vf= valor;
      case 'vi'
        obj.vi= valor;
      case 'vm'
        obj.vm= valor;
      case 'vn'
        obj.vn= valor;
      case 'vz'
        obj.vz= valor;
      otherwise
        error('SINopt:sistema:invalidProperty', ...
          '%s is not a valid property', propriedade);
    end
  end
end
