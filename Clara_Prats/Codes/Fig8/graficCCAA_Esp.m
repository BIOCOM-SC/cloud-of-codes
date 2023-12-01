% Valors de B y R0
B = [0.89388, 0.91709, 0.679, 1.3348, 0.59872, 0.68849, 0.87135, 0.65245];
error_B = [0.10508, 0.12674, 0.078451, 0.2234, 0.064074, 0.15727, 0.066558, 0.05246];
R0 = [0.00020425, 0.0012294, 0.010776, 3.2582e-06, 0.0066017, 0.0035938, 0.0080741, 0.0053773];

comunidades = {'Andalusia', 'Balearic I.', 'Catalonia', 'Castile and Leon', 'Madrid', 'Navarre+Basque C', 'Valencia+Murcia', 'Spain'};

t = 0:1:16; % Ajustar el rango según sea necesario

figure;
hold on;

colores = lines(length(B));

for i = 1:length(B)
    pp = 100*R0(i)*exp(B(i)*t)./(1 + R0(i)*exp(B(i)*t));
    p = movmean(pp,3);
    if comunidades{i} =="Spain"
        plot(t, p,'--', 'Color', [0 0 0],'LineWidth',1.3, 'DisplayName', comunidades{i});
    elseif comunidades{i} =="Valencia+Murcia"
    pp = 100*R0(i)*exp(B(i)*(t-1))./(1 + R0(i)*exp(B(i)*(t-1)));
    p = movmean(pp,3);
            plot(t, p,'Color', colores(i, :),'LineWidth',1.3, 'DisplayName', comunidades{i});
    else
        plot(t, p, 'Color', colores(i, :),'LineWidth',1.3, 'DisplayName', comunidades{i});
    end
end

hold off;

% legend('show','Location','northwest','FontSize',12);
% xlabel('Time (weeks)','FontSize',14);
fechas = {'06-May', '13-May', '20-May', '27-May', '03-Jun', ...
    '10-Jun', '17-Jun', '24-Jun', '01-Jul', '08-Jul', ...
    '15-Jul', '22-Jul', '29-Jul', '05-Aug', '12-Aug', '19-Aug','26-Aug'};

ylabel('% Delta lineage','FontSize',14);
xticklabels(fechas);
fig = gcf;

% saveas(fig, 'comunidades_autonomas.fig');
% saveas(fig, 'comunidades_autonomas.png');


figure;
hold on
for i = 1:length(B)
    if comunidades{i} =="Spain"
        errorbar(1.15,B(i), error_B(i),'x', 'Color', [0 0 0],'LineWidth',1.2, 'DisplayName', comunidades{i},'LineWidth',1.5,'MarkerSize',10);
    elseif i==1 || i==2 || i==3
        errorbar(1-i/5,B(i), error_B(i), 'o','Color', colores(i, :),'LineWidth',1., 'DisplayName', comunidades{i},'LineWidth',1.5,'MarkerSize',10);
    elseif i==4 || i==5 || i==6 || i==7
        errorbar(1+(i-3)/5,B(i), error_B(i), 'o','Color', colores(i, :),'LineWidth',1., 'DisplayName', comunidades{i},'LineWidth',1.5,'MarkerSize',10);
    end
end
C= B(1:(end-1))';
Cerr=error_B(1:(end-1))';

        weightBeta(:) = 1./Cerr(:);
        q1 = weightedquantile(C(:), weightBeta(:), 0.25);
        q3 = weightedquantile(C(:), weightBeta(:), 0.75);
        median = weightedquantile(C(:), weightBeta(:), 0.5);
        iqr = q3 - q1;
        lower_bound = max(min(C(:)), q1 - 1.5 * iqr);
        upper_bound = min(max(C(:)), q3 + 1.5 * iqr);
        ybox = [lower_bound, q1, median, q3, upper_bound];
        line(ones(5,1), ybox, 'Color', 'k','LineWidth',1.5);
        patch([(1-0.1) (1+0.1) (1+0.1) (1-0.1)], [q1 q1 q3 q3], 'k','FaceColor', 'none','LineWidth',1.5);     
        line([(1-0.1) (1+0.1)], [median median], 'Color', 'r','LineWidth',1.5);

set(gca, 'XTickLabel', comunidades, 'XTick',1:numel(comunidades))

legend('show','Location','northwest','FontSize',10);

xlim([0.3 1.9])

fig = gcf;

saveas(fig, 'betes_CCAA.fig');
saveas(fig, 'betes_CCAA.png');


function q = weightedquantile(x, w, p)
    [x, index] = sort(x);
    w = w(index);
    c = cumsum(w);
    totalWeight = sum(w);
    q = interp1(c ./ totalWeight, x, p);
end

