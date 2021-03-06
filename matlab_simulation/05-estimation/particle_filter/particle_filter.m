addpath('./lib')
addpath('./lib/particle_filter')
clear;
clc;

% Discrete time step
dt = 0.1;

% Prior
mu = 10; % mean (mu)
S = 1;% covariance (Sigma)

% Store prior
mu_old = mu;
S_old = S;

% Number of particles
M = 100;

% Prior - uniform over 5 15
X = 5 + 10 * rand(1, M);
X0 = X;

% Motion model
A = 0.8;
B = 3;
R = 1;

% Measurement model
C = 1;
Q = 1;

% Simulation Initializations
Tf = 3;
T = 0:dt:Tf;
x = zeros(1, length(T) + 1);
x(1) = mu + sqrt(S) * randn(1);
y = zeros(1, length(T));
u = y;

% Store States
mup_S = zeros(1, length(T));
mu_S = zeros(1, length(T));
muP_S = zeros(1, length(T));
SP_S = zeros(1, length(T));


% Main loop
tic;
for t = 1:length(T)
    % select control action
    if (t > 1)
        u(t) = u(t - 1);
    end
    if (mu > 10)
        u(t) = 0;
    elseif (mu < 2);
        u(t) = 1;
    end

    % update state
    e = sqrt(R) * randn(1);
    x(t + 1) = A * x(t) + B * u(t) + e;

    % take measurement
    d = sqrt(Q) * randn(1);
    y(t) = C * x(t + 1) + d;

    % kalman filter estimation
    [mup, mu, Sp, S] = kf(t, A, B, C, R, Q, y, u, mu, S);
    
    % particle filter estimation
    [muParticle, SParticle, Xp] = pf(t, M, A, B, C, X, R, Q, y, u);

    % store kalman filter estimates
    mup_S(t) = mup;
    mu_S(t) = mu;

    % store particle filter estimates
    muP_S(t) = muParticle;
    SP_S(t) = SParticle;

    % plot first time step results
    if (t == 1)
        plot_first_time_step(t, Q, mup, mu_old, Sp, S_old, X, X0, Xp, y);
    end
end
toc

plot_trajectory(4, T, x, y, mu_S, muP_S);
