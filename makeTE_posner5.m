% Suelynn analysis development script

function TE = makeTE_posner5(TE)
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
    %by default, TE... filled with NaN unless conditions are met
    TE = struct(...
        'filename', {},... 
        'trialNumber', zeros(nTrials, 1),...
        'trialType', zeros(nTrials, 1),...  % e.g. left or right
        'validTrial', zeros(nTrials, 1),...
        'invalidTrial', zeros(nTrials, 1),...
        'foreperiod', zeros(nTrials, 1),...
        'trialOutcome', NaN(nTrials, 1),...  % e.g.  correct = 1, incorrect = 0
        'reactionTime', NaN(nTrials, 1),... % involve sutracting two numbers dug out of session.SessionData.RawEvents.Trial{1}
        'reactionMoving', NaN(nTrials, 1),...
        'reactionSimple', NaN(nTrials, 1),...
        'sessionIndex', NaN(nTrials, 1),...
        'sessionChange', NaN(nTrials, 1)...
    );
    TE(1).filename = cell(nTrials, 1);
else
    startIndex = length(TE.filename);
    % extend all fields from startIndex
    TE.filename{startIndex + nTrials} = ''; % automatically extend
    TE.trialNumber = [TE.trialNumber ; zeros(nTrials, 1)];
    TE.trialType = [TE.trialType; zeros(nTrials, 1)];  % e.g. left or right
    TE.validTrial = [TE.validTrial; zeros(nTrials, 1)];  % e.g. left or right
    TE.invalidTrial= [TE.invalidTrial; NaN(nTrials, 1)];  % e.g. left or right
    TE.trialOutcome = [TE.trialOutcome; NaN(nTrials, 1)];  % e.g.  correct = 1, incorrect = 0
    TE.reactionTime = [TE.reactionTime; NaN(nTrials, 1)]; % involve sutracting two numbers dug out of session.SessionData.RawEvents.Trial{1}
    TE.reactionMoving = [TE.reactionMoving; NaN(nTrials, 1)]; 
    TE.reactionSimple = [TE.reactionSimple; NaN(nTrials, 1)];     
    TE.foreperiod = [TE.foreperiod; NaN(nTrials, 1)];
    TE.sessionIndex = [TE.sessionIndex; NaN(nTrials, 1)];
    TE.sessionChange = [TE.sessionChange; NaN(nTrials, 1)];
end


    


tcounter = 1;
for sCounter = 1:length(sessions)
    session = sessions(sCounter);
        
    for counter = 1:session.SessionData.nTrials
        
        % stuff for all trials
        
        %For ITI calculation    
        TE.TrialStartTimeStamp(tcounter)= session.SessionData.TrialStartTimestamp(counter);
        TE.trialType(tcounter) = session.SessionData.Transf(counter);
        
        if TE.trialType(tcounter) == 1 || TE.trialType(tcounter) == 2 %sort trial types into valid/invalid trials
             TE.validTrial(tcounter)=1;
             TE.invalidTrial(tcounter)=0;
        else
             TE.validTrial(tcounter)=0;
             TE.invalidTrial(tcounter)=1;
        end


         %% ReactionTime-Simple and Moving (Valid)

         if ~isnan(session.SessionData.RawEvents.Trial{1,counter}.States.Drinking(1)) && TE.validTrial(tcounter)==1
            TE.valid_outcome(tcounter) = 1;
            %simple reactionTime

            TE.valid_reactionTimeSimple (tcounter)=session.SessionData.RawEvents.Trial{1,counter}.States.TargetLightOn(1)-session.SessionData.RawEvents.Trial{1, counter}.Events.Port2Out(1);

            if TE.valid_reactionTimeSimple (tcounter) <=0 && length(session.SessionData.RawEvents.Trial{1, counter}.Events.Port2Out) >1
                %fixes glitch caused by re entry into center
                %port after receipt of reward
                for i=1:length(session.SessionData.RawEvents.Trial{1, counter}.Events.Port2Out);
                   valid_reactionTimetest(i)=session.SessionData.RawEvents.Trial{1,counter}.States.TargetLightOn(1)-session.SessionData.RawEvents.Trial{1, counter}.Events.Port2Out(i);
                   valid_reactionTimetest(valid_reactionTimetest <= 0) = NaN;
                end

                TE.valid_reactionTimeSimple(tcounter)=min(valid_reactionTimetest);
            end

                    %movingRT (i.e. movement time between end of withdrawal
                    %from center port-beginning of TargetLightOn-and entry into reward port)
                    TE.valid_reactionTime (tcounter)=session.SessionData.RawEvents.Trial{1,counter}.States.Drinking(1)-session.SessionData.RawEvents.Trial{1, counter}.States.TargetLightOn(1);
                    TE.valid_reactionTimeMoving (tcounter)= TE.valid_reactionTime (tcounter)-TE.valid_reactionTimeSimple(tcounter);


         elseif ~isnan(session.SessionData.RawEvents.Trial{1,counter}.States.Punish(1)) && TE.validTrial(tcounter)==1 

            TE.valid_outcome(tcounter) = 0;

            if session.SessionData.RawEvents.Trial{1,counter}.States.Punish(1)== session.SessionData.RawEvents.Trial{1,counter}.States.EarlyWithdrawalCue(end)

                TE.valid_outcome(tcounter) = NaN;
        %filters out early withdrawal during foreperiod
            elseif session.SessionData.RawEvents.Trial{1,counter}.States.Punish(1)== session.SessionData.RawEvents.Trial{1,counter}.States.EarlyWithdrawalFP(end)
                TE.valid_outcome(tcounter) = NaN;
            end

         %% ReactionTime-Simple and Moving (Invalid)
         elseif ~isnan(session.SessionData.RawEvents.Trial{1,counter}.States.Drinking(1))  && TE.validTrial(tcounter)==0
            TE.invalid_outcome(tcounter) = 1;
            %simpleRT
            TE.invalid_reactionTimeSimple (tcounter)=session.SessionData.RawEvents.Trial{1,counter}.States.TargetLightOn(1)-session.SessionData.RawEvents.Trial{1, counter}.Events.Port2Out(end);

            if TE.valid_reactionTimeSimple (tcounter) <=0 && length(session.SessionData.RawEvents.Trial{1, counter}.Events.Port2Out) >1
             %fixes glitch caused by re entry into center
             %port after receipt of reward
                for i=1:length(session.SessionData.RawEvents.Trial{1, counter}.Events.Port2Out);
                   valid_reactionTimetest(i)=session.SessionData.RawEvents.Trial{1,counter}.States.TargetLightOn(1)-session.SessionData.RawEvents.Trial{1, counter}.Events.Port2Out(i);
                   valid_reactionTimetest(valid_reactionTimetest <= 0) = NaN;
                end

                TE.valid_reactionTimeSimple(tcounter)=min(valid_reactionTimetest);
            end
            %movingRT (i.e. movement time between end of withdrawal
            %from center port-beginning of TargetLightOn-and entry into reward port) 
            TE.invalid_reactionTimeMoving (tcounter)=session.SessionData.RawEvents.Trial{1,counter}.States.TargetLightOn(end)-session.SessionData.RawEvents.Trial{1, counter}.States.TargetLightOn(end);


            if isfield(session.SessionData.RawEvents.Trial{1,counter}.States, 'LeftRewardDelay') == 1 || ...,
                isfield(session.SessionData.RawEvents.Trial{1,counter}.States, 'RightRewardDelay') ==1
                TE.invalid_reactionTime(tcounter)= (session.SessionData.RawEvents.Trial{1,counter}.States.Drinking(1)-session.SessionData.RawEvents.Trial{1, counter}.States.TargetLightOn(1))...
                    - session.SessionData.TrialSettings(counter).RewardDelay;
             end
         elseif ~isnan(session.SessionData.RawEvents.Trial{1,counter}.States.Punish(1))  && TE.validTrial(tcounter)==0
             TE.invalid_outcome(tcounter) = 0;

             if session.SessionData.RawEvents.Trial{1,counter}.States.Punish(1)== session.SessionData.RawEvents.Trial{1,counter}.States.EarlyWithdrawalCue(end)

                     TE.invalid_outcome(tcounter) = NaN;

             elseif session.SessionData.RawEvents.Trial{1,counter}.States.Punish(1)== session.SessionData.RawEvents.Trial{1,counter}.States.EarlyWithdrawalFP(end)

                     TE.invalid_outcome(tcounter) = NaN;
             end

         end
    

 
                 
        TE.filename{tcounter} = session.filename;
        TE.trialNumber(tcounter) = counter;
        TE.foreperiod(tcounter)= session.SessionData.TrialSettings(counter).foreperiod;
        
        %%overall outcome and RT
        % distinguished by punishment (total)
        if ~isnan(session.SessionData.RawEvents.Trial{1,counter}.States.Drinking(1)) %non-punish trials
            TE.trialOutcome (tcounter) = 1;
%             TE.TrackForeperiodProgress(tcounter)= session.SessionData.TrialSettings(counter).foreperiod;
            TE.reactionTime(tcounter)= session.SessionData.RawEvents.Trial{1,counter}.States.Drinking(1)-session.SessionData.RawEvents.Trial{1, counter}.States.TargetLightOn(1);

%         [valid_sorted, valid_index] = cum(TE.valid_reactionTime);
%         [invalid_sorted, invalid_index] = cum(TE.invalid_reactionTime);
%        
%         elseif ~isnan(session.SessionData.RawEvents.Trial{1,counter}.States.CorrectEarlyWithdrawal(1))
%             TE.trialOutcome (tcounter) = 0.5;
%             TE.TrackForeperiodProgress(tcounter)= session.SessionData.TrialSettings(counter).foreperiod;
        elseif ~isnan(session.SessionData.RawEvents.Trial{1,counter}.States.Punish(1))% punish trials
            TE.trialOutcome(tcounter) = 0;
%             TE.TrackForeperiodProgress(tcounter)= NaN;
%             TE.reactionTime(tcounter)= -(session.SessionData.RawEvents.Trial{1,counter}.States.Punish(1)-session.SessionData.RawEvents.Trial{1, counter}.States.TargetLightOn(1));
                                     
            %filters out early withdrawal during cue and foreperiod
             if session.SessionData.RawEvents.Trial{1,counter}.States.Punish(1)== session.SessionData.RawEvents.Trial{1,counter}.States.EarlyWithdrawalCue(end)
                 TE.trialOutcome(tcounter) = NaN;   
%                                          TE.reactionTime(tcounter)=NaN;

             elseif session.SessionData.RawEvents.Trial{1,counter}.States.Punish(1)== session.SessionData.RawEvents.Trial{1,counter}.States.EarlyWithdrawalFP(end)
                 TE.trialOutcome(tcounter) = NaN;  
%                                          TE.reactionTime(tcounter)=NaN;
             end
        else
            TE.trialOutcome(tcounter) = NaN;
            TE.reactionTime(tcounter)= NaN;
            TE.TrackForeperiodProgress(tcounter)= NaN;
        end
        tcounter = tcounter + 1; % don't forget :)

    
    end
    
end

    
sessionNames = unique(TE.filename);
for counter = 1:length(sessionNames)
    sname = sessionNames{counter};
    TE.sessionIndex(cellfun(@(x) strcmp(x, sname), TE.filename)) = counter;
end
TE.sessionChange = [0; diff(TE.sessionIndex)];

end
% 
