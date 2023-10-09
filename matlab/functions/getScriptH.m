function SH = getScriptH(psi, AT_c, SP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getScriptH returns Script H
% Inputs:
%       psi   int        Frisch labour elasticity
%       AT_c  Double     final use trade share (NxNR)
%       SP    Double     Script P (NRxNR). See getScriptP.m
% Output:
%       SH    Double     Script H (NRxNR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Script H
I = eye(size(AT_c,2), size(AT_c,2));
AC = kron(AT_c, ones(size(AT_c,2)/size(AT_c,1),1));
SH = (psi/(1+psi))*(I+(I-AC)*SP);
end
