function [Re] = find_Re(V, dp, T)
% find_Re: returns the Reynold's number given the gas velocity and size of 
% a particle.
%
% (Based on Eq. 2-4 from Baron and Willeke, 3ed)
%
% Inputs: V = characteristic gas velocity (m/s)
%         dp = characteristic dimension of the particle (m)
%         T = temperature (K)
%
% Assumptions: 
%   (1) Gas is dry air.
%   (2) Pressure is 1 atm

%% Get Constants Based on Temperature from Dixon 2007
P = 101325; % Pressure [Pa]
RA = 287.05; % Gas Constant [J/kgK]
rho_g = P/(RA*T);
eta = (1.458e-6*(T^1.5))/(T+110.4); % Dynamic Gas Viscosity, [Ns/m^2]

%% Solve for Re
Re = rho_g*V*dp/eta;

end

