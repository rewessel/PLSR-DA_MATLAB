function [cv_true, cv_perm, cv_rand, lasso_idx] = crossValidate(X,Y,fullVarNames,kfold,ncomp,niter,alpha,stability,multilevel,lassoReps)
%% Cross-validation framework for Lakudzala et al (2026) - iNTS malaria paper
%% Author:  Remziye Wessel, PhD (Apr 2026)

arguments
    X % Your X data matrix
    Y % Your Y matrix containing class labels
    fullVarNames % A cell array of variable names
    kfold % The number of folds
    ncomp % The number of model components
    niter % The number of times to run cross validation
    alpha % The alpha parameter input to run_elastic_net function
    stability % The stability parameter input to run_elastic_net function
    multilevel % flag if you want to do multilevel preprocessing before
    % scaling and training a model ('multilevel')
    lassoReps % How many times you want to repeat LASSO function (recommend 10<n<100)
end

rng(1); % set random number generator seed

% number of times to do random feature selection and random permutations:
nperm = 10;

% initialize Y prediction matrices
Y_predicted = zeros(size(Y));
Yperm_predicted = zeros(length(Y),width(Y),nperm);
Yrand_predicted = zeros(length(Y),width(Y),nperm);

Yperm = zeros(size(Yperm_predicted));

% initialize CV score vectors
cv_true = zeros(niter,1);
cv_perm = zeros(niter,nperm);
cv_rand = zeros(niter,nperm);

lasso_idx = zeros(niter,width(X));

ia = 0; % initialize ia to an arbitrary number

% if multilevel denoising, set aside normalized data to train models
% this data is NOT used for feature selection.
if strcmp(multilevel,'multilevel')
    % multilevel denoising
    for m = 1:height(X)/2
        pairwise_mean = mean([X(m,:);X(m+height(X)/2,:)]);
        Xml(m,:) = X(m,:) - pairwise_mean;
        Xml(m+height(X)/2,:) = X(m+height(X)/2,:) - pairwise_mean;
    end
end

% Loop through several independent CV iterations (defined by niter)
for i = 1:niter
    
    % partition the data
    if strcmp(multilevel,'multilevel')
        kfold = height(X)/2;
        cvp = cvpartition(height(X)/2,'Kfold',kfold);
    else
        cvp = cvpartition(height(X),'KFold',kfold);
    end

    disp(append('Starting iteration #',string(i),'...'))
    tic

    % train models separately for each fold in cvp (defined by kfold)
    for j = 1:kfold
        disp(append('Starting fold #',string(j),'...'))

        % partition training and testing data sets
        if strcmp(multilevel,'multilevel') % then hold out pairs
            [training_set] = [training(cvp,j);training(cvp,j)];
            [testing_set] = [test(cvp,j);test(cvp,j)];
        else
            [training_set] = training(cvp,j);
            [testing_set] = test(cvp,j);
        end

        % independent feature selection for each fold of training data
        [~,ia] = run_elastic_net(zscore(X(training_set,:)), Y(training_set,:), fullVarNames, 'minMSE',alpha, lassoReps, stability, 5);
        
        % print the lasso selected indices
        ia

        % if the feature selection fails, exit this loop and move on to the
        % next CV fold
        if length(ia)<=1
            disp('Invalid CV partition! Trying again...')
            Y_predicted(testing_set,:) = nan(size(Y(testing_set,:)));
            Yperm_predicted(testing_set,:,:) = nan(length(Y(testing_set,:)),width(Y(testing_set,:)),10);
            Yrand_predicted(testing_set,:,:) = nan(length(Y(testing_set,:)),width(Y(testing_set,:)),10);
            continue
        else 

            lasso_idx(i,ia) = 1; % flag features that got selected by LASSO
            
            % then use multilevel scaled data from before the loops
            if strcmp(multilevel,'multilevel')
                Xmodel = zscore(Xml);
            else
                Xmodel = zscore(X);
            end

            % train  model using true LASSO features
            [~,~,~,~,BETA_true,~,~,~] = plsregress(Xmodel(training_set,ia),Y(training_set,:),ncomp,'cv','resubstitution');
            Y_predicted(testing_set,:) = [ones(size(Xmodel(testing_set,ia),1),1) Xmodel(testing_set,ia)]*BETA_true;

            % train model on equal number of random features
            for k = 1:nperm
                ib = randsample(width(X),length(ia));
                [~,~,~,~,BETA_rand,~,~,~] = plsregress(Xmodel(training_set,ib),Y(training_set,:),ncomp,'cv','resubstitution');
                Yrand_predicted(testing_set,:,k) = [ones(size(Xmodel(testing_set,ib),1),1) Xmodel(testing_set,ib)]*BETA_rand;
            end
            
            % train null model(s) with shuffled labels
            for k = 1:nperm
                Yperm(:,:,k) = Y(randperm(height(Y)),:);
                [~,~,~,~,BETA_perm,~,~,~] = plsregress(Xmodel(training_set,ia),Yperm(training_set,:,k),ncomp,'cv','resubstitution');
                Yperm_predicted(testing_set,:,k) = [ones(size(Xmodel(testing_set,ia),1),1) Xmodel(testing_set,ia)]*BETA_perm;
            end
        
        end
        
    end
    toc

    % calculate CV accuracy for true model after all CV folds are complete
    cv_true(i) = cv_accuracy(Y,Y_predicted);

    % calculate CV accuracy for null models for each indepedent
    % trial (of 10) shuffling labels or choosing random features
    for k = 1:10
        cv_perm(i,k) = cv_accuracy(Yperm(:,:,k),Yperm_predicted(:,:,k));
        cv_rand(i,k) = cv_accuracy(Y,Yrand_predicted(:,:,k));
    end

end

% average across the repetitions of label permutation and random features
cv_perm = mean(cv_perm,2);
cv_rand = mean(cv_rand,2);

end

