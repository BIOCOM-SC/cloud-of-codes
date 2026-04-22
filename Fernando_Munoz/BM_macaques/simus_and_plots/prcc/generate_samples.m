clear;

Nsamples = 1000;
fname_fitA = "../fits/params_fitA.txt";


% Optimal point:
[v0, fvimm, r0, fr0dev, frimm, frimmdev, beta, nata, f, tmax, dt, n, a, rmin, N0, fndev, tc, ftcdev, tmin] = read_optimal_params(fname_fitA);


% Edit ranges here:
f_low = 0.75;    f_upp = 1.25;

v0_i = v0 * f_low;      v0_f = v0 * f_upp;
fvimm_i = fvimm * f_low;   fvimm_f = fvimm * f_upp;
r0_i = r0 * f_low;        r0_f = r0 * f_upp;
%frimm_i = frimm * f_low;  frimm_f = frimm * f_upp;
beta_i = beta * f_low;   beta_f = beta * f_upp;
nata_i = nata * f_low;   nata_f = nata * f_upp;
%f_i = f * f_low;         f_f = f * f_upp;
%n_i = n * f_low;         n_f = n * f_upp;
%a_i = a * f_low;         a_f = a * f_upp;
rmin_i = rmin * f_low;   rmin_f = rmin * f_upp;
N0_i = N0 * f_low;        N0_f = N0 * f_upp;
tc_i = tc * f_low;        tc_f = tc * f_upp; 


%% With immune response

Nparams = 8;  % Number of parameters to sweep

ranges = [v0_i, fvimm_i, r0_i, beta_i, nata_i, rmin_i, N0_i, tc_i;
          v0_f, fvimm_f, r0_f, beta_f, nata_f, rmin_f, N0_f, tc_f];

lhs_aux = latin_hyper(Nsamples, Nparams, ranges);


lhs(:,1) = lhs_aux(:,1);  %v0
lhs(:,2) = lhs_aux(:,2);  %fvimm
lhs(:,3) = lhs_aux(:,3);  %r0
lhs(:,4) = ones(Nsamples,1) * fr0dev;  %fr0dev
lhs(:,5) = lhs_aux(:,2);  %frimm
lhs(:,6) = ones(Nsamples,1) * frimmdev;  %frimmdev
lhs(:,7) = lhs_aux(:,4);  %beta
lhs(:,8) = lhs_aux(:,5);  %nata
lhs(:,9) = ones(Nsamples,1) * f;  %f
lhs(:,10) = ones(Nsamples,1) * tmax;  %tmax
lhs(:,11) = ones(Nsamples,1) * dt;  %dt
lhs(:,12) = ones(Nsamples,1) * n;  %n
lhs(:,13) = ones(Nsamples,1) * a;  %a
lhs(:,14) = lhs_aux(:,6);  %rmin
lhs(:,15) = lhs_aux(:,7);  %N0
lhs(:,16) = ones(Nsamples,1) * fndev;  %fndev
lhs(:,17) = lhs_aux(:,8);  %tc
lhs(:,18) = ones(Nsamples,1) * ftcdev;  %ftcdev
lhs(:,19) = ones(Nsamples,1) * tmin;  %tmin

writematrix(lhs, 'samples_prcc.txt');

%% Function

function samples = latin_hyper(Nsamples, Nparams, ranges)
    % LATIN HYPERCUBE SAMPLING
    % ranges is of the type [init_1 init_2 ... ; final_1 final_2 ...]
    samples = lhsdesign(Nsamples, Nparams);
    for ii = 1:Nsamples
        samples(ii,:) = ranges(1,:) + samples(ii,:).*(ranges(2,:)-ranges(1,:));
    end
end


function [v0, fvimm, r0, fr0dev, frimm, frimmdev, b, nata, f, tmax, dt, n, a, rmin, n0, fndev, tc, ftcdev, tmin] = read_optimal_params(fname)
    file_params = fopen(fname, "rt");
    v0 = sscanf(fgetl(file_params), "v0 = %f");
    fvimm = sscanf(fgetl(file_params), "fvimm = %f");
    r0 = sscanf(fgetl(file_params), "r0 = %f");
    fr0dev = sscanf(fgetl(file_params), "fr0dev = %f");
    frimm = sscanf(fgetl(file_params), "frimm = %f");
    frimmdev = sscanf(fgetl(file_params), "frimmdev = %f");
    b = sscanf(fgetl(file_params), "b = %f");
    nata = sscanf(fgetl(file_params), "nata = %f");
    f = sscanf(fgetl(file_params), "f = %f");
    tmax = sscanf(fgetl(file_params), "tmax = %f");
    dt = sscanf(fgetl(file_params), "dt = %f");
    n = sscanf(fgetl(file_params), "n = %f");
    a = sscanf(fgetl(file_params), "a = %f");
    rmin = sscanf(fgetl(file_params), "rmin = %f");
    n0 = sscanf(fgetl(file_params), "n0 = %f");
    fndev = sscanf(fgetl(file_params), "fndev = %f");
    tc = sscanf(fgetl(file_params), "tc = %f");
    ftcdev = sscanf(fgetl(file_params), "ftcdev = %f");
    tmin = sscanf(fgetl(file_params), "tmin = %f");
    fclose(file_params);
end
