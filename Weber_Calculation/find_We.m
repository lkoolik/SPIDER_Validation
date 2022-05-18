function [We] = find_We(dv, dp, T)
% find_We = returns Weber number using differential velocity and particle
%  size.
%
% (Based on Eq. 2 from Pekour & Cziczo 2011)
%
% Inputs: dv = differential velocity (m/s)
%         dp = particle size (m)
%         T = temperature (K)
%
% Assumptions: 
%   (1) Particle is liquid phase water.
rho_p = 1000.0; %kg/m^3

%% Solve for surface tension:
% (Based on P&K equation 5-12.)
TC = T - 298.15; % Convert T from K to C
a = [75.93, 0.115, 6.818e-2, 6.511e-3, 2.933e-4, 6.283e-6, 5.285e-8];
T_vec = [TC^0, TC^1, TC^2, TC^3, TC^4, TC^5, TC^6];
sigma = 49.87897441; % Based on MP Paper

%% Calculate Weber Number
We = (dv^2)*rho_p*dp/sigma;

end

