function sessions = bpLoadSessions(sessions, filenames, filepaths)
    % loads Bpod SessionData files
    % interactive file loading: call with only sessions argument
    % returns sessions structure with fields: filename, filepath,
    % SessionData
    %ARGUMENTS:
    % sessions- provide to add to existing structure
    
    % filenames- provide filenames for loading from current directory or
    % specified directory, form- string or string cell array
    
    % filepaths- if cell singleton or a string then this path will be
    % used for all listed filenames, form- string or string cell array
        
    
    if nargin < 3 
        filepaths = pwd;
    end
    
    if nargin == 0 || isempty(sessions)% create a new sessions struct for output
        sessions = struct();
    end
        
    if nargin < 2 % interactive loading
        [filenames, filepaths, ind] = uigetfile('*Session*.mat', 'select Session files to load', 'MultiSelect', 'on');
        if ~ind
            sessions=[];
            return
        end        
    end
    
    if ischar(filenames)
        filenames = {filenames};
    end
    
    if ischar(filepaths)
        filepaths = {filepaths};
    end        
    
    if length(filepaths) == 1 % if you are using a common path, make a dummy array for iteration
        filepaths = repmat(filepaths, size(filenames));
    end
    
    [filenames, I] = sort(filenames);
    filepaths = filepaths(I);
    
    for counter = 1:length(filenames)
        session = load(fullfile(filepaths{counter}, filenames{counter}));
        sessions(counter).SessionData = session.SessionData;
        sessions(counter).filename = filenames{counter};
        sessions(counter).filepath = filepaths{counter};
        disp(['***Loaded ' filenames{counter} ' from ' filepaths{counter} '***']);
    end
    
    
    


