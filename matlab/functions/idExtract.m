function id = idExtract(sheet,idname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% idExtract extracts specific information from a cell containing 
% spreadsheet information.
% Inputs:
%       sheet       Cell array    Cell containing info in a spreadsheet.
%       idname      String        Name of the variable to be extracted.
%
% Output:
%       id          Cell array    Column containing the values in the same 
%                                 row as idname.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[~,col] = find(strcmp(sheet, idname));%Find 'id' in Sheet
id = sheet(:,col);%Isolate Column with 'id'
id = id(~cellfun('isempty',id));%remove empty cells
[row,~] = find(strcmp(id, idname));%Find 'id' in array
id(row) = [];%remove idname from list

end

