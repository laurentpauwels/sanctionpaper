function SM = getScriptM(rho, eps, B_m, B_c, AT_mm, AT_c, Upsilon)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getScriptMatrix computes Script M.
% Inputs:
%       rho     int     Final goods elasticity of substitution
%       eps     int     Intermediate goods elasticity of substitution
%       AT_mm   Double  intermediate use trade share (NRxNR)
%       AT_c    Double  final use trade share (NxNR)
%       B_m     Double  share of src sect used as intermed. inputs (NRxNR)
%       B_c     Double  share of upstream output used in final cons. (NRxN)
%       Upsilon Double  share of nominal VA in total nominal cons. (NxNR)
% Output:
%       SM      Double  Script M (NRxNR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Script M
SM = B_c*Upsilon+B_m...
    +(1-rho)*(diag(B_c*ones(size(B_c,2),1)) - B_c*AT_c)...
    +(1-eps)*(diag(B_m*ones(size(B_m,2),1)) - B_m*AT_mm);
end