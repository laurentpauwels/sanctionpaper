function [lnY, lnP, lnPY, lnV] = getTransportCostImpact(SM, SP, SH, Lambda,lnTau,...
                                             AT_c, B_c, AT_mm, AT_m, B_m,...    
                                             elast, alpha, eta) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getTransportCostImpact computes the equilibrium in deviations from a 
% steady state created by shocks to the transport costs. The main model
% follows Huo et al. (2021).
% Inputs:
%       SM      Double  Script M (NRxNR) (getScriptM_fun.m)
%       SP      Double  Script P (NRxNR) (getScriptP_fun.m)
%       SH      Double  Script H (NRxNR) (getScriptP_fun.m)
%       LA      Double  Lambda (NRxNR) (getLambda_fun.m)
%       lnTau   Double  Changes in transport costs (NRxN)
%       AT_c    Double  final use trade share (NxNR)
%       B_c     Double  share of upstream output used in final cons. (NRxN)
%       AT_mm   Double  intermediate use trade share (NRxNR)
%       B_m     Double  share of src sect used as intermed. inputs (NRxNR)
%       elast   Double  elasticities (rho, esp, psi)
%       alpha   Double  labour share (NRx1)
%       eta     Double  share of value added in production (NRx1)
% Output:
%       lnY     Double  steady-state deviations of real ouput 
%       lnP     Double  relative country-industry prices
%       lnPY    Double  steady-state deviations of gross ouput  
%       lnV     Double  steady-state deviations of real value added
% Note that Lambda is NOT defined as the inverse (unlike Huo et al., 2021)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Preliminaries
rho = elast(1);%Final goods substitution elasticity
eps = elast(2);%Intermediate goods substitution elasticity
psi = elast(3);%Frisch elasticity
[NR,N] = size(lnTau);
R = NR/N;

%% lnT1 and lnT2
LNT = (kron(lnTau, ones(1,R)));
LNTK = transpose(kron(lnTau, ones(1,R)));
A_c = transpose(AT_c);
A_mm = transpose(AT_mm);

lnT1 = (1-rho)*(B_c.*(ones(NR,1)-A_c).*lnTau)*ones(N,1)...
     + (1-eps)*(B_m.*(ones(NR,1)-A_mm).*LNT)*ones(NR,1);

lnT2 = AT_m.*LNTK*ones(NR,1);%lnT2 pre-multiplied by (I-eta) in expression 
% for lnY. Simplification done here. 

%% Model: lnY, lnPY, lnH, lnV
I = eye(NR,NR);
AC = kron(AT_c, ones(size(AT_c,2)/size(AT_c,1),1));

lnT = ((psi/(1+psi))*diag(eta)*diag(alpha)*(I-AC)...
    + ((I-diag(eta)) - AT_m))*pinv(I-SM)*lnT1...
    - lnT2; %(I-eta) simplified in lnT2 expression.
lnT(isnan(lnT)|isinf(lnT)) = 0;

lnY = Lambda\lnT;
lnP = SP*lnY;
lnPY = (SP+I)*lnY;
lnH = SH*lnY;
lnV = diag(alpha)*lnH;
end
%Alternative expressions:
% truc1 = (1/R)*((1-rho)*(kron(B_c,ones(1,R)).*(ones(NR,1)-kron(A_c,ones(1,R)))));
% truc2 = (1-eps)*(B_m.*(ones(NR,1)-A_mm));
% lnT1alt = (truc1+truc2);
% Lambda_tau = ((psi/(1+psi))*diag(eta)*diag(alpha)*(I-AC)...
%     + ((I-diag(eta)) - AT_m))*pinv(I-SM);
%lnTalt = (Lambda_tau*(lnT1alt.*LNT)...
%     - AT_m.*LNTT)*ones(NR,1); %(I-eta) simplified in lnT2 expression.