% @sistema/get.m returns object property values.
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
function valor= get(obj, propriedade)
  switch propriedade
    case 'af'
      valor= obj.af;
    case 'ai'
      valor= obj.ai;
    case 'dc'
      valor= obj.dc;
    case 'dn'
      valor= obj.dn;
    case 'ev'
      valor= obj.ev;
    case 'ez'
      valor= obj.ez;
    case 'im'
      valor= obj.im;
    case 'in'
      valor= obj.in;
    case 'li'
      valor= obj.li;
    case 'mi'
      valor= obj.mi;
    case 'nc'
      valor= obj.nc;
    case 'ni'
      valor= obj.ni;
    case 'nl'
      valor= obj.nl;
    case 'nq'
      valor= obj.nq;
    case 'ns'
      valor= obj.ns;
    case 'nt'
      valor= obj.nt;
    case 'nu'
      valor= obj.nu;
    case 'rt'
      valor= obj.rt;
    case 'ti'
      valor= obj.ti;
    case 'tm'
      valor= obj.tm;
    case 'tn'
      valor= obj.tn;
    case 'uc'
      valor= obj.uc;
    case 'uh'
      valor= obj.uh;
    case 'ut'
      valor= obj.ut;
    case 'uz'
      valor= obj.uz;
    case 'vf'
      valor= obj.vf;
    case 'vi'
      valor= obj.vi;
    case 'vm'
      valor= obj.vm;
    case 'vn'
      valor= obj.vn;
    case 'vz'
      valor= obj.vz;
    otherwise
      error('hydra:sistema:get:invalidProperty', ...
          '%s is not a valid property', propriedade);
  end
end