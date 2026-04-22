clear;

Nsamples = 20;  % Samples per parameter
fname_fitA = "../fits/params_fitA.txt"

% Optimal point:
%fname_optimal = "../fit/params_macro.txt";
[v0, fvimm, r0, fr0dev, frimm, frimm_dev, beta, nata, f, tmax, dt, n, a, rmin, N0, fdevN, tc, ftcdev, tmin] = read_optimal_params(fname_fitA);


% Edit ranges here:
f_low = 0.75;    f_upp = 1.25;
f_vec = linspace(f_low, f_upp, Nsamples);

v0_vec = v0 * f_vec;
fimm_vec = fvimm * f_vec;
r0_vec = r0 * f_vec;
beta_vec = beta * f_vec;
nata_vec = nata * f_vec;
%n_vec = n * f_vec;
%a_vec = a * f_vec;
rmin_vec = rmin * f_vec;
N0_vec = N0 * f_vec;
tc_vec = tc * f_vec;

%% Generate samples
samples = [];

%v0
lhs(:,1) = v0_vec;  %v0
lhs(:,2) = ones(Nsamples,1) * fvimm ;  %fvimm
lhs(:,3) = ones(Nsamples,1) * r0;  %r0
lhs(:,4) = ones(Nsamples,1) * fr0dev;  %fr0dev
lhs(:,5) = ones(Nsamples,1) * frimm;  %frimm
lhs(:,6) = ones(Nsamples,1) * frimm_dev;  %frimmdev
lhs(:,7) = ones(Nsamples,1) * beta;  %beta
lhs(:,8) = ones(Nsamples,1) * nata;  %nata
lhs(:,9) = ones(Nsamples,1) * f;  %f
lhs(:,10) = ones(Nsamples,1) * tmax;  %tmax
lhs(:,11) = ones(Nsamples,1) * dt;  %dt
lhs(:,12) = ones(Nsamples,1) * n;  %n
lhs(:,13) = ones(Nsamples,1) * a;  %a
lhs(:,14) = ones(Nsamples,1) * rmin;  %rmin
lhs(:,15) = ones(Nsamples,1) * N0;  %N0
lhs(:,16) = ones(Nsamples,1) * fdevN;  %fndev
lhs(:,17) = ones(Nsamples,1) * tc;  %tc
lhs(:,18) = ones(Nsamples,1) * ftcdev;  %ftcdev
lhs(:,19) = ones(Nsamples,1) * tmin;  %tmin
samples = [samples; lhs];

%fimm
lhs(:,1) = ones(Nsamples,1) * v0;  %v0
lhs(:,2) = fimm_vec ;  %fvimm
lhs(:,3) = ones(Nsamples,1) * r0;  %r0
lhs(:,4) = ones(Nsamples,1) * fr0dev;  %fr0dev
lhs(:,5) = fimm_vec;  %frimm
lhs(:,6) = ones(Nsamples,1) * frimm_dev;  %frimmdev
lhs(:,7) = ones(Nsamples,1) * beta;  %beta
lhs(:,8) = ones(Nsamples,1) * nata;  %nata
lhs(:,9) = ones(Nsamples,1) * f;  %f
lhs(:,10) = ones(Nsamples,1) * tmax;  %tmax
lhs(:,11) = ones(Nsamples,1) * dt;  %dt
lhs(:,12) = ones(Nsamples,1) * n;  %n
lhs(:,13) = ones(Nsamples,1) * a;  %a
lhs(:,14) = ones(Nsamples,1) * rmin;  %rmin
lhs(:,15) = ones(Nsamples,1) * N0;  %N0
lhs(:,16) = ones(Nsamples,1) * fdevN;  %fndev
lhs(:,17) = ones(Nsamples,1) * tc;  %tc
lhs(:,18) = ones(Nsamples,1) * ftcdev;  %ftcdev
lhs(:,19) = ones(Nsamples,1) * tmin;  %tmin
samples = [samples; lhs];

%r0
lhs(:,1) = ones(Nsamples,1) * v0;  %v0
lhs(:,2) = ones(Nsamples,1) * fvimm ;  %fvimm
lhs(:,3) = r0_vec;  %r0
lhs(:,4) = ones(Nsamples,1) * fr0dev;  %fr0dev
lhs(:,5) = ones(Nsamples,1) * frimm;  %frimm
lhs(:,6) = ones(Nsamples,1) * frimm_dev;  %frimmdev
lhs(:,7) = ones(Nsamples,1) * beta;  %beta
lhs(:,8) = ones(Nsamples,1) * nata;  %nata
lhs(:,9) = ones(Nsamples,1) * f;  %f
lhs(:,10) = ones(Nsamples,1) * tmax;  %tmax
lhs(:,11) = ones(Nsamples,1) * dt;  %dt
lhs(:,12) = ones(Nsamples,1) * n;  %n
lhs(:,13) = ones(Nsamples,1) * a;  %a
lhs(:,14) = ones(Nsamples,1) * rmin;  %rmin
lhs(:,15) = ones(Nsamples,1) * N0;  %N0
lhs(:,16) = ones(Nsamples,1) * fdevN;  %fndev
lhs(:,17) = ones(Nsamples,1) * tc;  %tc
lhs(:,18) = ones(Nsamples,1) * ftcdev;  %ftcdev
lhs(:,19) = ones(Nsamples,1) * tmin;  %tmin
samples = [samples; lhs];

%beta
lhs(:,1) = ones(Nsamples,1) * v0;  %v0
lhs(:,2) = ones(Nsamples,1) * fvimm ;  %fvimm
lhs(:,3) = ones(Nsamples,1) * r0;  %r0
lhs(:,4) = ones(Nsamples,1) * fr0dev;  %fr0dev
lhs(:,5) = ones(Nsamples,1) * frimm;  %frimm
lhs(:,6) = ones(Nsamples,1) * frimm_dev;  %frimmdev
lhs(:,7) = beta_vec;  %beta
lhs(:,8) = ones(Nsamples,1) * nata;  %nata
lhs(:,9) = ones(Nsamples,1) * f;  %f
lhs(:,10) = ones(Nsamples,1) * tmax;  %tmax
lhs(:,11) = ones(Nsamples,1) * dt;  %dt
lhs(:,12) = ones(Nsamples,1) * n;  %n
lhs(:,13) = ones(Nsamples,1) * a;  %a
lhs(:,14) = ones(Nsamples,1) * rmin;  %rmin
lhs(:,15) = ones(Nsamples,1) * N0;  %N0
lhs(:,16) = ones(Nsamples,1) * fdevN;  %fndev
lhs(:,17) = ones(Nsamples,1) * tc;  %tc
lhs(:,18) = ones(Nsamples,1) * ftcdev;  %ftcdev
lhs(:,19) = ones(Nsamples,1) * tmin;  %tmin
samples = [samples; lhs];

%nata
lhs(:,1) = ones(Nsamples,1) * v0;  %v0
lhs(:,2) = ones(Nsamples,1) * fvimm ;  %fvimm
lhs(:,3) = ones(Nsamples,1) * r0;  %r0
lhs(:,4) = ones(Nsamples,1) * fr0dev;  %fr0dev
lhs(:,5) = ones(Nsamples,1) * frimm;  %frimm
lhs(:,6) = ones(Nsamples,1) * frimm_dev;  %frimmdev
lhs(:,7) = ones(Nsamples,1) * beta;  %beta
lhs(:,8) = nata_vec;  %nata
lhs(:,9) = ones(Nsamples,1) * f;  %f
lhs(:,10) = ones(Nsamples,1) * tmax;  %tmax
lhs(:,11) = ones(Nsamples,1) * dt;  %dt
lhs(:,12) = ones(Nsamples,1) * n;  %n
lhs(:,13) = ones(Nsamples,1) * a;  %a
lhs(:,14) = ones(Nsamples,1) * rmin;  %rmin
lhs(:,15) = ones(Nsamples,1) * N0;  %N0
lhs(:,16) = ones(Nsamples,1) * fdevN;  %fndev
lhs(:,17) = ones(Nsamples,1) * tc;  %tc
lhs(:,18) = ones(Nsamples,1) * ftcdev;  %ftcdev
lhs(:,19) = ones(Nsamples,1) * tmin;  %tmin
samples = [samples; lhs];

%rmin
lhs(:,1) = ones(Nsamples,1) * v0;  %v0
lhs(:,2) = ones(Nsamples,1) * fvimm ;  %fvimm
lhs(:,3) = ones(Nsamples,1) * r0;  %r0
lhs(:,4) = ones(Nsamples,1) * fr0dev;  %fr0dev
lhs(:,5) = ones(Nsamples,1) * frimm;  %frimm
lhs(:,6) = ones(Nsamples,1) * frimm_dev;  %frimmdev
lhs(:,7) = ones(Nsamples,1) * beta;  %beta
lhs(:,8) = ones(Nsamples,1) * nata;  %nata
lhs(:,9) = ones(Nsamples,1) * f;  %f
lhs(:,10) = ones(Nsamples,1) * tmax;  %tmax
lhs(:,11) = ones(Nsamples,1) * dt;  %dt
lhs(:,12) = ones(Nsamples,1) * n;  %n
lhs(:,13) = ones(Nsamples,1) * a;  %a
lhs(:,14) = rmin_vec;  %rmin
lhs(:,15) = ones(Nsamples,1) * N0;  %N0
lhs(:,16) = ones(Nsamples,1) * fdevN;  %fndev
lhs(:,17) = ones(Nsamples,1) * tc;  %tc
lhs(:,18) = ones(Nsamples,1) * ftcdev;  %ftcdev
lhs(:,19) = ones(Nsamples,1) * tmin;  %tmin
samples = [samples; lhs];

%N0
lhs(:,1) = ones(Nsamples,1) * v0;  %v0
lhs(:,2) = ones(Nsamples,1) * fvimm ;  %fvimm
lhs(:,3) = ones(Nsamples,1) * r0;  %r0
lhs(:,4) = ones(Nsamples,1) * fr0dev;  %fr0dev
lhs(:,5) = ones(Nsamples,1) * frimm;  %frimm
lhs(:,6) = ones(Nsamples,1) * frimm_dev;  %frimmdev
lhs(:,7) = ones(Nsamples,1) * beta;  %beta
lhs(:,8) = ones(Nsamples,1) * nata;  %nata
lhs(:,9) = ones(Nsamples,1) * f;  %f
lhs(:,10) = ones(Nsamples,1) * tmax;  %tmax
lhs(:,11) = ones(Nsamples,1) * dt;  %dt
lhs(:,12) = ones(Nsamples,1) * n;  %n
lhs(:,13) = ones(Nsamples,1) * a;  %a
lhs(:,14) = ones(Nsamples,1) * rmin;  %rmin
lhs(:,15) = N0_vec;  %N0
lhs(:,16) = ones(Nsamples,1) * fdevN;  %fndev
lhs(:,17) = ones(Nsamples,1) * tc;  %tc
lhs(:,18) = ones(Nsamples,1) * ftcdev;  %ftcdev
lhs(:,19) = ones(Nsamples,1) * tmin;  %tmin
samples = [samples; lhs];

%tc
lhs(:,1) = ones(Nsamples,1) * v0;  %v0
lhs(:,2) = ones(Nsamples,1) * fvimm ;  %fvimm
lhs(:,3) = ones(Nsamples,1) * r0;  %r0
lhs(:,4) = ones(Nsamples,1) * fr0dev;  %fr0dev
lhs(:,5) = ones(Nsamples,1) * frimm;  %frimm
lhs(:,6) = ones(Nsamples,1) * frimm_dev;  %frimmdev
lhs(:,7) = ones(Nsamples,1) * beta;  %beta
lhs(:,8) = ones(Nsamples,1) * nata;  %nata
lhs(:,9) = ones(Nsamples,1) * f;  %f
lhs(:,10) = ones(Nsamples,1) * tmax;  %tmax
lhs(:,11) = ones(Nsamples,1) * dt;  %dt
lhs(:,12) = ones(Nsamples,1) * n;  %n
lhs(:,13) = ones(Nsamples,1) * a;  %a
lhs(:,14) = ones(Nsamples,1) * rmin;  %rmin
lhs(:,15) = ones(Nsamples,1) * N0;  %N0
lhs(:,16) = ones(Nsamples,1) * fdevN;  %fndev
lhs(:,17) = tc_vec;  %tc
lhs(:,18) = ones(Nsamples,1) * ftcdev;  %ftcdev
lhs(:,19) = ones(Nsamples,1) * tmin;  %tmin
samples = [samples; lhs];


%{ 
%TEMPLATE
lhs(:,1) = ones(Nsamples,1) * v0;  %v0
lhs(:,2) = ones(Nsamples,1) * fvimm ;  %fvimm
lhs(:,3) = ones(Nsamples,1) * r0;  %r0
lhs(:,4) = ones(Nsamples,1) * fr0dev;  %fr0dev
lhs(:,5) = ones(Nsamples,1) * frimm;  %frimm
lhs(:,6) = ones(Nsamples,1) * frimm_dev;  %frimmdev
lhs(:,7) = ones(Nsamples,1) * beta;  %beta
lhs(:,8) = ones(Nsamples,1) * nata;  %nata
lhs(:,9) = ones(Nsamples,1) * f;  %f
lhs(:,10) = ones(Nsamples,1) * tmax;  %tmax
lhs(:,11) = ones(Nsamples,1) * dt;  %dt
lhs(:,12) = ones(Nsamples,1) * n;  %n
lhs(:,13) = ones(Nsamples,1) * a;  %a
lhs(:,14) = ones(Nsamples,1) * rmin;  %rmin
lhs(:,15) = ones(Nsamples,1) * N0;  %N0
lhs(:,16) = ones(Nsamples,1) * fdevN;  %fndev
lhs(:,17) = ones(Nsamples,1) * tc;  %tc
lhs(:,18) = ones(Nsamples,1) * ftcdev;  %ftcdev
lhs(:,19) = ones(Nsamples,1) * tmin;  %tmin
samples = [samples; lhs]; 
%}

writematrix(samples, 'samples_sweep.txt');

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
