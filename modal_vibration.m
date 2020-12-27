close all; clear all; clc

%% Geometry
% Initialise a 3D PDE model, and import the geometry
model = createpde('structural','modal-solid');
importGeometry(model, 'tongue_drum.stl');

% Visualise the Geometry
figure(1)
hc = pdegplot(model, 'FaceLabels', 'on');
hc(1).FaceAlpha = 0.6;

%% Properties
% Approximates steel
E = 180e9; % Modulus of elasticity in Pascals
nu = .265; % Poisson's ratio
rho = 8000; % Material density in kg/m^3

%% Set up the PDE coefficients
% Refer to https://au.mathworks.com/help/pde/examples/structural-dynamics-of-tuning-fork.html
% for further details
structuralProperties(model,'YoungsModulus',E,...
    'PoissonsRatio', nu,...
    'MassDensity', rho);

%% Mesh the Geometry
hmax = 0.0025;
generateMesh(model,'Hmax',hmax,'GeometricOrder','quadratic');

% Visualise the mesh
figure(1)
pdeplot3D(model);
title('Meshed Geometry');

%% Solve the model
freqRange = 2*pi*[100,5000] % [Hz] Only search for modes within these frequencies
results = solve(model,'FrequencyRange', freqRange);

%% Animate and Save Mode Vibrations
scaleFactor = 0.0005; % scale the vibrations for a better visualisation
modeSelection = 1:size(results.NaturalFrequencies,1); % animate and plot
animateMode(model,results, scaleFactor, modeSelection);
