function [pAdj, indAccepted,p] = univar_plot(X,Y,categories,vipNames,vipScores,varNames,palette,multilevel)
%plot univariate swarmcharts/violin plots for top scoring VIP scores
%(VIP>1)
vipNames = flipud(vipNames);
figure; 
% nplots = length(vipScores(vipScores>1));
nplots = length(vipScores);

for i = 1:width(Y)
 Ygroup(Y(:,i)==1)=i; 
end 
Ygroup = Ygroup';
% Ygroup=Y;

for n = 1:nplots
    nexttile
    % subplot(3,ceil(nplots/3))

    for m = 1:width(Y)
        group = X(Y(:,m)==1,strcmp(string(vipNames(n)),varNames));

        if strcmp(multilevel,'multilevel')
            scatter(ones(1,length(group))*m,group,20,'o','markerfacecolor',...
            palette(m,:),'markeredgecolor','k','markerfacealpha',1); hold on

            if m==1
                line([ones(length(group),1)*m ones(length(group),1)*(m+1)]', ...
                    [X(Y(:,m)==1,strcmp(string(vipNames(n)),varNames)) X(Y(:,m)==0,strcmp(string(vipNames(n)),varNames))]',...
                    'color','k')
            end

        else

            boxchart(m*ones(1,height(group)),group,'markerstyle','none','boxfacecolor',palette(m,:),'boxedgecolor','k','boxwidth',1); hold on
            s = swarmchart(ones(1,length(group))*m,group,20,'o','markerfacecolor',...
                palette(m,:),'markeredgecolor','k','markerfacealpha',0.5);
            s.XJitter = 'density';
            s.XJitterWidth = 0.5;

        end

    end
        xticks([1:1:m]); xticklabels(categories)
        ylabel(vipNames(n));
        xlim([0 m+1])

    if m == 2 & ~strcmp(multilevel,'multilevel') % use a t-test to compare 2 groups
        [h,p(n)]=ttest2(X(Y(:,1)==1,strcmp(string(vipNames(n)),varNames)),...
            X(Y(:,2)==1,strcmp(string(vipNames(n)),varNames)),'Vartype','unequal');
        % [p(n),h]=ranksum(X(Y(:,1)==1,strcmp(string(vipNames(n)),varNames)),...
        %     X(Y(:,2)==1,strcmp(string(vipNames(n)),varNames)));
        title(append('p = ',num2str(p(n),'%0.3f')))
                [pAdj, indAccepted] = findFDR(p, length(p), 0.05);

    elseif m > 2 % use a kruskalwallis test to compare multiple groups
        % make a group variable
        [~,~,stats]=kruskalwallis(X(:,strcmp(string(vipNames(n)),varNames)),Ygroup,'off');
        c=multcompare(stats,'CriticalValueType','dunn-sidak','Display','off');
        p(:,n)=c(:,6);
        pAdj = ''; indAccepted = '';

    elseif strcmp(multilevel,'multilevel')
    
        p(n) = signrank(X(Y(:,m)==1,strcmp(string(vipNames(n)),varNames)), ...
        X(Y(:,m)==0,strcmp(string(vipNames(n)),varNames)));
    
        title(append('p = ',num2str(p(n),'%0.3f')))
        [pAdj, indAccepted] = findFDR(p, length(p), 0.05);

    end        

        %     [~,~,stats]=kruskalwallis(X(:,n),Ygroup,'off');
        % c=multcompare(stats,'CriticalValueType','dunn-sidak','Display','off');
        % p(:,n)=c(:,6);
        % pAdj = ''; indAccepted = '';

 end


end

