clear;
colororder("gem12");

labels = {'v0', 'fvimm', 'r0', 'fr0dev', 'frimm', 'frimmdev', 'b', ...
          'nata', 'f', 'tmax', 'dt', 'n', 'a', 'rmin', 'n0', 'fndev', ...
          'tc', 'ftcdev', 'tmin'};

data_prev = readmatrix('./results_prcc.txt');
data = remove_erroneous_samples(data_prev);

relevant_params_indexes = [1, 2, 3, 7, 8, 14, 15, 17];
labels = labels(relevant_params_indexes);

% Separate parameters and results
parameters = data(:, relevant_params_indexes);
results    = data(:, 20:end);


% results(:, [1:8, 81:88, 161:168, 241:248, 321:328, 401:408]) = 0;

%% Compute PRCC via rank-transform + residual regression

[N, P] = size(parameters);  % N samples, P parameters
M = size(results, 2);       % M output time-points
num_conditioning = P - 1;   % degrees-of-freedom cost of partial correlation

% Rank-transform data (handles ties)
ranked_parameters = tiedrank(parameters);
ranked_results    = tiedrank(results);

prcc_matrix = zeros(P, M);
prcc_se     = zeros(P, M);  % Standard error of each PRCC estimate

for m = 1:M
    for pi = 1:P
        ranks_x      = ranked_parameters(:, pi);
        ranks_y      = ranked_results(:, m);
        ranks_others = ranked_parameters(:, [1:pi-1, pi+1:end]);

        residuals_x = regress_out(ranks_x, ranks_others);
        residuals_y = regress_out(ranks_y, ranks_others);

        R = corrcoef(residuals_x, residuals_y);
        if isnan(R(1,2))
            prcc_matrix(pi, m) = 0;
            prcc_se(pi, m)     = NaN;
        else
            rho = R(1, 2);
            prcc_matrix(pi, m) = rho;
            % SE for partial correlation, accounting for conditioning variables
            prcc_se(pi, m) = sqrt((1 - rho^2) / (N - 2 - num_conditioning));
        end
    end
end

%% Significance threshold

alpha  = 0.05;
t_crit = tinv(1 - alpha/2, N - 2 - num_conditioning);
rho_crit = t_crit / sqrt(t_crit^2 + N - 2 - num_conditioning)

%% Split outputs by variable

PRCC_nc  = prcc_matrix(:, 1:80);
PRCC_nm  = prcc_matrix(:, 81:160);
PRCC_nmd = prcc_matrix(:, 161:240);
PRCC_nmi = prcc_matrix(:, 241:320);
PRCC_vfc = prcc_matrix(:, 321:400);
PRCC_mac = prcc_matrix(:, 401:480);

PRCC_nc_se  = prcc_se(:, 1:80);
PRCC_nm_se  = prcc_se(:, 81:160);
PRCC_nmd_se = prcc_se(:, 161:240);
PRCC_nmi_se = prcc_se(:, 241:320);
PRCC_vfc_se = prcc_se(:, 321:400);
PRCC_mac_se = prcc_se(:, 401:480);

%% PRCC time series (one line per parameter)

figure;
subplot(2,3,1); hold on;
for ii = 1:P; plot(PRCC_nc(ii,:),  'LineWidth', 1.5); end
yline( rho_crit, 'LineWidth', 2); yline(-rho_crit, 'LineWidth', 2);
title('NC'); xlabel('Day'); ylabel('PRCC');

subplot(2,3,2); hold on;
for ii = 1:P; plot(PRCC_nm(ii,:),  'LineWidth', 1.5); end
yline( rho_crit, 'LineWidth', 2); yline(-rho_crit, 'LineWidth', 2);
title('NM'); xlabel('Day'); ylabel('PRCC');

subplot(2,3,3); hold on;
for ii = 1:P; plot(PRCC_vfc(ii,:), 'LineWidth', 1.5); end
yline( rho_crit, 'LineWidth', 2); yline(-rho_crit, 'LineWidth', 2);
title('VFC'); xlabel('Day'); ylabel('PRCC');

subplot(2,3,4); hold on;
for ii = 1:P; plot(PRCC_nmd(ii,:), 'LineWidth', 1.5); end
yline( rho_crit, 'LineWidth', 2); yline(-rho_crit, 'LineWidth', 2);
title('NMD'); xlabel('Day'); ylabel('PRCC');

subplot(2,3,5); hold on;
for ii = 1:P; plot(PRCC_nmi(ii,:), 'LineWidth', 1.5); end
yline( rho_crit, 'LineWidth', 2); yline(-rho_crit, 'LineWidth', 2);
title('NMI'); xlabel('Day'); ylabel('PRCC');

subplot(2,3,6); hold on;
for ii = 1:P; plot(PRCC_mac(ii,:), 'LineWidth', 1.5); end
yline( rho_crit, 'LineWidth', 2); yline(-rho_crit, 'LineWidth', 2);
title('MAC'); xlabel('Day'); ylabel('PRCC');

%% PRCC at final time-point (bar plots with proper SE error bars)

figure;
subplot(2,3,1);
bar(PRCC_nc(:,end)); hold on; ylim([-1,1]);
errorbar(1:P, PRCC_nc(:,end), PRCC_nc_se(:,end), '.k');
yline( rho_crit, 'LineWidth', 2); yline(-rho_crit, 'LineWidth', 2);
xticks(1:P); xticklabels(labels); title('NC');  ylabel('PRCC'); grid on; set(gca,'fontsize',12);

subplot(2,3,2);
bar(PRCC_nm(:,end)); hold on; ylim([-1,1]);
errorbar(1:P, PRCC_nm(:,end), PRCC_nm_se(:,end), '.k');
yline( rho_crit, 'LineWidth', 2); yline(-rho_crit, 'LineWidth', 2);
xticks(1:P); xticklabels(labels); title('NM');  ylabel('PRCC'); grid on; set(gca,'fontsize',12);

subplot(2,3,3);
bar(PRCC_vfc(:,end)); hold on; ylim([-1,1]);
errorbar(1:P, PRCC_vfc(:,end), PRCC_vfc_se(:,end), '.k');
yline( rho_crit, 'LineWidth', 2); yline(-rho_crit, 'LineWidth', 2);
xticks(1:P); xticklabels(labels); title('VFC'); ylabel('PRCC'); grid on; set(gca,'fontsize',12);

subplot(2,3,4);
bar(PRCC_nmd(:,end)); hold on; ylim([-1,1]);
errorbar(1:P, PRCC_nmd(:,end), PRCC_nmd_se(:,end), '.k');
yline( rho_crit, 'LineWidth', 2); yline(-rho_crit, 'LineWidth', 2);
xticks(1:P); xticklabels(labels); title('NMD'); ylabel('PRCC'); grid on; set(gca,'fontsize',12);

subplot(2,3,5);
bar(PRCC_nmi(:,end)); hold on; ylim([-1,1]);
errorbar(1:P, PRCC_nmi(:,end), PRCC_nmi_se(:,end), '.k');
yline( rho_crit, 'LineWidth', 2); yline(-rho_crit, 'LineWidth', 2);
xticks(1:P); xticklabels(labels); title('NMI'); ylabel('PRCC'); grid on; set(gca,'fontsize',12);

subplot(2,3,6);
bar(PRCC_mac(:,end)); hold on; ylim([-1,1]);
errorbar(1:P, PRCC_mac(:,end), PRCC_mac_se(:,end), '.k');
yline( rho_crit, 'LineWidth', 2); yline(-rho_crit, 'LineWidth', 2);
xticks(1:P); xticklabels(labels); title('MAC'); ylabel('PRCC'); grid on; set(gca,'fontsize',12);

%% PRCC for error outputs (columns 481:end)

PRCC_errors    = prcc_matrix(:, 481:end);
PRCC_errors_se = prcc_se(:, 481:end);
error_titles   = {'NC', 'NM', 'NMD', 'NMI', 'VFC', 'A', 'B'};

for k = 1:size(PRCC_errors, 2)
    figure;
    bar(PRCC_errors(:,k)); hold on;
    errorbar(1:P, PRCC_errors(:,k), PRCC_errors_se(:,k), '.k');
    yline( rho_crit, 'LineWidth', 2);
    yline(-rho_crit, 'LineWidth', 2);
    xlabel('Parameters'); ylabel('PRCC');
    title(['PRCC Error ' error_titles{k}]);
    xticks(1:P); xticklabels(labels);
    grid on; ylim([-1,1]); set(gca,'fontsize',15);
end

%% Write output files

write_data(PRCC_nc,  PRCC_nm,  PRCC_nmd,  PRCC_nmi,  PRCC_vfc,  PRCC_mac, ...
           PRCC_nc_se, PRCC_nm_se, PRCC_nmd_se, PRCC_nmi_se, PRCC_vfc_se, PRCC_mac_se);

%% -----------------------------------------------------------------------
%  Local functions
%  -----------------------------------------------------------------------

function residuals = regress_out(target, predictors)
    % Return residuals of target after linearly regressing out predictors.
    X = [ones(size(predictors,1), 1), predictors];
    beta = (X' * X) \ (X' * target);
    residuals = target - X * beta;
end

function out = remove_erroneous_samples(data)
    mask = data(:,1) == -1;
    out  = data(~mask, :);
end

function write_data(PRCC_nc,  PRCC_nm,  PRCC_nmd,  PRCC_nmi,  PRCC_vfc,  PRCC_mac, ...
                    PRCC_nc_se, PRCC_nm_se, PRCC_nmd_se, PRCC_nmi_se, PRCC_vfc_se, PRCC_mac_se)

    % --- Daily time series ---
    fid = fopen("prcc_daily.txt", "wt");
    groups    = {PRCC_nc, PRCC_nm, PRCC_nmd, PRCC_nmi, PRCC_vfc, PRCC_mac};
    for g = 1:numel(groups)
        for i = 1:80
            fprintf(fid, "%f, %f, %f, %f, %f, %f, %f, %f\n", groups{g}(:,i)');
        end
        fprintf(fid, "\n\n");
    end
    fclose(fid);

    % --- Final time-point with SE ---
    groups_se = {PRCC_nc_se, PRCC_nm_se, PRCC_nmd_se, PRCC_nmi_se, PRCC_vfc_se, PRCC_mac_se};
    fid = fopen("prcc_final.txt", "wt");
    for g = 1:numel(groups)
        for i = 1:8
            fprintf(fid, "%d %f %f\n", g, groups{g}(i,end), groups_se{g}(i,end));
        end
        fprintf(fid, "\n\n");
    end
    fclose(fid);
end