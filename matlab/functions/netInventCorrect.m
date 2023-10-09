function io_cln = netInventCorrect(io_table,finalcat,nind,ncty)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% netInventCorrrect corrects for inventories (INVNT) as
% discussed in Antras-Chor (2013,2018).
% Inputs:
%       io          Double        Matrix IO table includes concatenated IO 
%                                 data and Final demand.
%       fincat      String        Name of final demand categories.
%       nind        Double        Number of industries.
%       ncty        Double        Number of countries.
% Output:
%       io_cln      Double        Matrix containing the IO data corrected 
%                                 for inventories and without inventories 
%                                 columns.
% References:
%1. Antras, P. and Chor, D. (2013). Organizing the Global Value Chain. 
% Econometrica, 81(6):2127– 2204.
%2. Antras, P. and Chor, D. (2018). On the Measurement of Upstreamness and 
% Downstreamness in Global Value Chains. In Ing, L. Y. and Yu, M., editors, 
% World Trade Evolution: Growth, Productivity and Employment, chpt 5. 
% Routledge.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nfinals = size(finalcat,1);
invnt = nfinals - (find(ismember(finalcat,'INVNT')|...
    ismember(finalcat,'INVEN')|...
    ismember(finalcat,'Changes in inventories')|...
    ismember(finalcat,'Changes in inventories and valuables'))); %5th col of nfinal is Changes in inventories (ICIO)
nyrs = size(io_table,3);
io_nrows = ncty*nind;
io_ncols = io_nrows + nfinals*ncty;

% Collecting inventories
N_ir = squeeze(sum(squeeze(io_table(1:io_nrows,...
    io_nrows+nfinals-invnt:nfinals:io_nrows+(ncty*nfinals)-invnt,:)), 2));
Y_ir = squeeze(sum(io_table(1:io_nrows,1:io_ncols,:),2));

% Remove inventories
io_woinvnt = io_table;
io_woinvnt(:,io_nrows+nfinals-invnt:nfinals:io_nrows+(ncty*nfinals)-invnt,:) = []; 

% Net inventories correction factor Antras-Chor (2013, 2019)
mf = Y_ir ./ max(Y_ir - N_ir,0);
mf(isnan(mf)|isinf(mf)) = 1;

io_cln = io_woinvnt .* reshape(mf, [io_nrows, 1, nyrs]);
io_cln(io_cln<0) = 0; %Occasionally GFCF<0 and VA<0
end
% % Check
% YY = squeeze(sum(io_cln,2,'omitnan'));
% Y_Y1=round(YY-Y_ir,6);
% 
% % io_cln2=zeros(size(io_woinvnt));
% % for y = 1:nyrs
% %     io_cln2(:,:,y) = io_woinvnt(:,:,y) .* mf(:,y);
% % end
% io_cln(io_cln<0) = 0;
% YY2 = squeeze(sum(io_cln,2,'omitnan'));
% 
% (sum(Y_Y2>0.0000001 | Y_Y2<-0.0000001)/(nind*nctry))*100
