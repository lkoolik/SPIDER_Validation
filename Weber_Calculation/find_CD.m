function [CD] = find_CD(Re)
% find_CD: returns the drag coefficient of a particle given the Reynold's
% Number
%
% (Based on Eq. 2-18 through 2-20 from Baron and Willeke, 3ed)
%
% Inputs: Re = Reynold's Number

if Re < 0.1
    CD = 24/Re;
elseif Re < 5
    CD = (24/Re)*(1+0.0196*Re);
else
    CD = (24/Re)*(1+0.158*Re^(2/3));
end

end

