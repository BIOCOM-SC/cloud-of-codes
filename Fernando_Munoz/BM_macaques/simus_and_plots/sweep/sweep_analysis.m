clear;

% Number of samples per parameter swept
N_samples = 20;  

%% Read data

data = readmatrix('./results_sweep.txt');

relevant_params_indexes = [1, 2, 3, 7, 8, 14, 15, 17];
all_labels      = {'v0', 'f_imm', 'r0', 'fr0dev', 'f_rimm', 'frimmdev', 'b', ...
                   'nata', 'f', 'tmax', 'dt', 'n', 'a', 'rmin', 'n0', 'fndev', ...
                   'tc', 'ftcdev', 'tmin'};
relevant_labels = all_labels(relevant_params_indexes);

parameters = data(:, relevant_params_indexes);

%% Split results by output variable

results = data(:, 20:end);

% Mark entire row as erroneous if first column is -1
for i = 1:size(results, 1)
    if results(i, 1) == -1
        results(i, :) = -1;
    end
end

NC_res  = results(:, 1:80);
NM_res  = results(:, 81:160);
NMD_res = results(:, 161:240);
NMI_res = results(:, 241:320);
VFC_res = results(:, 321:400);
MAC_res = results(:, 401:480);

write_data(NC_res, NM_res, NMD_res, NMI_res, VFC_res, MAC_res);

%% Experimental results

exp_days    = [21, 53, 77];
exp_results = readmatrix("./experimental_results.txt");

NC_exp      = exp_results(1,  :);
NC_dev_exp  = exp_results(2,  :);
NM_exp      = exp_results(3,  :);
NM_dev_exp  = exp_results(4,  :);
NMD_exp     = exp_results(5,  :);
NMD_dev_exp = exp_results(6,  :);
NMI_exp     = exp_results(7,  :);
NMI_dev_exp = exp_results(8,  :);
VFC_exp     = exp_results(9,  :);
VFC_dev_exp = exp_results(10, :);
MAC_exp     = exp_results(11, :);
MAC_dev_exp = exp_results(12, :);

%% Build colour map (blue -> grey -> red, one colour per sample)

num_rows  = N_samples;
half_rows = floor(num_rows / 2);
blue_to_gray = [linspace(0,   0.5, half_rows)',          ...
                linspace(0,   0.5, half_rows)',          ...
                linspace(1,   0.5, half_rows)'];
gray_to_red  = [linspace(0.5, 1,   num_rows - half_rows)', ...
                linspace(0.5, 0,   num_rows - half_rows)', ...
                linspace(0.5, 0,   num_rows - half_rows)'];
cmap = [blue_to_gray; gray_to_red];

%% Bundle output groups for cleaner loop

output_groups = {NC_res, NM_res, VFC_res, NMD_res, NMI_res, MAC_res};
exp_means     = {NC_exp,  NM_exp,  VFC_exp,  NMD_exp,  NMI_exp,  MAC_exp};
exp_devs      = {NC_dev_exp, NM_dev_exp, VFC_dev_exp, NMD_dev_exp, NMI_dev_exp, MAC_dev_exp};
out_titles    = {'NC', 'NM', 'VFC', 'NMD', 'NMI', 'MAC'};
ylims         = [0 25; 0 150; 0 0.14; 0 100; 0 100; 0 22];

%% Plots — one figure per swept parameter

for kk = 1:numel(relevant_params_indexes)

    indexes   = (kk-1) * N_samples + (1:N_samples);
    param_vec = parameters(indexes, kk);

    % Colorbar tick labels based on actual parameter range
    p_min  = min(param_vec);
    p_max  = max(param_vec);
    p_mid  = param_vec(round(num_rows / 2));
    tick_labels = {sprintf('%.2f', p_min), sprintf('%.2f', p_mid), sprintf('%.2f', p_max)};

    figure;

    for s = 1:6
        res = output_groups{s};

        subplot(2, 3, s);
        hold on;

        j = 1;
        for i = indexes
            if res(i, 1) ~= -1          % check validity per output group
                plot(res(i, :), 'Color', cmap(j, :), 'LineWidth', 1.5);
            end
            j = j + 1;
        end

        plot(exp_days, exp_means{s}, 'ko', 'LineWidth', 2);
        errorbar(exp_days, exp_means{s}, exp_devs{s}, ...
                 'LineStyle', 'none', 'Color', 'black', 'LineWidth', 1);

        title(out_titles{s});
        ylim(ylims(s, :));
        xlabel('Time');
        ylabel('Value');
        grid on;

        colormap(cmap);
        c = colorbar;
        c.Ticks      = [0, 0.5, 1];
        c.TickLabels = tick_labels;

        hold off;
    end

    sgtitle("Variation of outputs for a range of " + relevant_labels{kk});
end

%% -----------------------------------------------------------------------
%  Local functions
%  -----------------------------------------------------------------------

function out = remove_erroneous_samples(data)
    mask = data(:, 1) == -1;
    out  = data(~mask, :);
end

function write_data(nc, nm, nmd, nmi, vfc, mac)
    groups   = {nc, nm, nmd, nmi, vfc, mac};
    n_rows   = size(nc, 1);   % avoid hardcoded 160
    file_id  = fopen("sweep.txt", "wt");
    for g = 1:numel(groups)
        for i = 1:80
            for j = 1:n_rows
                fprintf(file_id, "%f, ", groups{g}(j, i));
            end
            fprintf(file_id, "\n");
        end
        fprintf(file_id, "\n\n");
    end
    fclose(file_id);
end
