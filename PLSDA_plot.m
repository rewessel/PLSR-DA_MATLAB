function [vipScores,vipNames,pAdj,indAccepted,pvals]=PLSDA_plot(model,categories,multilevel)
%% PLSDA plotting, Dolatshahi Lab
%% Author: Remziye Erdogan, 6/25/2021
%INPUT:
%model: data structure containing model statistics, as output by PLSDA_main.
%categories: a cell array defining the names of the groups separated using
%discriminate analysis.
%
%OUTPUT:
%The following plots are generated:
%Scores plot: Scatter plot of X scores.
%Loadings plot: Two bar graphs of variable loadings on LV1 and LV2.
%VIP scores plot: A bar graph of VIP scores, colored by group.

% if no palette is given, assign a color scheme.
if isempty(model.palette)
    palette = [1 0 0; 0 0 1];
else
    palette = model.palette;
end
%determine which group has the lowest mean Xscores value to assign colors.

PLSR_or_PLSDA = 'PLSDA';

%% VIP score calculation and bar plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[vipScores,vipNames]=VIP(model.stats,model.XLoading,model.YLoading,...
    model.XScore,model.varNames,palette,'all',[],model.Ydata,'PLSDA');

%% Univariate statistical analysis and boxplots %%%%%%%%%%%%%%%%%%%%%%%%%%%
[pAdj, indAccepted,pvals] = univar_plot(model.XpreZ,model.Ydata,categories,vipNames,vipScores,model.varNames,palette,multilevel);

%% loadings bar plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loadings_plot(model.XLoading,model.varNames,1,palette,'PLSDA');

%% X scores scatter plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PLSR_or_PLSDA = 'PLSDA';

if model.ncomp == 2
    
    % If 2-class model, plot a simple scatter plot.
    scores_plot(PLSR_or_PLSDA,model.XScore,model.PCTVAR,model.Ydata,[],mean(model.CV_accuracy),model.p_perm,categories,palette);

else
    % If m>2, plot a biplot with loadings and scores next to each other.
    PLSDA_biplot(model.XScore,model.PCTVAR,model.Ydata,categories,mean(model.CV_accuracy(1,:)),model.p_perm,palette,model.XLoading,model.varNames)

end

end
