function [CC] = find_CC(Kn, phase)
% find_CC: returns the slip correction given the Knudsen number and phase.
%
% (Based on Eq. 2-15 from Baron and Willeke, 3ed)
%
% Inputs: Kn = Knudsen Number
%         phase = liquid (1) or solid (0)

if phase == 1
    a = 1.207;
    b = 0.440;
    c = 0.597;
else
    a = 1.142;
    b = 0.558;
    c = 0.999;
end

CC = 1 + Kn*(a + b*exp(-c/Kn));


end

