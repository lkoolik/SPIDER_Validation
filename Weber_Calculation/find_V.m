function [V] = find_V(Q, r)
% find_V: returns the gas flow velocity
%
% (Based on Conservation of Mass)
%
% Inputs: Q = flow rate of system (m^3/s)
%         r = radius of tube (m)   
%
% Assumptions: 
%   (1) No energy losses due to turbulence, heat loss, friction, etc.
%   (2) Mass is conserved

V = Q/(pi*r^2);

end

