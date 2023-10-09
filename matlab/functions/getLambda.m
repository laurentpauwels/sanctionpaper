function LA = getLambda(psi, alpha, eta, AT_mm, AT_c, SP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getLambda computes Lambda
% Inputs:
%       psi     Int     Frisch Labour Elasticity
%       alpha   Double  labour share (NRx1)
%       eta     Double  share of value added in production (NRx1)
%       AT_mm   Double  intermediate use trade share (NRxNR)
%       AT_c    Double  final use trade share (NxNR)
%       SP      Double  script P (NRxNR)
% Output:
%       LA      Double  Lambda (NRxNR)
% Note that Lambda is NOT defined as the inverse (unlike Huo et al., 2021)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Lambda
I = eye(size(AT_c,2), size(AT_c,2));
AC = kron(AT_c, ones(size(AT_c,2)/size(AT_c,1),1));
LA = (I - (psi/(1+psi))*diag(eta)*diag(alpha)*(I+(I-AC)*SP)...
            - (I-diag(eta))*(I+(I-AT_mm)*SP));
end


