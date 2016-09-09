% Suelynn analysis development script

function TE = makeTE_posner4(TE)
        sessions = bpLoadSessions;
%% make structure with many different fields, e.g. trialNumber, trialOutcome, reactiontime, etc.
% every field in this structure should be either a numeric array with numRows
% (dimension 1) == nTrials OR a cell array with the same criteria

% find total number of trials acrosss selected sesssions
scounter = zeros(size(sessions));
for i = 1:length(sessions)
    scounter(i) = sessions(i).SessionData.nTrials;
end
nTrials = sum(scounter);


if nargin < 1 % initialize from scratch (reload)
    startIndex = 1;
    TE = struct(...
        'trialNumber', zeros(nTrials, 1),...
        'trialType', zeros(nTrials, 1),...  % e.g. left or right
        'trialOutcome', zeros(nTrials, 1),...  % e.g.  correct = 1, incorrect = 0
        'reactionTime', zeros(nTrials, 1),... % involve sutracting two numbers dug out of session.SessionData.RawEvents.Trial{1}
        'foreperiod', zeros(nTrials, 1)...
    );
    TE.filename = cell(nTrials, 1);
else
    startIndex = length(TE.filename);
    % extend all fields from startIndex
    TE.filename{startIndex + nTrials} = ''; % automatically extend
    TE.trialNumber = [TE.trialNumber ; zeros(nTrials, 1)];
    TE.trialType = [TE.trialType; zeros(nTrials, 1)];  % e.g. left or right
    TE.validTrial = [TE.validTrial; zeros(nTrials, 1)];  % e.g. left or right
    TE.invalidTrial= [TE.invalidTrial; zeros(nTrials, 1)];  % e.g. left or right
    TE.trialOutcome = [TE.trialOutcome; zeros(nTrials, 1)];  % e.g.  correct = 1, incorrect = 0
    TE.reactionTime = [TE.reactionTime; zeros(nTrials, 1)]; % involve sutracting two numbers dug out of session.SessionData.RawEvents.Trial{1}
    TE.TrialStartTimeStamp=[TE.TrialStartTimeStamp; zeros(nTrials, 1)];
    TE.sessionIndex = [TE.sessionIndex; zeros(nTrials, 1)];
    TE.sessionChange = [TE.sessionChange; zeros(nTrials, 1)];
    TE.ITI=[TE.ITI; zeros(nTrials, 1)];
    TE.foreperiod = [TE.foreperiod; zeros(nTrials, 1)];
%     TE.TrackForeperiodProgress = [TE.TrackForeperiodProgress; zeros(nTrials, 1)];

end


    


tcounter = 1;
for sCounter = 1:length(sessions)
    session = sessions(sCounter);
   
    for counter = 1:session.SessionData.nTrials
        % stuff for all trials
        TE.trialType(tcounter) = session.SessionData.Transf(counter);            
        TE.filename{tcounter} = session.filename;     
        TE.trialNumber(tcounter) = counter; 
        TE.TrialStartTimeStamp(tcounter)= session.SessionData.TrialStartTimestamp(counter);
        % distinguished by punishment
        
        if ~isnan(session.SessionData.RawEvents.Trial{1,counter}.States.Drinking(1)) %non-punish trials
            TE.trialOutcome (tcounter) = 1;
            
            if isfield (session.SessionData.RawEvents.Trial{1,counter}.States, 'TargetLightOn')==1
            TE.reactionTime(tcounter)= session.SessionData.RawEvents.Trial{1,counter}.States.Drinking(1)-session.SessionData.RawEvents.Trial{1, counter}.States.TargetLightOn(1);
            elseif isfield(session.SessionData.RawEvents.Trial{1, counter}.States, 'LightOn')==1
                            TE.reactionTime(tcounter)= session.SessionData.RawEvents.Trial{1,counter}.States.Drinking(1)-session.SessionData.RawEvents.Trial{1, counter}.States.LightOn(1);
            end

                               
        elseif ~isnan(session.SessionData.RawEvents.Trial{1,counter}.States.Punish(1))% punish trials
            TE.trialOutcome(tcounter) = 0;
                            if isfield(session.SessionData.RawEvents.Trial{1,counter}.States, 'EarlyWithdrawalCue')==1 ||...,
                                    isfield(session.SessionData.RawEvents.Trial{1,counter}.States, 'EarlyWithdrawalFP')==1
                                    %filters punish due to early withdrawal during cue
                                        if session.SessionData.RawEvents.Trial{1,counter}.States.Punish(1)== session.SessionData.RawEvents.Trial{1,counter}.States.EarlyWithdrawalCue(end)
                                                TE.trialOutcome(tcounter) = NaN;
                                    %filters punsih due to early withdrawal during foreperiod
                                        elseif session.SessionData.RawEvents.Trial{1,counter}.States.Punish(1)== session.SessionData.RawEvents.Trial{1,counter}.States.EarlyWithdrawalFP(end)
                                                TE.trialOutcome(tcounter) = NaN;

                                        end
                            end
        else
            TE.trialOutcome(tcounter) = NaN;
            TE.reactionTime(tcounter)= NaN;
        end
        tcounter = tcounter + 1; % don't forget :)
        
    end
    
end

sessionNames = unique(TE.filename);
for counter = 1:length(sessionNames)
    sname = sessionNames{counter};
    TE.sessionIndex(cellfun(@(x) strcmp(x, sname), TE.filename)) = counter;
end
TE.sessionChange = [0 diff(TE.sessionIndex)];
end
% 
