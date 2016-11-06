function Posner_stage3_analysis(filename, filepath) 

    if nargin < 1 || isempty(filename) % interactive loading
        [filename, filepath] = uigetfile('*Session*.mat', 'select session');
        if ~filename
            sessions=[];
            return
        end
    end


    %% edit file path and filename
    % filepath = 'Z:\B309_rig2\Data\Posner_1\Posner_Stage3\Session Data';

    % filename = 'Posner_1_Posner_Stage3_Nov01_2016_Session1.mat';


    %% this section is constant

    load(fullfile(filepath, filename));

    figName = filename(1:end-4); % strip off the extension
    % make new folder named after the session
    datafolder = fullfile(filepath, figName);
    ensureDirectory(datafolder);
    cd(datafolder);
    nTrials = SessionData.nTrials;
    trialTypes = SessionData.TrialTypes'; % make column vector
    trialOutcomes = SessionData.TrialOutcomes'; % make column vector
    correctPort = (mod(trialTypes, 2) == 0) + 1; % L = 1, R = 2

    correctTrials = trialOutcomes == 1;
    correctTrialIndices = find(correctTrials); % finding all the non-zero elements in correctTrials
    nCorrectTrials = length(correctTrialIndices); % # of correct trials
    nTrialTypes = length(unique(trialTypes));

    % correctTrialsByType = zeros(nTrials, nTrialTypes); % initializing as zeros advantageous- you can use find and not get screwed by NaNs, these are indexes anyway...
    % for counter = 1:nTrialTypes
    %     correctTrialsByType(:, counter)= trialOutcomes == 1 & trialTypes == counter;
    % end
    simpleRTs = NaN(nTrials, 1);
    movementTimes = NaN(nTrials, 1);
    totalRTs = NaN(nTrials, 1);


    for trial = correctTrialIndices'
        % lightOn = light comes on
        targetLightOn = SessionData.RawEvents.Trial{trial}.States.Target(1);% light on time for a given trial

    % determine simple reaction time (port 2 withdrawal)    
        simpleRT = NaN;
        if isfield(SessionData.RawEvents.Trial{trial}.Events, 'Port2Out')
            timeDiffs1 = SessionData.RawEvents.Trial{trial}.Events.Port2Out - targetLightOn;
            simpleRT = timeDiffs1(find(timeDiffs1 > 0, 1));
            if isempty(simpleRT) % firstPositive1 could be [] (empty) if the user cancels while mouse is in the poke (unlikely)     
                simpleRT = NaN;
            end
        end
    % determine total reaction time (simple + movement)
        totalRT = SessionData.RawEvents.Trial{trial}.States.Reward(1) - targetLightOn;
        movementTime = totalRT - simpleRT;
        simpleRTs(trial) = simpleRT;
        movementTimes(trial) = movementTime;
        totalRTs(trial) = totalRT;
    end

    validSimpleRTs.data = simpleRTs(trialOutcomes == 1 & ismember(trialTypes, [1 2]));
    [validSimpleRTs.sorted validSimpleRTs.index]= cum(validSimpleRTs.data);
    invalidSimpleRTs.data = simpleRTs(trialOutcomes == 1 & ismember(trialTypes, [3 4]));
    [invalidSimpleRTs.sorted invalidSimpleRTs.index]= cum(invalidSimpleRTs.data);
    validMovementTimes.data = movementTimes(trialOutcomes == 1 & ismember(trialTypes, [1 2]));
    [validMovementTimes.sorted validMovementTimes.index]= cum(validMovementTimes.data);
    invalidMovementTimes.data = movementTimes(trialOutcomes == 1 & ismember(trialTypes, [3 4]));
    [invalidMovementTimes.sorted invalidMovementTimes.index]= cum(invalidMovementTimes.data);
    validTotalRTs.data = totalRTs(trialOutcomes == 1 & ismember(trialTypes, [1 2]));
    [validTotalRTs.sorted validTotalRTs.index]= cum(validTotalRTs.data);
    invalidTotalRTs.data = totalRTs(trialOutcomes == 1 & ismember(trialTypes, [3 4]));
    [invalidTotalRTs.sorted invalidTotalRTs.index]= cum(invalidTotalRTs.data);

    correctLeft = trialOutcomes == 1 & ismember(trialTypes, [1 3]);
    totalLeft = ismember(trialOutcomes, [0 1 2])  & ismember(trialTypes, [1 3]);
    correctRight = trialOutcomes == 1 & ismember(trialTypes, [2 4]);
    totalRight = ismember(trialOutcomes, [0 1 2])  & ismember(trialTypes, [2 4]);

    winsize = 20; % 20 trial sum
    h = ensureFigure('Posner_stage3_Performance', 1);
    subplot(2,1,1);
    plot(movsum(correctLeft, winsize) ./ movsum(totalLeft, winsize), 'g'); hold on;
    plot(movsum(correctRight, winsize) ./ movsum(totalRight, winsize), 'r');
    legend({'Left', 'Right'}, 'Box', 'off');

    ts = sprintf('Fraction Correct: Total- %0.1f Left- %0.1f Right- %0.1f',...
        sum(correctLeft | correctRight)/sum(totalLeft | totalRight),...
        sum(correctLeft)/sum(totalLeft),...
        sum(correctRight)/sum(totalRight)...
        );

    subplot(2,1,2);
    textAxes(gca, ts);
    
    
    saveas(gcf, 'Posner_stage3_Performance.fig');
    saveas(gcf, 'Posner_stage3_Performance.jpg');



    %
    nBars = 30;
    h = ensureFigure('Posner_stage3_RTs', 1);
    mcPortraitFigSetup(h);
    subplot(2,2,1);
    histogram(simpleRTs, nBars, 'FaceColor', 'r'); hold on;
    histogram(totalRTs, nBars, 'FaceColor', 'b');
    set(gca, 'XLim', [0 5]);
    xlabel('Simple and total reaction times (s)');
    title(figName, 'Interpreter', 'none');



    %%

    subplot(2,2,2);
    plot(validSimpleRTs.sorted, validSimpleRTs.index, 'g'); hold on;
    plot(invalidSimpleRTs.sorted, invalidSimpleRTs.index, 'r');
    % set(gca, 'XLim', [0 5]);
    xlabel('Simple Reaction Time (s)');
    title('RTs, valid (g), invalid (r)');

    subplot(2,2,3);
    plot(validMovementTimes.sorted, validMovementTimes.index, 'g'); hold on;
    plot(invalidMovementTimes.sorted, invalidMovementTimes.index, 'r');
    % set(gca, 'XLim', [0 5]);
    xlabel('MovementTime (s)');
    title('RTs, valid (g), invalid (r)');

    subplot(2,2,4);
    plot(validTotalRTs.sorted, validTotalRTs.index, 'g'); hold on;
    plot(invalidTotalRTs.sorted, invalidTotalRTs.index, 'r');
    % set(gca, 'XLim', [0 5]);
    xlabel('Total Reaction Time (s)');
    title('RTs, valid (g), invalid (r)');


    %%
    % subplot(2,2,4);
    % title(['Pcorrect = ' num2str(length(correctTrialIndices) / nTrials)]);

    saveas(h, fullfile(filepath, [figName '.fig']));
    saveas(h, fullfile(filepath, [figName '.jpg']));
    
    cd('..');
end



function y = movsum(x, N)
    x = double(x);
    y = conv(x,ones(N,1), 'same');
end
  

function  textAxes(ax, txt)   
    fsize = 10;
    text(...
        'String', txt,...
        'Units', 'normalized',...
        'Position', [.5 .5],...
        'FontSize', fsize,...
        'HorizontalAlignment', 'center',...
        'VerticalAlignment', 'middle',...
        'Interpreter', 'none',...
        'Parent', ax...
        );
end

function [sorted index]=cum(a)
    % for generation of cumulative probability plots
    
    if numel(a) ~= length(a)
        disp('error in cum: input argument not a row or column vector');
        return
    end
    
    a = a(~isnan(a));
    
    sorted = sort(a);
    index = (0:numel(a) - 1) / (numel(a) - 1);
end


