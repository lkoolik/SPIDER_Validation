function [x_vec, u_vec, V_vec, We_vec] = PekourCalc(dp, Q, CVI)
%We_Model: A function to model the weber number in PCVI
%   Based on Matlab script Weber_Calc.m
% REQUIRED INPUTS:
%   dp = particle size (um)
%   Q = input flow to CVI (LPM)
%   CVI = which PCVI? (PCVI = 1, LPCVI = 0)
%
% ASSUMPTIONS:
%   - Phase is liquid
%   - Temperature is 298 K
%   - Dimensions of PCVI and LPCVI are as listed below (see diagram)
%   - Particle and gas velocity are equal at the inlet

% Note, there is no calculation of the exact interaction with the ECF.
% Instead, this is approximated by forcing gas velocity to zero and holding
% particle velocity constant as it approaches the stagnation plane.

    %% Define Initial Parameters
    dp = dp*10^(-6); % Particle Size [m]
    phase = 1; % Phase = liquid (1) or solid (0)
    T = 298; % Temperature [K]
    dx = 0.000001; % Step [m]

    %% Grab CVI Constants
    % CVI constants refer to the drawing in CVI_Diagram.pptx
    if CVI == 1
        % Grab constants for PCVI (m)
        a = 4.31/2/1000;
        b = 1.37/2/1000;
        L = 1.5/1000;
        B = 2.43/1000;
        A = 32.8/1000;
    else
        % Grab constants for LPCVI (m)
        a = 8.77/2/1000;
        b = 5.5/2/1000;
        L = 8/1000;
        B = 14.4/1000;
        A = 60.6/1000;
    end

    % !!! This is for slanted nozzle CVIs !!!
    theta = asin((a-b)/A);

    % Get horizontal length of slanted section
    Xab = A*cos(theta); 

    % Get the total length along x-axis.
    X = Xab+B+L;

    %% Convert Q units:
    Q = Q * (0.001) / (60);

    %% Get mass of particle
    if phase == 1
        rho_p = 1000.0;
    else
        rho_p = 916.7;
    end

    mp = rho_p * (dp/2)^3 * pi;

    %% Determine decay equation for "free" region before stagnation plane
    % The decay is based on the fact that velocity in this region rapidly
    % decays to zero.
    V_b = find_V(Q,b); % See find_V for more information.
    f = polyfit([Xab+B, Xab+B+L], [V_b, 0],1);

    %% Perform calculation along delta-x
    x_vec = [0:dx:X];
    p = length(x_vec);
    r_vec = zeros(1,p);
    V_vec = zeros(1,p);
    u_vec = zeros(1,p);
    dv_vec = zeros(1,p);
    We_vec = zeros(1,p);
    counter = 0;
    FD_vec = zeros(1,p);

    for x = x_vec
        counter = counter + 1;
        if x == 0
            % At entrance of PCVI inlet nozzle
            % Determine V, u, and dv (inlet, so radius = a)
            V = find_V(Q,a);
            u = V; % At inlet, assume that particle speed and gas speed are same
            dv = 0;
            We_vec(counter) = find_We(dv, dp, T); % See find_We for more information.

            % Save values
            r_vec(counter) = a;
            V_vec(counter) = V;
            u_vec(counter) = u;
            dv_vec(counter) = dv;

        elseif x < Xab
            % In the slanted section of PCVI inlet nozzle
            % Determine the radius of the slanted section at this x-value
            r = (Xab-x)*tan(theta)+b;
            r_vec(counter) = r;

            % Calculate the gas velocity
            V = find_V(Q,r);
            V_vec(counter) = V;

            % Find the particle velocity
            ui_1 = u_vec(counter-1);

            % Get Differential Velocity
            dv = V-ui_1;
            dv_vec(counter) = dv;

            FD = find_FD(V,dp,T,dv,phase); % See find_FD
            FD_vec(counter) = FD;

            u = find_u(dp, V, T, dv, phase, dx, ui_1);
            u_vec(counter) = u;

            % Calculate Weber Number
            We_vec(counter) = find_We(dv,dp,T);

            V_straight = V;

        elseif x < (Xab+B)
            % In the straight segment of the inlet nozzle
            % Gas velocity doesn't change, so V_straight can be called for all.
            V_vec(counter) = V_straight;

            % Find the particle velocity
            ui_1 = u_vec(counter-1);
            u = find_u(dp, V, T, dv, phase, dx, ui_1);
            u_vec(counter) = u;

            % Get Differential Velocity
            dv = V-u;
            dv_vec(counter) = dv;

            % Calculate Weber Number
            We_vec(counter) = find_We(dv,dp,T);

        elseif x < (Xab+B+L)
            % Open section of CVI --> rapid decay of gas velocity
            V = f(1)*x + f(2);
            V_vec(counter) = V;

            % Find the particle velocity
            ui_1 = u_vec(counter-1);
            if round(ui_1) == round(V)
                u_vec(counter) = NaN;
            else
%             u = find_u(dp, V, T, dv, phase, dx, ui_1);
                u_vec(counter) = ui_1;
            end

            % Get Differential Velocity
            %dv = V-u;
            %dv_vec(counter) = dv;
            dv_vec(counter) = dv_vec(counter-1);
            
            % Calculate Weber Number
            We_vec(counter) = find_We(dv,dp,T);

        else
            % At the stagnation plane
            V = 0;
            V_vec(counter) = V;

            % Find the particle velocity
            ui_1 = u_vec(counter-1);
            u = find_u(dp, V, T, dv, phase, dx, ui_1);
            u_vec(counter) = u;

            % Get Differential Velocity
            dv = V-u;
            dv_vec(counter) = dv;

            % Calculate Weber Number
            We_vec(counter) = find_We(dv,dp,T);                
        end    
    end
end

