% @problema/get.m returns object property values.
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
    % problem data
    case 'A'
      valor= obj.A;
    case 'B'
      valor= obj.B;
    case 'C'
      valor= obj.C;
    case 'L'
      valor= obj.L;
    case 'M'
      valor= obj.M;
    case 'N'
      valor= obj.N;
    case 'Q'
      valor= obj.Q;
    case 'Ql'
      valor= obj.Ql;
    case 'V'
      valor= obj.V;
    case 'X'
      valor= obj.X;
    case 'b'
      valor= obj.b;
    case 'd'
      valor= obj.d;
    case 'ls'
      valor= obj.ls;
    case 'lq'
      valor= obj.lq;
    case 'lv'
      valor= obj.lv;
    case 'ly'
      valor= obj.ly;
    case 'lz'
      valor= obj.lz;
    case 'us'
      valor= obj.us;
    case 'uq'
      valor= obj.uq;
    case 'uv'
      valor= obj.uv;
    case 'uy'
      valor= obj.uy;
    case 'uz'
      valor= obj.uz;
    % problem dimensions
    case 'ma'
      valor= obj.ma;
    case 'mb'
      valor= obj.mb;
    case 'mc'
      valor= obj.mc;
    case 'm'
      valor= obj.m;
    case 'na'
      valor= obj.na;
    case 'nq'
      valor= obj.nq;
    case 'nv'
      valor= obj.nv;
    case 'nx'
      valor= obj.nx;
    case 'ny'
      valor= obj.ny;
    case 'nz'
      valor= obj.nz;
    case 'n'
      valor= obj.n;
    % objects
    case 'pf'
      valor= obj.pf;
    case 'rs'
      valor= obj.rs;
    case 'si'
      valor= obj.si;
    % solver options
    case 'dv'
      valor= obj.dv;
    case 'km'
      valor= obj.km;
    case 'so'
      valor= obj.so;
    otherwise
      error('sinopt:problema:get:invalidProperty', ...
          '%s is not a valid property', propriedade);
  end
end
