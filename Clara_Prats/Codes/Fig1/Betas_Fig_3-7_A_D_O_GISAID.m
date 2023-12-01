clear all
close all
%% !
countries = ["Belgium","Bulgaria","Croatia","Czechia","Denmark","Finland","France","Germany","Ireland","Italy","Latvia","Lithuania","Netherlands","Norway","Poland","Romania","Slovenia","Spain","Sweden","Europe"];

FigA = figure('Position', get(0, 'Screensize'));
hold on
    Variants = {'','Alpha (vs pre-Alpha)','Delta (vs Alpha)','Omicron (vs Delta)'};
    fill([1.5 2.5 2.5 1.5],[0 0 10 10],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none') %per separar visualment onades
for j=1:3
Beta = zeros(length(countries),3);
Errbeta = zeros(length(countries),3);
weightBeta = zeros (length(countries),3);
    for k = 1:length(countries)
    Country = countries{k};
    [plotcolorb,symb] = colorcountry(Country);
opts = spreadsheetImportOptions("NumVariables", 14);
opts.Sheet = Country;
opts.DataRange = "A2:N4";
opts.VariableNames = ["Country_Subs", "Start_Day", "Vaccination", "Fitting_Day_20", "Fitting_Day_60", "Beta", "ErrorBeta", "R0", "ErrorR0", "mean_Rt_20_40", "mean_Rt_60_80", "Population", "Area","Gini"];
opts.VariableTypes = ["string", "string","double","string", "string", "double", "double", "double", "double", "double", "double", "double", "double","double"];
opts = setvaropts(opts, ["Country_Subs", "Start_Day", "Fitting_Day_20", "Fitting_Day_60"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Country_Subs", "Start_Day", "Fitting_Day_20", "Fitting_Day_60"], "EmptyFieldRule", "auto");
BetaR0ADO = readtable(".\BetaR0_27pais_ADO_GISAID.xlsx", opts, "UseExcel", false);

clear opts
    Beta (k,:) = BetaR0ADO.Beta';
    Errbeta (k,:) = BetaR0ADO.ErrorBeta';
    errorbar((j-1/4+k/40),BetaR0ADO.Beta(j),BetaR0ADO.ErrorBeta(j),'vertical',symb,'Color',plotcolorb,'LineWidth',1.5,'MarkerSize',10);
    end
    Beta(end,:) = [];
    Errbeta(end,:) = [];
    weightBeta(end,:) = [];
% BOXPLOT 
        weightBeta(:,j) = 1./Errbeta(:,j);
        q1 = weightedquantile(Beta(:,j), weightBeta(:,j), 0.25);
        q3 = weightedquantile(Beta(:,j), weightBeta(:,j), 0.75);
        median = weightedquantile(Beta(:,j), weightBeta(:,j), 0.5);
        iqr = q3 - q1;
        lower_bound = max(min(Beta(:,j)), q1 - 1.5 * iqr);
        upper_bound = min(max(Beta(:,j)), q3 + 1.5 * iqr);
        ybox = [lower_bound, q1, median, q3, upper_bound];
        line(0.0125+j.*ones(5,1), ybox, 'Color', 'k','LineWidth',1.5);
        patch([(0.0125+j-0.1) (0.0125+j+0.1) (0.0125+j+0.1) (0.0125+j-0.1)], [q1 q1 q3 q3], 'k','FaceColor', 'none','LineWidth',1.5);   
        line([(0.0125+j-0.1) (0.0125+j+0.1)], [median median], 'Color', 'r','LineWidth',1.5);
end

xlabel('SARS-CoV-2 variants wave','FontSize', 16)
xlim([0.5 3.5]); ylim([0 2.5]);
ylabel('Increase in transmissibility \Delta\beta','FontSize', 16)
legend(['',countries], 'Location', 'north', 'Orientation', 'horizontal', 'FontSize', 12,'NumColumns',10);
box on
set(gca, 'Xtick',[0,1,2,3],'XTickLabel', Variants,'FontSize', 16)
hold off

textCaption = ".\Figures_beta_ADO27_GISAID\Beta_ok_Fig3b";
saveas(FigA,textCaption,'png');
saveas(FigA,textCaption,'fig');


%% !
close all
clear all
countries = ["Belgium","Bulgaria","Croatia","Czechia","Denmark","Finland","France","Germany","Ireland","Italy","Latvia","Lithuania","Netherlands","Norway","Poland","Romania","Slovenia","Spain","Sweden","Europe"];

FigB = figure('Position', get(0, 'Screensize'));
fig = tiledlayout(1,3); 

for j=1:3
% FigAAbis = figure('Position', get(0, 'Screensize'));
% hold on
nexttile;

    for k = 1:length(countries)
    Country = countries{k};
    [plotcolorb,symb] = colorcountry(Country);
opts = spreadsheetImportOptions("NumVariables", 14);
opts.Sheet = Country;
opts.DataRange = "A2:N4";
opts.VariableNames = ["Country_Subs", "Start_Day", "Vaccination", "Fitting_Day_20", "Fitting_Day_60", "Beta", "ErrorBeta", "R0", "ErrorR0", "mean_Rt_20_40", "mean_Rt_60_80", "Population", "Area","Gini"];
opts.VariableTypes = ["string", "string","double","string", "string", "double", "double", "double", "double", "double", "double", "double", "double","double"];
opts = setvaropts(opts, ["Country_Subs", "Start_Day", "Fitting_Day_20", "Fitting_Day_60"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Country_Subs", "Start_Day", "Fitting_Day_20", "Fitting_Day_60"], "EmptyFieldRule", "auto");
BetaR0ADO = readtable(".\BetaR0_27pais_ADO_GISAID.xlsx", opts, "UseExcel", false);
clear opts

    BetaR0ADO.Onada5percent = datetime(BetaR0ADO.Start_Day,'InputFormat','dd-MMM-yyyy','Format','dd/MM/yyyy');
    errorbar(BetaR0ADO.Onada5percent(j),BetaR0ADO.Beta(j),BetaR0ADO.ErrorBeta(j),'vertical',symb,'Color',plotcolorb,'LineWidth',1.5,'MarkerSize',10);
    hold on
    Beta (k,:) = BetaR0ADO.Beta';
    Errbeta (k,:) = BetaR0ADO.ErrorBeta';
    Datareal (k,:) = BetaR0ADO.Onada5percent';
    x(k) = datenum(BetaR0ADO.Onada5percent(j));
    end

    Beta (end,:) = [];
    Errbeta (end,:) = [];
    Datareal (end,:) = [];
    x(end) = [];

weights(:) = 1 ./ Errbeta (:,j); % Ponderación basada en errores

ft = fittype('a * x + b');
opts = fitoptions('Method', 'LinearLeastSquares', 'Weights', weights);
linear_fit = fit(x', Beta (:,j), ft, opts);
y_fit = feval(linear_fit, x);
SSE = sum(weights' .* (Beta (:,j) - y_fit).^2); 
SST = sum(weights' .* (Beta (:,j) - mean(Beta (:,j))).^2); 
R_squared = 1 - SSE / SST
plot(Datareal(:,j),y_fit, 'r-','LineWidth',1.5);

Start_Day_Num = datenum(datetime(Datareal (:,j), 'InputFormat', 'dd/MM/yyyy'));
[rho, pval_rho] = corr(Start_Day_Num, Beta(:,j), 'Type', 'Spearman');
disp(['Spearman correlation coefficient: ', num2str(rho)])
disp(['p-value for Spearman correlation: ', num2str(pval_rho)])

% outliers
xx = Start_Day_Num;
y = Beta(:,j);
% Calcular cuartiles y rango intercuartil (IQR)
Q1_x = quantile(xx, 0.25);
Q3_x = quantile(xx, 0.75);
IQR_x = Q3_x - Q1_x;
Q1_y = quantile(y, 0.25);
Q3_y = quantile(y, 0.75);
IQR_y = Q3_y - Q1_y;
outliers_x = (xx < (Q1_x - 1.5 * IQR_x)) | (xx > (Q3_x + 1.5 * IQR_x));
outliers_y = (y < (Q1_y - 1.5 * IQR_y)) | (y > (Q3_y + 1.5 * IQR_y));
outliers = outliers_x | outliers_y;
x_no_outliers = xx(~outliers);
y_no_outliers = y(~outliers);

% Spearman 
[rho_no_outliers, pval_rho_no_outliers] = corr(x_no_outliers, y_no_outliers, 'Type', 'Spearman');
disp(['Spearman correlation coefficient without outliers: ', num2str(rho_no_outliers)])
disp(['p-value for Spearman correlation without outliers: ', num2str(pval_rho_no_outliers)])

ylim([0 Inf]);
        if j==1
            ylabel('\Delta\beta pre-Alfa vs Alfa','FontSize', 18)
            ylim([0.1 1])
            ax = gca;
ax.XAxis.FontSize = 16; 
        elseif j==2
            ylabel('\Delta\beta Alfa vs Delta','FontSize', 18)
            ylim([0.1 1.8])
                        legend([countries,''], 'Location', 'northoutside','FontSize',16,'Orientation','horizontal','NumColumns',10);
                                    xlabel('Date when new VOC exceeds 5%','FontSize', 18)
ax = gca;
ax.XAxis.FontSize = 16; 
        else
            ylabel('\Delta\beta Delta vs Omicron','FontSize', 18)
            ylim([0.6 2.3])
        end
hold off
end
fig.TileSpacing = 'tight';
fig.Padding = 'tight';
ax = gca;
ax.XAxis.FontSize = 18; 
textCaption = ".\Figures_beta_ADO27_GISAID\Beta_ok_Fig4b";
saveas(FigB,textCaption,'png');


%% Estadística BB: segons tamany
close all
clear all
countries = ["Belgium","Bulgaria","Croatia","Czechia","Denmark","Finland","France","Germany","Ireland","Italy","Latvia","Lithuania","Netherlands","Norway","Poland","Romania","Slovenia","Spain","Sweden"];
FigBB = figure
for j=1:3
    subplot(1,3,j)
hold on
    for k = 1:length(countries)
        Country = countries{k};
        [plotcolorb,symb] = colorcountry(Country);
opts = spreadsheetImportOptions("NumVariables", 14);
opts.Sheet = Country;
opts.DataRange = "A2:N4";
opts.VariableNames = ["Country_Subs", "Start_Day", "Vaccination", "Fitting_Day_20", "Fitting_Day_60", "Beta", "ErrorBeta", "R0", "ErrorR0", "mean_Rt_20_40", "mean_Rt_60_80", "Population", "Area","Gini"];
opts.VariableTypes = ["string", "string","double","string", "string", "double", "double", "double", "double", "double", "double", "double", "double","double"];
        opts = setvaropts(opts, ["Country_Subs", "Start_Day", "Fitting_Day_20", "Fitting_Day_60"], "WhitespaceRule", "preserve");
        opts = setvaropts(opts, ["Country_Subs", "Start_Day", "Fitting_Day_20", "Fitting_Day_60"], "EmptyFieldRule", "auto");
        BetaR0ADO = readtable(".\BetaR0_27pais_ADO_GISAID.xlsx", opts, "UseExcel", false);
        clear opts
         Beta (k,:) = BetaR0ADO.Beta';
         Errbeta (k,:) = BetaR0ADO.ErrorBeta';
         superficie (k,:) = BetaR0ADO.Area(:)';
        errorbar(log10(BetaR0ADO.Area(j)),BetaR0ADO.Beta(j),BetaR0ADO.ErrorBeta(j),'vertical',symb,'Color',plotcolorb,'LineWidth',1.5,'MarkerSize',10);
    end
% superficie_norm(:,j) = (superficie(:,j) - min(superficie(:,j))) / (max(superficie(:,j)) - min(superficie(:,j)));
% velocidad_norm(:,j) = (Beta (:,j) - min(Beta (:,j)  )) / (max(Beta (:,j)  ) - min(Beta (:,j)  ));
% X = [superficie_norm(:,j), velocidad_norm(:,j)];
% [idx, C] = kmeans(X, 2);
% 20 paisos
if j==2
    idx = [1;1;1;1;1;1;2;2;1;2;1;0;1;2;2;1;1;2;2];
else
    idx = [1;1;1;1;1;1;2;2;1;2;1;1;1;2;2;1;1;2;2];
end
media_velocidad_cluster1 = mean(Beta (idx == 1,j));
media_velocidad_cluster2 = mean(Beta (idx == 2,j));
median_velocidad_cluster1 = median(Beta (idx == 1,j));
median_velocidad_cluster2 = median(Beta (idx == 2,j));
[h, p] = ttest2(Beta (idx == 1,j), Beta (idx == 2,j));

[rhopetit, pval_rhopetit] = corr(superficie (idx == 1,j), Beta (idx == 1,j), 'Type', 'Spearman');
disp(['Spearman correlation coefficient (petit): ', num2str(rhopetit)])
disp(['p-value for Spearman correlation (petit): ', num2str(pval_rhopetit)])

[rhogran, pval_rhogran] = corr(superficie (idx == 2,j), Beta (idx == 2,j), 'Type', 'Spearman');
disp(['Spearman correlation coefficient (gran): ', num2str(rhogran)])
disp(['p-value for Spearman correlation (gran): ', num2str(pval_rhogran)])
box on
        if j==1
            ylabel('Increase in transmissibility \Delta\beta','FontSize',16)
            line([0 5.2], [media_velocidad_cluster1 media_velocidad_cluster1], 'Color', 'k','LineStyle','--','LineWidth',1.5);

            line([5.2 8], [media_velocidad_cluster2 media_velocidad_cluster2], 'Color', 'k','LineStyle','-','LineWidth',1.5);
        fill([5.2 8 8 5.2],[0.1 0.1 1 1],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none') %per separar visualment onades

        elseif j==2
%             ylabel('\Delta\beta Alfa vs Delta')
            line([0 5.2], [media_velocidad_cluster1 media_velocidad_cluster1], 'Color', 'k','LineStyle','--','LineWidth',1.5);

            line([5.2 8], [media_velocidad_cluster2 media_velocidad_cluster2], 'Color', 'k','LineStyle','-','LineWidth',1.5);

            xlabel('Country surface area [km^2] (log_{10})','FontSize',16)
        fill([5.2 8 8 5.2],[0.4 0.4 1.8 1.8],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none') %per separar visualment onades
        else
            line([0 5.2], [media_velocidad_cluster1 media_velocidad_cluster1], 'Color', 'k','LineStyle','--','LineWidth',1.5);
            line([5.2 8], [media_velocidad_cluster2 media_velocidad_cluster2], 'Color', 'k','LineStyle','-','LineWidth',1.5);
                weights(:) = 1 ./ Errbeta (idx == 2,j);  
                % Ajust lineal
                ft = fittype('a * x + b');
                opts = fitoptions('Method', 'LinearLeastSquares', 'Weights', weights);
                linear_fit = fit(superficie (idx==2,j), Beta (idx == 2,j), ft, opts);
                y_fit = feval(linear_fit, superficie (idx==2,j));
                SSE = sum(weights' .* (Beta (idx == 2,j) - y_fit).^2); 
                SST = sum(weights' .* (Beta (idx == 2,j) - mean(Beta (idx == 2,j))).^2); 
                R_squared = 1 - SSE / SST
%                 plot(log(superficie (idx==2,j)),y_fit, 'r-');
                fill([5.2 8 8 5.2],[0.6 0.6 2.2 2.2],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none') %per separar visualment onades
                legend([countries,'Mean cluster 1','Mean cluster 2',''], 'Location', 'northoutside','Orientation','horizontal','FontSize',12,'NumColumns',11);        
        end
        xlim([4 6])
        hold off        
end
textCaption = ".\Figures_beta_ADO27_GISAID\Beta_ok_Fig5b";
saveas(FigBB,textCaption,'png');


%% !
close all
clear all
countries = ["Belgium","Bulgaria","Croatia","Czechia","Denmark","Finland","France","Germany","Ireland","Italy","Latvia","Lithuania","Netherlands","Norway","Poland","Romania","Slovenia","Spain","Sweden","Europe"];

FigC=figure
for j=2
    if j==1
        subplot(1,2,1)
    elseif j==3
        subplot(1,2,2)
    end
hold on
    for k = 1:length(countries)
        Country = countries{k};
        [plotcolorb,symb] = colorcountry(Country);
opts = spreadsheetImportOptions("NumVariables", 14);
opts.Sheet = Country;
opts.DataRange = "A2:N4";
opts.VariableNames = ["Country_Subs", "Start_Day", "Vaccination", "Fitting_Day_20", "Fitting_Day_60", "Beta", "ErrorBeta", "R0", "ErrorR0", "mean_Rt_20_40", "mean_Rt_60_80", "Population", "Area","Gini"];
opts.VariableTypes = ["string", "string","double","string", "string", "double", "double", "double", "double", "double", "double", "double", "double","double"];
        opts = setvaropts(opts, ["Country_Subs", "Start_Day", "Fitting_Day_20", "Fitting_Day_60"], "WhitespaceRule", "preserve");
        opts = setvaropts(opts, ["Country_Subs", "Start_Day", "Fitting_Day_20", "Fitting_Day_60"], "EmptyFieldRule", "auto");
        BetaR0ADO = readtable(".\BetaR0_27pais_ADO_GISAID.xlsx", opts, "UseExcel", false);
        clear opts
         Beta (k,:) = BetaR0ADO.Beta';
         Errbeta (k,:) = BetaR0ADO.ErrorBeta';
         Vacuna (k,:) = (100*(BetaR0ADO.Vaccination ./ BetaR0ADO.Population))';
        errorbar(100*(BetaR0ADO.Vaccination(j) ./ BetaR0ADO.Population(j)),BetaR0ADO.Beta(j),BetaR0ADO.ErrorBeta(j),'vertical',symb,'Color',plotcolorb,'LineWidth',1.5,'MarkerSize',10); 
    end

        if j==1
            ylabel('\beta pre-Alfa vs Alfa')
                X = [ones(height(Beta),1), Vacuna(:,1)];
                [b, bint, r, rint, stats] = regress(Beta(:,1), X);
                R_squared = stats(1);
        elseif j==2
            ylabel('\Delta\beta Alfa vs Delta')
                X = [ones(height(Beta),1), Vacuna(:,2)];
                [b, bint, r, rint, stats] = regress(Beta(:,2), X);
                R_squared = stats(1);
                plot([3 15 26],[0.5757 0.8169 1.038],'r','LineWidth',1.5)
                legend([countries], 'Location', 'southeast','Orientation','vertical','FontSize',12);
                xlabel('Population fully vaccinated (%)')

        else
            ylabel('\beta Delta vs Omicron')
            X = [ones(height(Beta),1), Vacuna(:,3)];
                [b, bint, r, rint, stats] = regress(Beta(:,3), X);
                R_squared = stats(1);
                xlabel('Population fully vaccinated (%)')
            legend([countries], 'Location', 'northoutside','Orientation','horizontal','FontSize',11,'NumColumns',10);
        end  
        hold off        

[rho, pval_rho] = corr(Vacuna(:,j),Beta(:,j), 'Type', 'Spearman');
disp(['Spearman correlation coefficient: ', num2str(rho)])
disp(['p-value for Spearman correlation: ', num2str(pval_rho)])


end

% textCaption = ".\Figures_beta_ADO27_GISAID\Beta_ok_Fig6";
% saveas(FigC,textCaption,'png');

%% !
close all
clear all
countries = ["Belgium","Bulgaria","Croatia","Czechia","Denmark","Finland","France","Germany","Ireland","Italy","Latvia","Lithuania","Netherlands","Norway","Poland","Romania","Slovenia","Spain","Sweden","Europe"];

FigC = figure('Position', get(0, 'Screensize'));
title('Rt comparisson')
for j=1:3
subplot(1,3,j)
hold on
    for k = 1:length(countries)
    Country = countries{k};
    [plotcolorb,symb] = colorcountry(Country);
    opts = spreadsheetImportOptions("NumVariables", 14);
    opts.Sheet = Country;
    opts.DataRange = "A2:N4";
    opts.VariableNames = ["Country_Subs", "Start_Day", "Vaccination", "Fitting_Day_20", "Fitting_Day_60", "Beta", "ErrorBeta", "R0", "ErrorR0", "mean_Rt_20_40", "mean_Rt_60_80", "Population", "Area","Gini"];
    opts.VariableTypes = ["string", "string","double","string", "string", "double", "double", "double", "double", "double", "double", "double", "double","double"];
    opts = setvaropts(opts, ["Country_Subs", "Start_Day", "Fitting_Day_20", "Fitting_Day_60"], "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["Country_Subs", "Start_Day", "Fitting_Day_20", "Fitting_Day_60"], "EmptyFieldRule", "auto");
    BetaR0ADO = readtable(".\BetaR0_27pais_ADO_GISAID.xlsx", opts, "UseExcel", false);
    clear opts
    plot(BetaR0ADO.mean_Rt_20_40(j),BetaR0ADO.mean_Rt_60_80(j),symb,'Color',plotcolorb,'LineWidth',1.5,'MarkerSize',10);
    end
        x = [0, 1, 2];
        y = [0, 1, 2];
        plot(x, y,'--','Color','k','LineWidth',1.5)
       
        if j==1
            ylabel('mean Rt 60%-80%','FontSize',14)
            xlim([0.6 1.4])
            ylim([0.8 1.4])
        elseif j==2
            % ylabel('mean Rt 60% - 80%  Alfa vs Delta')
            xlim([0.5 1.2])
            ylim([0.7 1.8])
            xlabel('mean Rt 20%-40%','FontSize',14)
        else
            % ylabel('mean Rt 60% - 80%  Delta vs Omicron')
            xlim([0.6 1.4])
            legend([countries,''], 'Location', 'northoutside','Orientation','horizontal','FontSize',18,'NumColumns',10);
        end

hold off

end

% saveas(FigC,textCaption,'png');