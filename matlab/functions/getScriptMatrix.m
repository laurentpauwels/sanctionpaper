function [SM, SP, SH, LA] = getScriptMatrix(elast, AT_mm, AT_c, B_m, B_c,...
                                            Upsilon, alpha, eta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getScriptMatrix computes the main components of the Huo et al (2023) 
% model: scriptH, scriptP, scriptM, and Lambda. The requirements for this 
% function are:
% - getScriptM.m
% - getScriptH.m
% - getScriptP.m
% - getLambda.m
% Inputs:
%       elast   Double  elasticities (rho, esp, psi)
%       AT_mm   Double  intermediate use trade share (NRxNR)
%       AT_c    Double  final use trade share (NxNR)
%       B_m     Double  share of src sect used as intermed. inputs (NRxNR)
%       B_c     Double  share of upstream output used in final cons. (NRxN)
%       Upsilon Double  share of nominal VA in total nominal cons. (NxNR)
%       alpha   Double  labour share (NRx1)
%       eta     Double  share of value added in production (NRx1)
% Output:
%       SM      Double  Script M (NRxNR)
%       SP      Double  Script P (NRxNR)
%       SH      Double  Script H (NRxNR)
%       LA      Double  Lambda (NRxNR)
% Note that Lambda is NOT defined as the inverse (unlike Huo et al., 2021)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rho = elast(1);%Final goods substitution elasticity
eps = elast(2);%Intermediate goods substitution elasticity
psi = elast(3);%Frisch elasticity

SM = getScriptM(rho, eps, B_m, B_c, AT_mm, AT_c, Upsilon);%script M
if rho == 1 && eps == 1
    SP = -eye(size(SM,1),size(SM,2));%script P in Cobb-Douglas case
else
    SP = getScriptP(B_m, B_c, Upsilon, SM);%script P
end
SH = getScriptH(psi, AT_c, SP); %Script H (without LAMBDA)
LA = getLambda(psi, alpha, eta, AT_mm, AT_c, SP);%LAMBDA NOT INVERSED
end
