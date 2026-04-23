function my_cv_score = cv_accuracy(Y, Y_predicted)
%Y = true labels
%Y_predicted = predicted labels
% calculate CV accuracy scores
    [~,idx]=max(Y_predicted,[],2);
    Y_predicted_new = zeros(size(Y_predicted));
    correct=0;

    for m = 1:height(Y_predicted)
        Y_predicted_new(m,idx(m))=1;
    end

    for n = 1:height(Y)
        if Y(n,:) == Y_predicted_new(n,:) & ~isnan(Y_predicted(n,:))
            correct = correct + 1; 
        end
    end

    my_cv_score = correct/length(Y_predicted(~isnan(Y_predicted(:,1)),1))*100; %correct classification rate

end