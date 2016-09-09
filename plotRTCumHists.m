
function plotRTCumHists(TE, trialType)

sessions = unique(TE.sessionIndex);
ensureFigure('figname', 1);
axh = zeros(size(sessions));
colors = {'k', 'r', 'g', 'b', 'y'};
for counter = 1:length(sessions);
    axh(counter) = axes; hold on;
    for i = 1:length(trialType)
        type = trialType(i);
        valid_trials = filterTE(TE, 'trialType', [1,2], 'trialOutcome', 1, 'sessionIndex', sessions(counter));
        invalid_trials=filterTE(TE, 'trialType', [3,4], 'trialOutcome', 1, 'sessionIndex', sessions(counter));
        
%         reactionTime = TE.reactionTime(all(~isnan(TE.reactionTime),2),:);
        
        [valid_sorted, valid_index] = cum(TE.reactionTime(valid_trials));
        [invalid_sorted,invalid_index]=cum(TE.reactionTime(invalid_trials));
        plot(valid_sorted, valid_index);
        hold on;
        plot(invalid_sorted, invalid_index);
    end
end
splayAxisTile;