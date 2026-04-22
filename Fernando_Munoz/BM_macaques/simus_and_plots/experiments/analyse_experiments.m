clear;

Nsamples = 20;

% Each entry: {input file, output file, swept parameter column index, figure title}
experiments = {
    'results_vaccinated.txt', 'experiment_vaccinated.txt', 17, 'Vaccinated (tc sweep)';
    'results_fimm.txt',       'experiment_fimm.txt',        2, 'Immunisation fraction (fimm sweep)';
};

for e = 1:size(experiments, 1)
    fname_in    = experiments{e, 1};
    fname_out   = experiments{e, 2};
    swept_col   = experiments{e, 3};
    fig_title   = experiments{e, 4};

    data        = readmatrix(fname_in);
    swept_param = data(:, swept_col);
    results     = data(:, 20:end);

    nc  = results(:, 1:80);
    nm  = results(:, 81:160);
    nmd = results(:, 161:240);
    nmi = results(:, 241:320);
    vfc = results(:, 321:400);
    mac = results(:, 401:480);

    write_data(nc, nm, nmd, nmi, vfc, mac, fname_out);
    plot_results(nc, nm, nmd, nmi, vfc, mac, Nsamples, swept_param, fig_title);
end

%% -----------------------------------------------------------------------
%  Local functions
%  -----------------------------------------------------------------------

function plot_results(nc, nm, nmd, nmi, vfc, mac, Nsamples, swept_param, fig_title)
    groups      = {nc, nm, vfc, nmd, nmi, mac};
    out_titles  = {'NC', 'NM', 'VFC', 'NMD', 'NMI', 'MAC'};

    figure;
    for s = 1:6
        subplot(2, 3, s); hold on;
        for i = 1:Nsamples
            plot(groups{s}(i, :));
        end
        title(out_titles{s});
        xlabel('Day'); ylabel('Value');
        hold off;
    end
    sgtitle(fig_title);
end

function write_data(nc, nm, nmd, nmi, vfc, mac, fname_out)
    groups  = {nc, nm, nmd, nmi, vfc, mac};
    n_rows  = size(nc, 1);
    fmt     = [repmat('%f, ', 1, n_rows - 1), '%f\n'];  % no trailing comma

    fid = fopen(fname_out, 'wt');
    for g = 1:numel(groups)
        for i = 1:80
            fprintf(fid, fmt, groups{g}(:, i)');
        end
        fprintf(fid, '\n\n');
    end
    fclose(fid);
end