function shares = getShares(Z, Y)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getShares creates shares by applying element-by-element division
% Inputs:
%       Z       Double      matrix or vector
%       Y       Double      matrix or vector of length(Z) 
% Output:
%       shares  Double      shares of size(Z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

shares = (Z ./ Y);
shares(isnan(shares)|isinf(shares)) = 0;
end