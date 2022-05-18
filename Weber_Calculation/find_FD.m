function [FD] = find_FD(V, dp, T, dv, phase)
% find_FD: returns the drag force on a particle based on the inputs
%
% (Based on Eq. 2-21 from Baron and Willeke, 3ed)
%
% Inputs: V = characteristic gas velocity (m/s)
%         dp = characteristic dimension of the particle (m)
%         T = temperature (K)
%         dv = differential velocity (U-v) (m/s)
%         phase = liquid (1) or solid (0)
%
% Assumptions: 
%   (1) Gas is dry air.
%   (2) Pressure is 1 atm

%% Call other functions for basic parameters.
Re = find_Re(V, dp, T);
[MFP, Kn] = find_MFP_Kn(T, dp);
CD = find_CD(Re);
CC = find_CC(Kn, phase);

%% Grab Basic Constants
P = 101325; % Pressure [Pa]
RA = 287.05; % Gas Constant [J/kgK]
rho_g = P/(RA*T);
rho_i = 916.7; %kg/m^3
rho_w = 1000.0; %kg/m^3

%% Determine the shape factor
if phase == 1
    chi = 1;
elseif Re < 0.1
    chi_num = rho_i*CC;
    chi_denom = rho_w*find_CC(Kn,1);
    chi = chi_num / chi_denom; % Based on Eq.4-41 from B&W, 2ed
    % Assumes that difference in diameter of sphere and effective diameter
    % is negligible.
else
    chi = 0.8; % (From P&K eq. 5-41)
end

%% Solve for Drag Force
FD_num = pi*CD*rho_g*dv^2*chi^2*dp^2;
FD_denom = 8*CC;
FD = FD_num/FD_denom;

end

