% Koolik et al. (2022) Droplet Evaporation Model
% easyrt function
% % % % % % % % % % % % % % % % % % % % % % % % % % % % %

function [rvec] = easyrt(T,p,S, ri, dt, Tu)
%Simplistic solution to the droplet growth equation using Lohmann et al.
% (2016) Equation 7.29 (page 193).

%% Constants
Lv = 2.5332e6; %Latent Heat of Vaporization (J/kg)
K = (4.1868e-3)*(5.69+0.017*(T-273.15)); % Thermal conductivity coefficient  (W/mK), eqn 7.24
Rv = 461.5; % Gas Constant for Water Vapor (J/kgK)
Dv = (2.11e-5)*((T/273.15)^(1.94))*(101325/p); % Diffusion of water vapor (m2/s), eqn 7.26
esw = (2.53e11)*exp(-5420/T); % equilibrium saturation vapor pressure 

%% Calculation of Fk and Fd
Fk = Lv^2/(K*Rv*T^2)*1000; % eqn. 7.23
Fd = (Rv*T)/(Dv*esw)*1000; % eqn. 7.25

%% Run the Evaporation Over the Entire time step
% Set up the loop variables
tvec = [0:dt:Tu];
rvec = zeros(length(tvec),1);
rp = ri;

% First, loop over time steps:
for i = 1:length(tvec)
    if i == 1
        % For the first step, the radius is just the initial radius.
        rvec(1) = rp;
    else
        % Grab the radius at the end of the last step.
        rp = rvec(i-1);
        if rp > 0
            % If it is still nonzero, perform calculation
            if (rp^2 + 2.*(S-1)./(Fk+Fd).*dt) < 0
                % If the result is negative, droplet has fully evaporated.
                rp = 0;
                rvec(i) = 0;
            else
                % If it is still greater than zero, add the new droplet
                % size to the vector.
                rvec(i) = sqrt((rp^2 + 2.*(S-1)./(Fk+Fd).*dt));
            end
        else
            % If droplet was already zero, it will stay zero.
            rvec(i) = 0;
        end
    end
end         

% Print the final droplet size.
rf = rvec(length(tvec),1)

end

