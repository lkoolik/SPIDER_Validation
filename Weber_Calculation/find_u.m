function [u] = find_u(dp, V, T, dv, phase, dx, ui_1)
% find_v: returns the particle velocity (u)
%
% (Based on Pekour and Cziczo 2011)
%
% Inputs: dp = particle size (m)
%         V = gas velocity (m/s)
%         T = temperature (K)
%         dv = differential velocity (U-v) (m/s)
%         phase = liquid (1) or solid (0)
%         dx = delta-x (m)
%
% Assumptions: 
%   (1) No energy losses due to turbulence, heat loss, friction, etc.
%   (2) Mass is conserved

%% Find FD
FD = find_FD(V,dp,T,dv,phase);

%% Get mass of particle
if phase == 1
    rho_p = 1000.0;
else
    rho_p = 916.7;
end

mp = rho_p * (dp/2)^3 * pi;

%% Calculate Particle Velocity
dFD = dx*FD;
Ei_1 = mp*(ui_1^2)/2;

u = (2/mp*(Ei_1+dFD))^0.5;

end

