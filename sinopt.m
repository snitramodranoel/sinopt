% sinopt.m solves long-term hydrothermal scheduling problems.
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
function sinopt(estudo)
  % load data
  ioo= io();
  ioo= set(ioo, 'fi', estudo);
  try
    ioo= ler(ioo);
  catch err
    if strcmp(err.identifier, 'MATLAB:FileIO:InvalidFid')
      msg= 'Problem files do not exist';
    else
      msg= err.message;
    end
    eid= err.identifier;
    errordlg(strcat(eid,',',msg), 'Error', 'modal');
    return;
  end
  prb= get(ioo,'pb');
  % problem setup
  prb= set(prb,'si',get(ioo,'si'));
  try
    prb= construir(prb);
  catch err
    msg= err.message;
    eid= err.identifier;
    errordlg(strcat(eid,',',msg), 'Error', 'modal');
    return;
  end
  % solve problem
  try
    rs= resolver(prb);
  catch err
    if strcmp(err.identifier, 'MATLAB:UndefinedFunction')
      msg= sprintf('Solver %s is not available', upper(get(prb,'so')));
    else
      msg= err.message;
    end
    eid= err.identifier;
    errordlg(strcat(eid,',',msg), 'Error', 'modal');
    return;
  end
  ioo= set(ioo,'rs',rs);
  % output optimization results
  escrever(ioo);
end