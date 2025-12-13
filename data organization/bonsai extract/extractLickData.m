function behavFile = extractLickData(filename, FP)



%% Input handling
    % If dataLines is not specified, define defaults
    dataLines = [2, Inf];
    
    % Set up the Import Options and import the data
    if FP
        opts = delimitedTextImportOptions("NumVariables", 4); 
        % Specify range and delimiter
        opts.DataLines = dataLines;
        opts.Delimiter = ",";   
        % Specify column names and types
        opts.VariableNames = ["TS", "Trial", "Id", "ElapsedTime"];
        % opts.SelectedVariableNames = ["VarName2", "VarName4", "VarName5"];
        opts.VariableTypes = ["double", "double", "string", "double"];
        % Specify file level properties
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        % Import the data
        behavFile = readtable(filename, opts);
        behavFile.TS = behavFile.TS / 1e3;
        behavFile.TS_0 = behavFile.TS - behavFile.TS(1);
        behavFile.ElapsedTS_0 = behavFile.ElapsedTime - behavFile.ElapsedTime(1);

    else
        opts = delimitedTextImportOptions("NumVariables", 3);
        % Specify range and delimiter
        opts.DataLines = dataLines;
        opts.Delimiter = ",";
        % Specify column names and types
        opts.VariableNames = ["Trial", "Id", "ElapsedTime"];
        opts.VariableTypes = ["double", "string", "double"];
        % Specify file level properties
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        % Import the data
        behavFile = readtable(filename, opts);
        behavFile.ElapsedTS_0 = behavFile.ElapsedTime - behavFile.ElapsedTime(1);
    end
    
end

