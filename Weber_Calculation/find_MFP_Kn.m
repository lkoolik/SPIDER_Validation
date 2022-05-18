function [MFP, Kn] = find_MFP_Kn(T, dp)
% find_MFP: returns the mean free path and Knudsen Number based on a given 
% temperature
%
% (Based on Eq. 2-10 and 2-11 from Baron and Willeke, 3ed)
%
% Inputs: T = temperature (K)
%         dp = characteristic dimension of the particle (m)   
%
% Assumptions: 
%   (1) Gas is dry air.
%   (2) Pressure is 1 atm

P =  101.325; % Pressure [kPa]

MFP = (0.0664e-6)*(101/P)*(T/293)*((1+110/293)/(1+110/T)); % [m]

Kn = 2*MFP/dp;

end

