clear all;


%% ----------------------- fit A ---------------------------------
data = readmatrix("fitA/dakota.tab", "FileType", "text");
data = data(:, 3:end);

err = data(:, end);

min_err = [];
for ii = 1:length(err)
    min_err = [min_err, min(err(1:ii))];
end

plot(min_err, 'LineWidth', 2); grid on;
xlabel('Function evaluations'); ylabel('Minimum error'); 
ylim([0,10]); xlim([0, 1000]);
title('Evolution of minimum error'); set(gca,'fontsize', 15);
writematrix(min_err', "minerr_fitA.txt");

[a, min_id] = min(err);
params_min = data(min_id, :);
write_params(params_min, "params_fitA.txt");
a

%% ----------------------- fit B ---------------------------------
figure;
data = readmatrix("fitB/dakota.tab", "FileType", "text");
data = data(1:1000, 3:end);

err = data(:, end);

min_err = [];
for ii = 1:length(err)
    min_err = [min_err, min(err(1:ii))];
end

plot(min_err, 'LineWidth', 2); grid on;
xlabel('Function evaluations'); ylabel('Minimum error'); 
title('Evolution of minimum error'); set(gca,'fontsize', 15);
ylim([0,10]); xlim([0, 1000]);
writematrix(min_err', "minerr_fitB.txt");

[a, min_id] = min(err);
params_min = data(min_id, :);
write_params(params_min, "params_fitB.txt");
a

%% -----------------------------------------------------------------------
%  Local functions
%  -----------------------------------------------------------------------

function write_params(params, file_name)
v0 = params(1);
fvimm = params(2);
r0 = params(3);
b = params(4);
nata = params(5);
tc = params(6); 
n0 = params(7);


frimm = fvimm;
n = 1.630;
a = 0.035;
rmin = 0.070;
fr0dev = 0.2;
frimmdev = 0.2;
f = 1;
tmax = 80;
dt = 0.1;
fndev = 0.2;
ftcdev = 0;
tmin = 7;

file_params = fopen(file_name,'wt');
fprintf(file_params, "v0 = %f\n", v0);
fprintf(file_params, "fvimm = %f\n", fvimm);
fprintf(file_params, "r0 = %f\n", r0);
fprintf(file_params, "fr0dev = %f\n", fr0dev);
fprintf(file_params, "frimm = %f\n", frimm);
fprintf(file_params, "frimmdev = %f\n", frimmdev);
fprintf(file_params, "b = %f\n", b);
fprintf(file_params, "nata = %f\n", nata);
fprintf(file_params, "f = %f\n", f);
fprintf(file_params, "tmax = %f\n", tmax);
fprintf(file_params, "dt = %f\n", dt);
fprintf(file_params, "n = %f\n", n);
fprintf(file_params, "a = %f\n", a);
fprintf(file_params, "rmin = %f\n", rmin);
fprintf(file_params, "n0 = %f\n", n0);
fprintf(file_params, "fndev = %f\n", fndev);
fprintf(file_params, "tc = %f\n", tc);
fprintf(file_params, "ftcdev = %f\n", ftcdev);
fprintf(file_params, "tmin = %f\n", tmin);
fclose(file_params);
end