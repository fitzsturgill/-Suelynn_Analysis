

%% edit file path and filename
filepath = 'Z:\B309_rig2\Data\Posner_1\Posner_Stage2\Session Data';
cd(filepath);
filename = 'Posner_1_Posner_Stage2_Oct26_2016_Session1.mat';


% this section is constant
load(filename);
figName = filename(1:end-4);
nTrials = SessionData.nTrials;
trialTypes = SessionData.TrialTypes;
trialOutcomes = SessionData.TrialOutcomes;

correctTrials = trialOutcomes == 1;
correctLeftTrials = trialOutcomes == 1 & trialTypes == 1;
correctRightTrials = trialOutcomes == 1 & trialTypes == 2;

correctTrialIndices = find(correctTrials); % finding all the non-zero elements in correctTrials
nCorrectTrials = length(correctTrialIndices); % # of correct trials

reactionTimes = NaN(nTrials, 1);% reaction time
initialSideIn = NaN(nTrials, 1); % 1 or 2 for left and right ports, identity of side port that mouse first pokes into
minRT = 0.15;
for trial = correctTrialIndices
    % lightOn = light comes on
    lightOn = SessionData.RawEvents.Trial{trial}.States.Reward(1);% light on time for a given trial
    correctPort = trialTypes(trial);
    
    firstPositive1 = NaN;
    if isfield(SessionData.RawEvents.Trial{trial}.Events, 'Port1In')
        timeDiffs1 = SessionData.RawEvents.Trial{trial}.Events.Port1In - lightOn;
% firstPositive1 could be [] (empty) if there isn't a poke AFTER lightOn        
        firstPositive1 = timeDiffs1(find(timeDiffs1 > minRT, 1));
        if isempty(firstPositive1)
            firstPositive1 = NaN;
        end
    end
    
    firstPositive3 = NaN;
    if isfield(SessionData.RawEvents.Trial{trial}.Events, 'Port3In')
        timeDiffs3 = SessionData.RawEvents.Trial{trial}.Events.Port3In - lightOn;
% firstPositive3 could be [] (empty) if there isn't a poke AFTER lightOn
        firstPositive3 = timeDiffs3(find(timeDiffs3 > minRT, 1));
        if isempty(firstPositive3)
            firstPositive3 = NaN;
        end  
    end
    
    if correctPort == 1 %left trial
        reactionTimes(trial) = firstPositive1;
    else %right trial
        reactionTimes(trial) = firstPositive3;
    end
    
    if ~(isnan(firstPositive1) || isnan(firstPositive3)) % Mouse went to both ports.
        if firstPositive1 > firstPositive3 
            % Mouse went to left port first.
            initialSideIn(trial) = 1;
        else
            % Mouse went to right port first.
            initialSideIn(trial) = 2;
        end
    elseif isnan(firstPositive1) && isnan(firstPositive3) % Mouse didn't go to either ports.
        initialSideIn(trial) = NaN;
    elseif isnan(firstPositive1) % Mouse only went to Port 3.
        initialSideIn(trial) = 2;
    else % Mouse only went to Port 1.
        initialSideIn(trial) = 1;
    end     
end

%
nBars = 30;
h = ensureFigure('Posner_stage2_summary', 1);
subplot(2,2,1);
hist(reactionTimes, nBars);
set(gca, 'XLim', [0 5]);
xlabel('Total Reaction Time (s)');
title(figName, 'Interpreter', 'none');


leftIndices = find(correctLeftTrials);
rightIndices = find(correctRightTrials);
subplot(2,2,2);

histogram(reactionTimes(correctLeftTrials), nBars,  'FaceColor', 'r');
hold on;
histogram(reactionTimes(correctRightTrials), nBars, 'FaceColor', 'b');
set(gca, 'XLim', [0 5]);
xlabel('Total Reaction Time (s)');
title('RTs by reward side Left-r, Right-b');



sideMatch = initialSideIn == trialTypes';
sideMismatch = initialSideIn ~= trialTypes';
subplot(2,2,3);
histogram(reactionTimes(sideMatch), nBars, 'FaceColor', 'g');
hold on;
histogram(reactionTimes(sideMismatch), nBars, 'FaceColor', 'r');
set(gca, 'XLim', [0 5]);
xlabel('Total Reaction Time (s)');
title('RTs by first poke match (g) mismatch (r)');

subplot(2,2,4);
title(['Pcorrect = ' num2str(length(correctTrialIndices) / nTrials)]);

saveas(h, fullfile(filepath, [figName '.fig']));
saveas(h, fullfile(filepath, [figName '.jpg']));





