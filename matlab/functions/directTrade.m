function [M, X] = directTrade(Z,F,emb_i,emb_j,emb_r)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Country/ies j imposes sanctions on country/ies i, sector(s) r.
% directTrade extract the direct impact of sanctions (global 
% value chains), i.e. the impact on country/ies,sector(s) (i,r) of the sanctions
% Inputs:
%       Z     Double      intermediate input-output matrix (NRxNR) 
%       F     Double      Final demand (NRxN) matrix
%       emb_i Double      sanctioned country/ies
%       emb_r Double      sanctioned industry/ies
%       emb_j Double      country/ies sanctionning embi
% Output:
%       M  Double        direct imports of size (embr x embi x embj)
%       X  Double        direct export of size (embr x embi x embj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NR = size(F,1);
N = size(F,2);
R = NR/N;
T = size(F,3);

% Gross Output (PY)
Y = max(squeeze(sum(Z,2)) + squeeze(sum(F,2)),0);

% Direct requirement
A = Z ./ transpose(Y);
A(isinf(A)) = 0;
A(isnan(A)) = 0;

% Direct intermediate imports
A_emb = reshape(A,R,N,R,N,T);
M = squeeze(A_emb(emb_r,emb_i,:,emb_j));
if length(emb_r) > 1
    M = transpose(sum(M,1,'omitnan'));
end

% Direct Final trade = PC/Y.
F_rxnxn = reshape(F./repmat(Y,1,N),R,N,N);
X = squeeze(F_rxnxn(:,emb_i,emb_j)); 
