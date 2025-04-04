function [X,Z, outcome] =ChimerasSimAllParam(N, b, alphaD, Deltaalpha, epsilon, couplingonset, X0, WindowLength, NumberWindows,dt,circw,lag,problink)
%
% This source code has been adapted from the original 
% [1] Andrzejak, Ralph Gregor, Giulia Ruzzene, and Irene Malvestio.
%     Generalized synchronization between chimera states." Chaos; 27 (5): 053114. (2017).
%
% In general, we follow the notation of [1]. Only the auxiliary response is called Theta instead of Psi'
%
% Input
% N: Number of oscillators in each network (50 in [1])
% b: broadness of coupling kernel (18 in [1])
% alphaD: phase lag parameter of the driver network (1.46 in [1])
% Deltaalpha: difference between the phase lag parameter of the driver and response network. alphaR = alphaD+Deltaalpha (ranged from 0 to 0.08 in [1])
% epsilon: coupling strength (ranged from 0 to 1 in [1])
% couplingonset: number of sample points at which the coupling is turned on from zero to epsilon (100,0000 in [1])
% X0: initial conditions in a vector of size (3*N,1). (random intial conditions uniformly distributed between 0 and 2*pi in [1], using rand(150,1)*2*pi)
%
% NumberWindows: Total number of windows -of WindowLength samples each- used for simulation (250 in [1])
% WindowLength: Number of samples in each window. The last window is given as output X. (20,000 used in [1])
% dt sampling time used for the numerical integration (0.01 in [1])
% Taken these three parameters, we have 250 windows * 20,000 samples/window = 5,000,000 samples. Corresponding to 50,000 dimensionless time units
%
% Output
% X: phases of all three network in one joint matrix of size: (3N,WindowLength);
% In X: 1:N phases of driver; N+1:2*N phases of response; 2*N+1:3*N phases of auxiliary response.
% outcome: string explaining what happened for this realization

% The three networks (driver Phi, response Psi, and auxiliary response Theta)
% are generated using one set of differential equations. We here set the
% indices to address them:

Phi = 1:N;

wcirc = circw;
% Writing the phase lag parameters into a matrix of size (3*N,3*N).
% This matrix representation is used for computational efficiency.
alphaR = alphaD+Deltaalpha;
alphaV = zeros(N,1);
alphaV(Phi,1) = alphaD;

% Defining the coupling kernel matrix G
Rectangularwindow = zeros(N,1);
Rectangularwindow(1:b+1)=1;
Rectangularwindow(N-b+1:N)=1;
G = zeros(N,N);
for i = 1:round(N)
    G(i,1:N)=circshift(Rectangularwindow,i-1);
end
G = G/2/b;

if b==0
    G = zeros(N,N);
end


MatrixRand = rand(N,N);
linksErase = find(MatrixRand<=problink);
G(linksErase)=0;
% Allocating the memory space for the phases of all three networks.
X = zeros(WindowLength,N);

% Setting the last state of the network to the initial conditions.
x = X0;

% Specifying the function which contains the differential equation of the
% entire network (driver & response & auxiliary response). Included below.
deriv = @AndrzejakChaosNetworkDifferentialEquation;

% default entry for outcome
outcome = 'No chimera collapsed. No synchronization occurred';
TotalSamples = WindowLength*NumberWindows;
t=0.05:0.05:round(TotalSamples/20);
Driver =wrapTo2Pi(2*pi*t);
driver = 0;
lagD=0;
for j =1:TotalSamples
    % one-time activation of coupling
    if j==couplingonset
        driver = epsilon;
    end
    if j==couplingonset*2
        lagD = lag;
    end

    % Runge-Kutta integration of order four
    PSI=Driver(j);
    k1 = dt*feval(deriv,x,G,alphaV,PSI,driver,wcirc,lagD);
    k2 = dt*feval(deriv,x+k1/2,G,alphaV,PSI,driver,wcirc,lagD);
    k3 = dt*feval(deriv,x+k2/2,G,alphaV,PSI,driver,wcirc,lagD);
    k4 = dt*feval(deriv,x+k3,G,alphaV,PSI,driver,wcirc,lagD);
    x = x + k1/6+k2/3+k3/3+k4/6;
    
    % wrapping the phases
    x = mod(x,2*pi);
    
    % Writing the phases to the output X using the modulus of Windowlength.
    % In this way, always the last WindowLength samples are in X.
    X(j,:)=x;
    
    
    % What follows all serves to check for possible chimera collapses in one of the
    % networks or onsets of synchronization. This is done only every 100th
    % sample to reduce the computational load.
    
    % Order parameter of driver network to check if its chimera has collapsed
    Z(j) = 1/N*abs(sum(exp(1i*x(Phi))));
    PSIall(j) = angle(1/N*sum(exp(1i*x(Phi))));    
end

% Make sure that the last point is always at the right end of the window.
% See above how the data is written circularly into X.
if mean(Z(end-10000:end))>0.9
    outcome=0;
else
    outcome=1;
end

function dy = AndrzejakChaosNetworkDifferentialEquation(x,G,alpha,PSI,epsilon,wcirc,lagD)

diffm=bsxfun(@minus,x,x');
dy = wcirc*ones(numel(x),1)-sum(+sin((diffm+alpha)).*G,2)-epsilon*sin(x-PSI+lagD);
