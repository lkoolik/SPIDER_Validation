% Koolik et al. (2022) PCVI Transmission Efficiency Code

%% Initialize
close all
clear all

%% User Inputs - 
% Current input strings refer to the specific files and sample bounds that
% were used to generate the PCVI Transmission Efficiency curve in the 
% manuscript.

% Input the filenames that contain the data
file_on = '07252017.txt'; 
file_off = '07252017.txt';

% OPS Bin Midpoint Diameters are Saved Elsewhere
OPS_middia = 'OPSMidDia.csv';

% Bounds on sample numbers [first,last] for on and off
sam_on = [8600,9000]; % Transition time is excluded between boundaries
sam_off = [9200,11599];
datesam = '07252017'; 

% Settings for Code
saveoutput = 0; % Save the pictures that are outputted? 1 = yes, 0 = no
crit = 1; % Run the criteria code (see below)? 1 = yes, 0 = no
sigmoidfit = 1; % Run a sigmoid fit? 1 = yes, 0 = no
D50calc = 1; % Calculate the D50 from the sigmoid? 1 = yes, 0 = no

% Where should figures go?
outputfolder = '...';

%% Import the Data!
% Import the data from when the PCVI is on:
[Sam_On,ST_On,Mean_On,TotalConccm_On,VarName18_On,VarName19_On,VarName20_On,VarName21_On,VarName22_On,VarName23_On,VarName24_On,VarName25_On,VarName26_On,VarName27_On,VarName28_On,VarName29_On,VarName30_On,VarName31_On,VarName32_On,VarName33_On] = importOPS(file_on, sam_on(1), sam_on(2));
PCVI_On = horzcat(VarName18_On,VarName19_On,VarName20_On,VarName21_On,VarName22_On,VarName23_On,VarName24_On,VarName25_On,VarName26_On,VarName27_On,VarName28_On,VarName29_On,VarName30_On,VarName31_On,VarName32_On,VarName33_On);

% Import the data from when the PCVI is off:
[Sam_Off,ST_Off,Mean_Off,TotalConccm_Off,VarName18_Off,VarName19_Off,VarName20_Off,VarName21_Off,VarName22_Off,VarName23_Off,VarName24_Off,VarName25_Off,VarName26_Off,VarName27_Off,VarName28_Off,VarName29_Off,VarName30_Off,VarName31_Off,VarName32_Off,VarName33_Off] = importOPS(file_off, sam_off(1), sam_off(2));
PCVI_Off = horzcat(VarName18_Off,VarName19_Off,VarName20_Off,VarName21_Off,VarName22_Off,VarName23_Off,VarName24_Off,VarName25_Off,VarName26_Off,VarName27_Off,VarName28_Off,VarName29_Off,VarName30_Off,VarName31_Off,VarName32_Off,VarName33_Off);

% Import the Diameter Bin Midpoints and save to a new variable
[VarName1,VarName2,VarName3,VarName4,VarName5,VarName6,VarName7,VarName8,VarName9,VarName10,VarName11,VarName12,...
    VarName13,VarName14,VarName15,VarName16] = importopsmiddia(OPS_middia);
opsmiddia = [VarName1,VarName2,VarName3,VarName4,VarName5,VarName6,VarName7,VarName8,VarName9,VarName10,VarName11,VarName12,...
    VarName13,VarName14,VarName15,VarName16];

% Perform some memory cleanup
vars = {'VarName1','VarName2','VarName3','VarName4','VarName5','VarName6','VarName7','VarName8','VarName9','VarName10','VarName11','VarName12',...
    'VarName13','VarName14','VarName15','VarName16','VarName18_On','VarName19_On','VarName20_On','VarName21_On','VarName22_On','VarName23_On','VarName24_On','VarName25_On','VarName26_On','VarName27_On','VarName28_On','VarName29_On','VarName30_On','VarName31_On','VarName32_On','VarName33_On','VarName18_Off','VarName19_Off','VarName20_Off','VarName21_Off','VarName22_Off','VarName23_Off','VarName24_Off','VarName25_Off','VarName26_Off','VarName27_Off','VarName28_Off','VarName29_Off','VarName30_Off','VarName31_Off','VarName32_Off','VarName33_Off'};
clear (vars{:}) % Save memory space

%% Apply Criteria, if applicable
% "PCVI_crit" will be "PCVI_On" even if criteria doesn't run
PCVI_crit = PCVI_On(:,:);

% Wake Capture Criteria Loop
if crit == 1
    
    % First, iterate through samples (rows)
    for s = 1:length(PCVI_On)
        
        % Set up dummy variables for counting small and large particles
        small = 0;
        large = 0;
        
        % Count the particles smaller than expected cut size
        for dp = 1:10 % <- change this value for larger cut size
            if PCVI_On(s,dp) > 0
                small = small + 1;
            end            
        end
        
        % Count the particles larger than expected cut size
        for dp = 11:16 % <- change this value for larger cut size
            if PCVI_On(s,dp) > 0
                large = large + 1;
            end
        end
        
        % If both are showing up, throw away this sample
        if (large >=1) && (small>=1)
            PCVI_crit(s,:) = 0;
        end
    end
end

%% Compute Averages
mean_off = mean(PCVI_Off);
mean_on = mean(PCVI_On);
mean_crit = mean(PCVI_crit);

%% Estimate Transmission Efficiency

if D50calc == 1

    % PCVI Transmission Efficiency
    PCVI_TE = mean_crit./mean_off;
    PCVI_TE_max = max(PCVI_TE);
    PCVI_TE = PCVI_TE ./ PCVI_TE_max;

    % Fit Curve to Data
    if sigmoidfit == 0
        % If told not to do a sigmoid, will attempt a smoothing spline.
        f = fit(opsmiddia',PCVI_TE','smoothingspline');
        fx = [];
        xvec = [];

        % After creating fit, will calculate curve points with 0.01 um
        % resolution.
        for i = [opsmiddia(1):0.01:max(opsmiddia)]
            fx = [fx, f(i)];
            xvec = [xvec,i];
        end

    elseif sigmoidfit == 1
        % If told to do a sigmoidal fit, uses sigm_fit (function from internet)
        % Currently, only fitting sigmoid to points 3-16 (fails less)
        [param,stat] = sigm_fit(opsmiddia(3:16)',PCVI_TE(3:16)');
        fsigm = @(param,xval) param(1)+(param(2)-param(1))./(1+10.^((param(3)-xval)*param(4)));

        % After creating fit, will calculate curve points with 0.01 um
        % resolution.
        xvec = [opsmiddia(1):0.01:max(opsmiddia)];
        fx=fsigm(param,xvec);

    end

    % Find D50
    % Set up dummy variables for looping
    D50vec = [];
    yD50vec = [];
    ytest = [];

    % Cut the vector to save runtime
    y2 = (0.4 <= fx) & (fx <= 0.6);
    minYval = find(y2 == 1, 1 );
    maxYval = find(y2 == 1, 1, 'last' );

    % Next, will go through with higher resolution to create a more resolved
    % set of data points. 
    for x = xvec(minYval):0.0001:xvec(maxYval)

        % Solve for theoretical TE for x = 0-10um.
        if sigmoidfit == 0
            y = f(x);
        elseif sigmoidfit == 1
            y = fsigm(param,x);
        end
        ytest = [ytest,y];

        % Check to see if the theoretical TE is approximately 50%.
        if y >= 0.499 && y <= 0.501
            % If yes, add it to the two vectors of potential D50 values.
            D50vec = [D50vec, x];
            yD50vec = [yD50vec, y];
        end
    end

    % Want to find best choice for D50, so need to closest value to y = 0.5.
    % Create a vector that calculates how far from y = 0.5.
    y_dist = 0.5./yD50vec;

    % Select first value to be "best" to start the loop.
    yD50 = yD50vec(1);

    % Loop through all values chosen as potential D50 values.
    for p = 1:length(y_dist)
        % Calculate the absolute value of the distance between the chosen
        % "best" value and the current looped value.
        d1 = abs(y_dist(p)-1);
        d2 = abs((0.5/yD50)-1);
        % Compare distances.
        if d1 <= d2
            % If new value is closer to 0.5 than the old value, select this
            % value as the new "best" value.
            yD50 = yD50vec(p);
            D50 = D50vec(p);
        end
    end

    % Print out the best approximation for D50 and the associated TE(D50).
    D_50 = round(D50,1)
    yD50

    % Generate a string for the plot:
    D50str = ['Calculated D_{50} = ', num2str(D_50), ' \pm ', num2str(round(D_50*0.025,1)),' \mum'];

    % Plot D50 and Model on top of TE
    figure1 = figure('units','normalized','outerposition',[0 0 1 1]);
    figure1.Position = [100 100 1000 500];
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');

    % Plot the Calculated TE (same as Fig 2)
    plot(opsmiddia,PCVI_TE,'DisplayName','Normalized Transmission Efficiency',...
        'MarkerFaceColor',[0 0 0],...
        'Marker','o',...
        'LineStyle','none',...
        'Color',[0 0 0],...
        'MarkerSize',8);
    
    % Plot the Best Fit Curve
    plot(xvec,fx,'DisplayName','Best Fit Curve','LineStyle','--',...
        'Color',[0.2196,0.2196,0.2196],'LineWidth',1);

    % Plot the Calculated D50 from the Best Fit Curve
    plot(D_50,yD50,'DisplayName',D50str,...
        'MarkerFaceColor',[0.800000011920929 0.800000011920929 0.800000011920929],...
        'MarkerSize',14,...
        'Marker','pentagram',...
        'LineStyle','none',...
        'Color',[0 0 0],...
        'LineWidth',1);
    xlabel('Median Particle Diameter (\mum)','FontName','Arial');
    ylabel('Normalized Transmission Efficiency','FontName','Arial');
    ylim(axes1,[0;1.1]);
    box(axes1,'on');
    set(axes1,'FontName','Arial','FontSize',12);
    errorbar(opsmiddia(14),PCVI_TE(14),opsmiddia(14)*0.05,'horizontal','LineWidth',1,'Color',[0.2196,0.2196,0.2196])
    errorbar(D_50,yD50,D_50*0.05,'horizontal','LineWidth',1,'Color',[0.2196,0.2196,0.2196])
    legend1 = legend('Normalized Transmission Efficiency','Best Fit Curve',D50str);
    set(legend1,'Location','northwest','FontSize',24);
end

%% Export Plots to PNG
fstr1 = [outputfolder,'\PCVIData-',datesam];
if D50calc == 1
    fstr3 = [outputfolder,'\PCCID50-',datesam];
end
    
if saveoutput == 1
    set(gcf,'PaperPositionMode','auto');
    if D50calc == 1 
        print('-f3', fstr3, '-dpng')
    end
end
