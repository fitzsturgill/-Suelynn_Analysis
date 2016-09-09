function binnedTrials_TE = binnedTrials(TE, binSize, varargin)

 if strcmp('average', varargin)==1
    prebinTrials=TE(1:(end-(rem(length(TE),binSize))));
    binnedTrials_TE=nanmean(reshape(prebinTrials, binSize, []));
elseif strcmp('index', varargin)==1
    prebinTrials=TE(1:(end-(rem(length(TE),binSize))));
    binnedTrials=reshape(prebinTrials, binSize, []);
    binnedTrials=diff(max(binnedTrials));
    binnedTrials_TE=[0 binnedTrials];

 else
     
     display ('error: enter average or index')
    
end
