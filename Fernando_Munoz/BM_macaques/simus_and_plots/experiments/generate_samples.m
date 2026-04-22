clear;

Nsamples  = 20;                          % samples per swept parameter
fname_fitA = "../fits/params_fitA.txt";
fname_fitB = "../fits/params_fitB.txt";

% Parameter column indices (into the 19-element vector)
IDX_FVIMM = 2;
IDX_FRIMM = 5;
IDX_TC    = 17;

%% --- 1.  samples_vaccinated.txt  (sweep over tc) -------------------------

p = read_optimal_params(fname_fitA);

tc_vec = linspace(10, 40, Nsamples);
samples_vaccinated = make_sweep(p, IDX_TC, tc_vec);

writematrix(samples_vaccinated, 'samples_vaccinated.txt');

%% --- 2.  samples_fimm.txt  (sweep over fvimm and frimm jointly) ----------

p = read_optimal_params(fname_fitA);

fimm_vec = linspace(p(IDX_FVIMM), 1, Nsamples);

% Both fvimm (col 2) and frimm (col 5) vary together along the same vector
base = repmat(p, Nsamples, 1);
base(:, IDX_FVIMM) = fimm_vec(:);
base(:, IDX_FRIMM) = fimm_vec(:);
samples_fimm = base;

writematrix(samples_fimm, 'samples_fimm.txt');

%% --- 3.  params_immunosuppressed.txt  (fitA, fitB, fitA with full immunisation) ----

pA_immunosuppressed      = read_optimal_params(fname_fitA);
pA_immunosuppressed(IDX_FVIMM) = 1;
pA_immunosuppressed(IDX_FRIMM) = 1;

writematrix(pA_immunosuppressed, 'params_immunosuppressed.txt');


%% -----------------------------------------------------------------------
%  Local functions
%  -----------------------------------------------------------------------

function samples = make_sweep(base_params, param_idx, sweep_vec)
% MAKE_SWEEP  Build an (N x 19) sample matrix by varying one parameter.
%   base_params : 1x19 row vector of baseline parameter values
%   param_idx   : column index of the parameter to sweep
%   sweep_vec   : N-element vector of values for that parameter
    N       = numel(sweep_vec);
    samples = repmat(base_params, N, 1);
    samples(:, param_idx) = sweep_vec(:);
end

function p = read_optimal_params(fname)
% READ_OPTIMAL_PARAMS  Read a parameter file and return a 1x19 row vector.
%   File format (one per line):  "param_name = value"
    fid = fopen(fname, "rt");
    v0       = sscanf(fgetl(fid), "v0 = %f");
    fvimm    = sscanf(fgetl(fid), "fvimm = %f");
    r0       = sscanf(fgetl(fid), "r0 = %f");
    fr0dev   = sscanf(fgetl(fid), "fr0dev = %f");
    frimm    = sscanf(fgetl(fid), "frimm = %f");
    frimmdev = sscanf(fgetl(fid), "frimmdev = %f");
    b        = sscanf(fgetl(fid), "b = %f");
    nata     = sscanf(fgetl(fid), "nata = %f");
    f        = sscanf(fgetl(fid), "f = %f");
    tmax     = sscanf(fgetl(fid), "tmax = %f");
    dt       = sscanf(fgetl(fid), "dt = %f");
    n        = sscanf(fgetl(fid), "n = %f");
    a        = sscanf(fgetl(fid), "a = %f");
    rmin     = sscanf(fgetl(fid), "rmin = %f");
    n0       = sscanf(fgetl(fid), "n0 = %f");
    fndev    = sscanf(fgetl(fid), "fndev = %f");
    tc       = sscanf(fgetl(fid), "tc = %f");
    ftcdev   = sscanf(fgetl(fid), "ftcdev = %f");
    tmin     = sscanf(fgetl(fid), "tmin = %f");
    fclose(fid);
    p = [v0, fvimm, r0, fr0dev, frimm, frimmdev, b, nata, f, ...
         tmax, dt, n, a, rmin, n0, fndev, tc, ftcdev, tmin];
end