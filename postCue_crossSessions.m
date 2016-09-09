%% graphing for makeTE_posner4
function postCue_crossSessions(TE, varargin)


validTrial=filterTE(TE, 'trialType', [1,2])';
invalidTrial=filterTE(TE, 'trialType', [3,4])';
drinking=filterTE(TE, 'trialOutcome', 1); 
punish=filterTE(TE, 'trialOutcome', 0);
targetLightNotReached = filterTECell(TE, 'TargetLightOn', NaN); % a logical array


% MakeValidMatrix=horzcat(drinking, punish, earlyWithdrawal);
% MakeValidMatrix=bsxfun(@eq, validTrial, MakeValidMatrix);
% 
% MakeInvalidMatrix=horzcat(drinking, punish, earlyWithdrawal);
% MakeInvalidMatrix=bsxfun(@eq, invalidTrial, MakeInvalidMatrix);



binSize = 1;

%% ratio of drinking: punish: early withdrawal

numDrinking=numel(TE.trialOutcome(drinking & validTrial))/numel(TE.trialOutcome(validTrial));
numPunish=numel(TE.trialOutcome(punish & validTrial))/numel(TE.trialOutcome(validTrial));
numEarlyWithdrawal=numel(TE.trialOutcome(targetLightNotReached & validTrial))/numel(TE.trialOutcome(validTrial));

numDrinking_invalid=numel(TE.trialOutcome(drinking & invalidTrial))/numel(TE.trialOutcome(invalidTrial));
numPunish_invalid=numel(TE.trialOutcome(punish & invalidTrial))/numel(TE.trialOutcome(invalidTrial));
numEarlyWithdrawal_invalid=numel(TE.trialOutcome(targetLightNotReached & invalidTrial))/numel(TE.trialOutcome(invalidTrial));

y=[numDrinking, numPunish, numEarlyWithdrawal; 
    numDrinking_invalid, numPunish_invalid, numEarlyWithdrawal_invalid]';
figure; bar(y)
set(gca,'XTickLabel',{'Drinking', 'Punish', 'Early Withdrawal'});
ylabel('Fraction/Trial Type');
legend( 'valid', 'invalid', 'Location', 'northeast', 'FontSize', 12); legend('boxoff');


%% binned trial outcomes and reactionTimes
    
trialOutcomeValid_binned=binnedTrials(TE.trialOutcome (validTrial), binSize, 'average');
trialOutcomeInvalid_binned=binnedTrials(TE.trialOutcome (invalidTrial), binSize, 'average');


ValidreactionTime_binned=binnedTrials(TE.reactionTime(validTrial&drinking), binSize, 'average');
ValidreactionTimeSimple_binned=binnedTrials(TE.reactionTimeSimple (validTrial&drinking), binSize, 'average');
ValidreactionTimeMoving_binned=binnedTrials(TE.reactionTimeMoving (validTrial&drinking), binSize, 'average');
    
InvalidreactionTime_binned=binnedTrials(TE.reactionTime(invalidTrial&drinking), binSize, 'average');
InvalidreactionTimeSimple_binned=binnedTrials(TE.reactionTimeSimple(invalidTrial&drinking), binSize, 'average');
InvalidreactionTimeMoving_binned=binnedTrials(TE.reactionTimeMoving(invalidTrial&drinking), binSize, 'average');


%binned session index
validBinned_sessionIndex = binnedTrials(TE.sessionIndex(validTrial), binSize, 'index');
validDrinkingBinned_sessionIndex = binnedTrials(TE.sessionIndex(validTrial&drinking), binSize, 'index');

invalidDrinkingBinned_sessionIndex = binnedTrials(TE.sessionIndex(invalidTrial&drinking), binSize, 'index');


plotSI_trialOutcome=validBinned_sessionIndex*max(trialOutcomeValid_binned);
plotSI_reactionTime=validDrinkingBinned_sessionIndex*max(ValidreactionTime_binned);
plotSI_InvalidreactionTime=invalidDrinkingBinned_sessionIndex*max(InvalidreactionTime_binned);

% plotSI_reactionTime=sessionIndex_binned*max(reactionTime_binned);
% plotSI_reactionTimeSimple=sessionIndex_binned*max(reactionTimeSimple_binned);
% plotSI_reactionTimeMoving=sessionIndex_binned*max(reactionTimeMoving_binned);

%% plot trial outcomes (correct and incorrect trials)

        outcomeFig = ensureFigure('Outcome_plot', 1);
        outcomeAxes = axes('Parent', outcomeFig);
        % make xData for scatter and stem plots
        xData_valid = 1:binSize:length(trialOutcomeValid_binned)*binSize;
        xData_invalid = 1:binSize:length(trialOutcomeInvalid_binned)*binSize;

        % gather scatter graphic object handles as numeric values into a
        % numeric array
        outcomeHandles=zeros(1,2);
        outcomeHandles(1)= scatter(xData_valid, smooth(trialOutcomeValid_binned)); hold on;
        outcomeHandles(2)= scatter(xData_invalid, smooth(trialOutcomeInvalid_binned)); 

        set(outcomeAxes, 'XLim', [0 max(xData_valid)]);
        set(outcomeAxes, 'YLim', [0 1]);
        % make legend label axes
        % use hanles to create a labeled legend
        legend(outcomeHandles, {'valid', 'invalid'}, 'Location', 'northwest', 'FontSize', 12); legend('boxoff');
        title('Outcomes across sessions (punishment excluding early withdr.'); ylabel('Fraction Correct'); xlabel('binned trial number');     

        stem(xData_valid, plotSI_trialOutcome, 'k', 'marker', 'none')
        %% plot valid reactionTime
        valid_reactionTimeFig = ensureFigure('reactionTime_plot', 1);
        valid_reactionTimeAxes = axes('Parent', valid_reactionTimeFig);
        % make xData for scatter and stem plots
        xData_valid = 1:binSize:length(ValidreactionTime_binned)*binSize;
        % gather scatter graphic object handles as numeric values into a
        % numeric array

        reactionTimeHandles=zeros(1,3);
        reactionTimeHandles (1) = plot(xData_valid, smooth(ValidreactionTime_binned)); hold on;
        reactionTimeHandles (2) = scatter(xData_valid, smooth(ValidreactionTimeSimple_binned)); hold on;
        reactionTimeHandles (3) = scatter(xData_valid, smooth(ValidreactionTimeMoving_binned)); hold on;
%         reactionTimeHandles (4) = plot(xData_invalid, smooth(InvalidreactionTime_binned)); hold on;
%         reactionTimeHandles (5) = scatter(xData_invalid, smooth(InvalidreactionTimeSimple_binned)); hold on;
%         reactionTimeHandles (6) = scatter(xData_invalid, smooth(InvalidreactionTimeMoving_binned)); hold on;
        set(valid_reactionTimeAxes, 'XLim', [0 max(xData_valid)]);
        set(valid_reactionTimeAxes, 'YLim', [0 1]);
        % make legend label axes
        % use hanles to create a labeled legend
        legend(reactionTimeHandles, {'reaction time', 'simple RT', 'moving RT'}, 'Location', 'northwest', 'FontSize', 12); legend('boxoff');
        title('Reaction time across valid sessions (excluding early withdr.)'); ylabel('Fraction Correct'); xlabel('binned trial number');     

        stem(xData_valid, plotSI_reactionTime, 'k', 'marker', 'none')    
        
%% plot invalid reactionTime
        invalid_reactionTimeFig = ensureFigure('invalid reactionTime_plot', 1);
        invalid_reactionTimeAxes = axes('Parent', invalid_reactionTimeFig);
        % make xData for scatter and stem plots
        xData_invalid = 1:binSize:length(InvalidreactionTime_binned)*binSize;

        % gather scatter graphic object handles as numeric values into a
        % numeric array

        invalid_reactionTimeHandles=zeros(1,3);
        invalid_reactionTimeHandles (1) = plot(xData_invalid, smooth(InvalidreactionTime_binned)); hold on;
        invalid_reactionTimeHandles (2) = scatter(xData_invalid, smooth(InvalidreactionTimeSimple_binned)); hold on;
        invalid_reactionTimeHandles (3) = scatter(xData_invalid, smooth(InvalidreactionTimeMoving_binned)); hold on;

        set(invalid_reactionTimeAxes, 'XLim', [0 max(xData_invalid)]);
        set(invalid_reactionTimeAxes, 'YLim', [0 1]);
        % make legend label axes
        % use hanles to create a labeled legend
        legend(invalid_reactionTimeHandles, {'reaction time', 'simple RT', 'moving RT'}, 'Location', 'northwest', 'FontSize', 12); legend('boxoff');
        title('Reaction time across invalid sessions (excluding early withdr.)'); ylabel('Fraction Correct'); xlabel('binned trial number');     

        stem(xData_invalid, plotSI_InvalidreactionTime, 'k', 'marker', 'none')  

%% Cum histogram plots per session

sessions = unique(TE.sessionIndex);
ensureFigure('figname', 1);
axh = zeros(size(sessions));
colors = {'k', 'r', 'g', 'b', 'y'};



% for counter = 1:length(sessions);
for counter=1:length(sessions);
    axh(counter) = axes; hold on;
    sessionIndex = (filterTE(TE, 'sessionIndex', sessions(counter)))';
    
        [valid_sorted, valid_index] = cum(TE.reactionTimeSimple(validTrial&drinking&sessionIndex));
        [invalid_sorted,invalid_index]=cum(TE.reactionTimeSimple(invalidTrial&drinking&sessionIndex));
        
        cumulativeHistHandle=zeros(1,2);
        cumulativeHistHandle(1)= plot(valid_sorted, valid_index); hold on;
        cumulativeHistHandle(2)= plot(invalid_sorted, invalid_index); 
        legend(cumulativeHistHandle, {'valid','invalid'}, 'Location', 'northwest', 'FontSize', 12); legend('boxoff');
        title('Reaction time per session'); ylabel('Cumulative %'); xlabel('Simple reaction time (s)');     
        
%          integral_valid = trapz(valid_sorted,valid_index);
%          integral_invalid = trapz(invalid_sorted,invalid_index);
%          
%          y=[integral_valid; integral_invalid];
%          bar(y); hold on;
%     

     
end

splayAxisTile;

end


    
