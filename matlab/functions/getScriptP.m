function SP = getScriptP(B_m, B_c, Upsilon, SM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getScriptP returns Script P
% Inputs:
%       B_m     Double  share of src sect used as intermed. inputs (NRxNR)
%       B_c     Double  share of upstream output used in final cons. (NRxN)
%       Upsilon Double  share of nominal VA in total nominal cons. (NxNR)
%       alpha   Double  labour share (NRx1)
%       eta     Double  share of value added in production (NRx1)
%       SM      Double  Script M (NRxNR). See scriptM_fun.m 
% Output:
%       SP      Double  Script P (NRxNR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Script P
I = eye(size(SM,1),size(SM,2));
SP = - pinv(I-SM)*(I-B_c*Upsilon-B_m) ;
end