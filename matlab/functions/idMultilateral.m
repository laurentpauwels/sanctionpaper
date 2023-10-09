function [country_i, sector_r, sectorcode_r, year] = idMultilateral(indname, indcode, ctycode, years)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% idMultilateral creates country-sector-year ID list to export 
% datasets out of MATLAB.
% Inputs:
%       indname     Cell array    Cell containing info on industries
%       indcode     Cell array    Cell containing info on industry code
%       ctycode     Cell array    Cell containing info on country code
%       years       Double        List of years
%
% Output:
%       country_i       Cell array    Country list to match # of industries
%       sector_r        Cell array    Sector list to match # of countries
%       sectorcode_r    Cell array    Sector code to match # of countries
%       year            Double        Year list to match # of ctry/indust.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nind = size(indcode,1);
nctry =  size(ctycode,1);
nyrs = size(years,1);

sector_r = cell(nind*nctry*nyrs,1);
sectorcode_r = cell(nind*nctry*nyrs,1);
country_i = cell(nind*nctry*nyrs,1);
year = zeros(nind*nctry*nyrs,1);
v = 0;
for y = 1:nyrs
    for i = 1:nctry
        for r = 1:nind
            v = v + 1;
            sector_r(v,1) = indname(r,1);
            sectorcode_r(v,1) = indcode(r,1);
            country_i(v,1) = ctycode(i,1);
            year(v,1) = years(y,1);
        end
    end
end
end