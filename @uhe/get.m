% @uhe/get.m returns object property values.
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
function valor = get(obj, propriedade)
  switch propriedade
    case 'bc'
      valor= obj.bc;
    case 'cd'
      valor= obj.cd;
    case 'cf'
      valor= obj.cf;
    case 'cg'
      valor= obj.cg;
    case 'cj'
      valor= obj.cj;
    case 'df'
      valor= obj.df;
    case 'dm'
      valor= obj.dm;
    case 'dn'
      valor= obj.dn;
    case 'id'
      valor= obj.id;
    case 'ie'
      valor= obj.ie;
    case 'ij'
      valor= obj.ij;
    case 'im'
      valor= obj.im;
    case 'ms'
      valor= obj.ms;
    case 'ng'
      valor= obj.ng;
    case 'nm'
      valor= obj.nm;
    case 'pc'
      valor= obj.pc;
    case 'pe'
      valor= obj.pe;
    case 'qb'
      valor= obj.qb;
    case 'tm'
      valor= obj.tm;
    case 'vm'
      valor= obj.vm;
    case 'vn'
      valor= obj.vn;
    case 'yc'
      valor= obj.yc;
    case 'ya'
      valor= obj.ya;
    case 'yp'
      valor= obj.yp;
    case 'yf'
      valor= obj.yf;
    otherwise
      error('SINopt:uhe:invalidProperty', ...
        '%s is not a valid property', propriedade);
  end
end