% Koolik et al. (2022) Droplet Evaporation Model
% Main Function
% % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% Initialize
close all
clear all

% % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% This script will use easyrt function to calculate the %
% droplet size after a given amount of time in the      %
% chamber based on a few initial parameters. For more   %
% information about easyrt, see that function.          %
%                                                       %
% The chamber dimensions have been hard-coded but can   %
% be easily changed for other purposes.                 %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% Inputs
% Parameters about the overall system
T = 273-16; % Temperature (K)
p = 101325; % Pressure (Pa)
S = [0.25, 0.5, 0.75, 1]; % Supersaturation Conditions
ri = [5, 12.5, 25, 37.5, 50]*10^(-6); % Initial radius (um)
dt = 0.01; % Time step for evaporation (s)

% Parameters about the Chamber
IF = 6.78; % Input flow into the chamber (LPM)
dChamber = 5.15; % Diameter of the chamber (cm)
LChamber = 138.4; % Length of the chamber (cm)

%% Basic fluid dynamics calculations
IF = IF *(1000/60); % Converts input flow to cm3/s
vChamber = IF/(pi*(dChamber/2)^2); % Calculates the flow velocity in cm/s
Tu = LChamber/vChamber; % Calculates the residence time in the chamber (s)

%% Running the Simulation for each droplet at S = 0.75
% Create a vector for iterating through time steps at rate dt
tvec = [0:dt:Tu];

% Call the easyrt function for each droplet radius
[rvec10] = easyrt(T,p,S(3), ri(1), dt, Tu);
[rvec25] = easyrt(T,p,S(3), ri(2), dt, Tu);
[rvec50] = easyrt(T,p,S(3), ri(3), dt, Tu);
[rvec75] = easyrt(T,p,S(3), ri(4), dt, Tu);
[rvec100] = easyrt(T,p,S(3), ri(5), dt, Tu);

% Update units from m to um
rvec10 = rvec10.*10^6;
rvec25 = rvec25.*10^6;
rvec50 = rvec50.*10^6;
rvec75 = rvec75.*10^6;
rvec100 = rvec100.*10^6;

%% Repeat the Simulation at each other S
% Supersaturation = 0.25
[rvec10_25] = easyrt(T,p,S(1), ri(1), dt, Tu) * 10^6;
[rvec25_25] = easyrt(T,p,S(1), ri(2), dt, Tu) * 10^6;
[rvec50_25] = easyrt(T,p,S(1), ri(3), dt, Tu) * 10^6;
[rvec75_25] = easyrt(T,p,S(1), ri(4), dt, Tu) * 10^6;
[rvec100_25] = easyrt(T,p,S(1), ri(5), dt, Tu) * 10^6;

% Supersaturation = 0.5
[rvec10_50] = easyrt(T,p,S(2), ri(1), dt, Tu) * 10^6;
[rvec25_50] = easyrt(T,p,S(2), ri(2), dt, Tu) * 10^6;
[rvec50_50] = easyrt(T,p,S(2), ri(3), dt, Tu) * 10^6;
[rvec75_50] = easyrt(T,p,S(2), ri(4), dt, Tu) * 10^6;
[rvec100_50] = easyrt(T,p,S(2), ri(5), dt, Tu) * 10^6;

% Supersaturation = 1
[rvec10_100] = easyrt(T,p,S(4), ri(1), dt, Tu) * 10^6;
[rvec25_100] = easyrt(T,p,S(4), ri(2), dt, Tu) * 10^6;
[rvec50_100] = easyrt(T,p,S(4), ri(3), dt, Tu) * 10^6;
[rvec75_100] = easyrt(T,p,S(4), ri(4), dt, Tu) * 10^6;
[rvec100_100] = easyrt(T,p,S(4), ri(5), dt, Tu) * 10^6;

%% Plot the Results of all four 
% Collect inputs into Ymatrices
Ymatrix1 = [rvec10_25,rvec25_25,rvec50_25,rvec75_25,rvec100_25];
Ymatrix2 = [rvec10_50,rvec25_50,rvec50_50,rvec75_50,rvec100_50];
Ymatrix3 = [rvec10,rvec25,rvec50,rvec75,rvec100];
Ymatrix4 = [rvec10_100,rvec25_100,rvec50_100,rvec75_100,rvec100_100];

% Time will be the x variable
X1 = tvec;

% Call the evapfigure function to plot
evapfigure(X1,Ymatrix1,Ymatrix2,Ymatrix3,Ymatrix4)