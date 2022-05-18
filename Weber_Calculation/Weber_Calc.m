% Weber Number Calculation
%% Initialize MATLAB
close all
clear all

%% User Inputs
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Change the values in this section to run the script.  %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

dp = 30e-6; % Particle Size [m]
phase = 1; % Phase = liquid (1) or solid (0)
T = 298; % Temperature [K]
%Q = 42.5695; % Input Flow, [LPM]
Q = 6.8; % Input Flow [LPM]
CVI = 1; % Which CVI? PCVI = 1, LPCVI = 0
dx = 0.0000001; % Step [m]
%dx = 0.1;

%% Grab CVI Constants
% CVI constants refer to the drawing found at the following link:
% [include link]
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
V_b = find_V(Q,b);
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
        We_vec(counter) = find_We(dv, dp, T);
        
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
       
        FD = find_FD(V,dp,T,dv,phase);
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
%         ui_1 = u_vec(counter-1);
%         u = find_u(dp, V, T, dv, phase, dx, ui_1);
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
        %u = find_u(dp, V, T, dv, phase, dx, ui_1);
        u_vec(counter) = ui_1;
        
        % Get Differential Velocity
        dv = dv_vec(counter-1);
        %dv = V-u;
        dv_vec(counter) = dv;
        
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

%% Plot Gas Velocity Versus X
figure(1)
plot(x_vec, V_vec,'.')
xlabel('Distance Along X-Axis (m)')
ylabel('Gas Velocity (m/s)')

%% Plot Particle Velocity Versus X
figure(2)
plot(x_vec, u_vec, '.')
xlabel('Distance Along X-Axis (m)')
ylabel('Particle Velocity (m/s)')

%% Plotting Gas and Particle Velocity Together
 figure3 = figure;

% Create axes
axes3 = axes('Parent',figure3);
hold(axes3,'on');

labstr = ['Particle Velocity (d_p = ', num2str(dp*10^6), ' \mum)'];

% Create multiple lines using matrix input to plot
plot3 = plot(x_vec,[V_vec; u_vec]);
set(plot3(1),'DisplayName','Gas Velocity');
set(plot3(2),'DisplayName',labstr,...
    'LineStyle','--');

% Create xlabel
xlabel('Distance Along PCVI (m)');

ylim([0,250])

% Create ylabel
ylabel('Velocity (m/s)');

box(axes3,'on');
% Create legend
legend3 = legend(axes3,'show');
set(legend3,'Location','northwest');

%% Plotting Weber Number Versus X
figure(4)
plot(x_vec(1:355500), We_vec(1:355500),'.')
title('Weber Number');
ylabel('Weber Number');
xlabel('Distance Along PCVI');
