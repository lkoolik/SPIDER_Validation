function [Sample,StartTime,Mean,TotalConccm,VarName18,VarName19,VarName20,VarName21,VarName22,VarName23,VarName24,VarName25,VarName26,VarName27,VarName28,VarName29,VarName30,VarName31,VarName32,VarName33] = importOPS(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [SAMPLE,STARTTIME,MEAN,TOTALCONCCM,VARNAME18,VARNAME19,VARNAME20,VARNAME21,VARNAME22,VARNAME23,VARNAME24,VARNAME25,VARNAME26,VARNAME27,VARNAME28,VARNAME29,VARNAME30,VARNAME31,VARNAME32,VARNAME33]
%   = IMPORTFILE(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   [SAMPLE,STARTTIME,MEAN,TOTALCONCCM,VARNAME18,VARNAME19,VARNAME20,VARNAME21,VARNAME22,VARNAME23,VARNAME24,VARNAME25,VARNAME26,VARNAME27,VARNAME28,VARNAME29,VARNAME30,VARNAME31,VARNAME32,VARNAME33]
%   = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows STARTROW
%   through ENDROW of text file FILENAME.
%
% Example:
%   [Sample,StartTime,Mean,TotalConccm,VarName18,VarName19,VarName20,VarName21,VarName22,VarName23,VarName24,VarName25,VarName26,VarName27,VarName28,VarName29,VarName30,VarName31,VarName32,VarName33] = importfile('04152017-23000-23300-row.txt',1, 302);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2017/06/02 14:30:36

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%*s%s%*s%*s%*s%*s%*s%*s%*s%*s%s%*s%*s%*s%s%*s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

% Convert the contents of columns with dates to MATLAB datetimes using date
% format string.
try
    dates{2} = datetime(dataArray{2}, 'Format', 'HH:mm:ss', 'InputFormat', 'HH:mm:ss');
catch
    try
        % Handle dates surrounded by quotes
        dataArray{2} = cellfun(@(x) x(2:end-1), dataArray{2}, 'UniformOutput', false);
        dates{2} = datetime(dataArray{2}, 'Format', 'HH:mm:ss', 'InputFormat', 'HH:mm:ss');
    catch
        dates{2} = repmat(datetime([NaN NaN NaN]), size(dataArray{2}));
    end
end

anyBlankDates = cellfun(@isempty, dataArray{2});
anyInvalidDates = isnan(dates{2}.Hour) - anyBlankDates;
dates = dates(:,2);

%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [1,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]);

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
Sample = cell2mat(rawNumericColumns(:, 1));
StartTime = dates{:, 1};
Mean = cell2mat(rawNumericColumns(:, 2));
TotalConccm = cell2mat(rawNumericColumns(:, 3));
VarName18 = cell2mat(rawNumericColumns(:, 4));
VarName19 = cell2mat(rawNumericColumns(:, 5));
VarName20 = cell2mat(rawNumericColumns(:, 6));
VarName21 = cell2mat(rawNumericColumns(:, 7));
VarName22 = cell2mat(rawNumericColumns(:, 8));
VarName23 = cell2mat(rawNumericColumns(:, 9));
VarName24 = cell2mat(rawNumericColumns(:, 10));
VarName25 = cell2mat(rawNumericColumns(:, 11));
VarName26 = cell2mat(rawNumericColumns(:, 12));
VarName27 = cell2mat(rawNumericColumns(:, 13));
VarName28 = cell2mat(rawNumericColumns(:, 14));
VarName29 = cell2mat(rawNumericColumns(:, 15));
VarName30 = cell2mat(rawNumericColumns(:, 16));
VarName31 = cell2mat(rawNumericColumns(:, 17));
VarName32 = cell2mat(rawNumericColumns(:, 18));
VarName33 = cell2mat(rawNumericColumns(:, 19));