function [features_filt,idx] = run_elastic_net(X, Y,varNames,method, alpha, reps, stability, cv_reps)
arguments
    X % The input matrix for future PLSDA/R. No normalization performed within this function - z-score or log normalize prior if desired
    Y % The response matrix for future PLSDA/R
    varNames % input variable names [REW addition]
    method % either minMSE or 1SE, defines the method to be used when selecting the best feature set
    alpha = 1 % A value between 0 and 1, with 0 being fully elastic net and 1 being regular LASSO
    reps = 500 % The number of repetitions to perform
    stability = 0.8 % The percentage of repetitions a feature must be selected in to be included in the final feature set
    cv_reps = 5 % cross validation repetitions for the internal lasso function - use the same value as for the final PLSDA/R model
end
X_z=X;
% X_z = zscore(table2array(X));
% varNames = X.Properties.VariableNames;
elastic_feat_names = {};
for n = 1:reps
    [b,fitInfo] = lasso(X_z,Y(:,1),'CV',cv_reps,'Alpha',alpha);
    if (strcmp(method, 'minMSE'))
        [~,idx] = min(fitInfo.MSE);
    elseif (strcmp(method, '1SE'))
        idx=max(fitInfo.Index1SE,1);
    end
    temp_name = varNames(any(b(:,idx),2));
    elastic_feat_names = [elastic_feat_names, temp_name];
end
[feature_counts, elastic_feats] = groupcounts((elastic_feat_names)');
features_filt = elastic_feats(feature_counts > reps*stability);
[~,idx] = intersect(varNames,features_filt);
end