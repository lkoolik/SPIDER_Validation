% Koolik et al. (2022) Velocity and Weber Number Model
% Main Function
% % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% Initialize
close all
clear all
set(0,'DefaultAxesFontName', 'Arial');
set(0,'DefaultTextFontname', 'Arial');
set(0,'DefaultTextFontSize', 12);

%% Define Initial Parameters
% PCVI and L-PCVI values specific for SPIDER are hardcoded here.
% CVI: (PCVI = 1, LPCVI = 0)
 
% PCVI
CVI = 1;
Q = 6.8; 

% % L-PCVI
% CVI = 0;
% Q = 42.5695;

%% String Stuff
% Auto-generates strings for file saving.
if CVI == 0
    CVIstr = 'L-PCVI';
else
    CVIstr = 'PCVI';
end

title1str = ['Velocity Along ', CVIstr, ' Axis'];
xstr = ['Distance from ', CVIstr, ' Inlet [mm]'];
title2str = ['Weber Number Along ', CVIstr, ' Axis'];

%% Calculate for all particle sizes
% Runs the simulations for each particle size.
% See "PekourCalc" for more information.
[x_vec_01, u_vec_01, V_vec_01, We_vec_01] = PekourCalc(1, Q, CVI);
[x_vec_03, u_vec_03, V_vec_03, We_vec_03] = PekourCalc(3, Q, CVI);
[x_vec_10, u_vec_10, V_vec_10, We_vec_10] = PekourCalc(10, Q, CVI);
[x_vec_20, u_vec_20, V_vec_20, We_vec_20] = PekourCalc(20, Q, CVI);
[x_vec_30, u_vec_30, V_vec_30, We_vec_30] = PekourCalc(30, Q, CVI);
[x_vec_50, u_vec_50, V_vec_50, We_vec_50] = PekourCalc(50, Q, CVI);
[x_vec_75, u_vec_75, V_vec_75, We_vec_75] = PekourCalc(75, Q, CVI);

%% Plot The Velocity of Each Particle as a Function of Space
% Plots the results.
YMatrix1 = [V_vec_01; u_vec_01 ;u_vec_03; u_vec_10; u_vec_20; u_vec_30; ...
    u_vec_50; u_vec_75];

figure1 = figure('units','normalized','outerposition',[0 0 1 1]);
axes1 = axes('Parent',figure1);
hold(axes1,'on')
plot1 = plot(x_vec_01,YMatrix1,'Parent',axes1);
set(plot1(1),'DisplayName','Gas','LineWidth',2,...
    'Color',[0 0.447058826684952 0.74117648601532]);
set(plot1(2),'DisplayName','1 \mum','LineStyle','-.','Color',[1 0 0]);
set(plot1(3),'DisplayName','3 \mum','LineStyle','--','Color',[1 0 0]);
set(plot1(4),'DisplayName','10 \mum','Color',[1 0 0]);
set(plot1(5),'DisplayName','20 \mum','LineStyle','-.',...
    'Color',[0.466666668653488 0.674509823322296 0.18823529779911]);
set(plot1(6),'DisplayName','30 \mum','LineStyle','--',...
    'Color',[0.466666668653488 0.674509823322296 0.18823529779911]);
set(plot1(7),'DisplayName','50 \mum',...
    'Color',[0.466666668653488 0.674509823322296 0.18823529779911]);
set(plot1(8),'DisplayName','75 \mum','LineStyle','-.',...
    'Color',[0.749019622802734 0 0.749019622802734]);
title(title1str);
xlabel(xstr);
ylabel('Velocity [m/s]');
box(axes1,'on');
set(axes1,'XTickLabel',{'0','5','10','15','20','25','30','35','40'});
legend1 = legend(axes1,'show');
set(legend1,'Location','northwest');

%% Weber Number at each Point of the CVI
YMatrix2 = [We_vec_01; We_vec_03; We_vec_10; We_vec_20; We_vec_30; ...
    We_vec_50; We_vec_75];

figure2 = figure('units','normalized','outerposition',[0 0 1 1]);
axes2 = axes('Parent',figure2);
hold(axes2,'on')
plot2 = plot(x_vec_01,YMatrix2,'Parent',axes2);
set(plot2(1),'DisplayName','1 \mum','LineStyle','-.','Color',[1 0 0]);
set(plot2(2),'DisplayName','3 \mum','LineStyle','--','Color',[1 0 0]);
set(plot2(3),'DisplayName','10 \mum','Color',[1 0 0]);
set(plot2(4),'DisplayName','20 \mum','LineStyle','-.',...
    'Color',[0.466666668653488 0.674509823322296 0.18823529779911]);
set(plot2(5),'DisplayName','30 \mum','LineStyle','--',...
    'Color',[0.466666668653488 0.674509823322296 0.18823529779911]);
set(plot2(6),'DisplayName','50 \mum',...
    'Color',[0.466666668653488 0.674509823322296 0.18823529779911]);
set(plot2(7),'DisplayName','75 \mum','LineStyle','-.',...
    'Color',[0.749019622802734 0 0.749019622802734]);
title(title2str);
xlabel(xstr);
ylabel('Weber Number');
box(axes2,'on');
set(axes2,'XTickLabel',{'0','5','10','15','20','25','30','35','40'});
legend2 = legend(axes2,'show');
set(legend2,'Location','northwest');

%% Figure 3 (for thesis)
figure3 = figure;

subplot1 = subplot(2,1,1,'Parent',figure3);
hold(subplot1,'on');
plot1 = plot(x_vec_01,YMatrix1,'Parent',subplot1);
set(plot1(1),'DisplayName','Gas','LineWidth',2,'Color',[0 0 0]);
set(plot1(2),'DisplayName','1 \mum','LineStyle','--',...
    'Color',[0.831372559070587 0.815686285495758 0.7843137383461]);
set(plot1(3),'DisplayName','3 \mum','LineWidth',1,'LineStyle',':',...
    'Color',[0.800000011920929 0.800000011920929 0.800000011920929]);
set(plot1(4),'DisplayName','10 \mum','LineStyle','-.',...
    'Color',[0.800000011920929 0.800000011920929 0.800000011920929]);
set(plot1(5),'DisplayName','20 \mum',...
    'Color',[0.313725501298904 0.313725501298904 0.313725501298904]);
set(plot1(6),'DisplayName','30 \mum','LineStyle','--',...
    'Color',[0.313725501298904 0.313725501298904 0.313725501298904]);
set(plot1(7),'DisplayName','50 \mum','LineWidth',1,'LineStyle',':',...
    'Color',[0.313725501298904 0.313725501298904 0.313725501298904]);
set(plot1(8),'DisplayName','75 \mum','LineStyle','-.',...
    'Color',[0.313725501298904 0.313725501298904 0.313725501298904]);
title3str = ['Modeled Velocity and Weber Number in the ', CVIstr];
title(title3str);
ylabel('Velocity [m/s]');
ylim(subplot1,[0 max(max(YMatrix1))*1.25]);
box(subplot1,'on');
legend1 = legend(subplot1,'show');
set(legend1,'Orientation','horizontal','Location','north');
x_location = x_vec_01(round(length(x_vec_01)/15));
textlocation1 = [x_location, 1.05*max(max(YMatrix1))];
text(textlocation1(1), textlocation1(2), '(a)','FontName', 'CMU Bright','HorizontalAlignment','right','FontSize',12)
    

subplot2 = subplot(2,1,2,'Parent',figure3);
hold(subplot2,'on');
plot2 = plot(x_vec_01,YMatrix2,'Parent',subplot2,...
    'Color',[0.313725501298904 0.313725501298904 0.313725501298904]);
set(plot2(1),'DisplayName','1 \mum','LineStyle','--',...
    'Color',[0.831372559070587 0.815686285495758 0.7843137383461]);
set(plot2(2),'DisplayName','3 \mum','LineWidth',1,'LineStyle',':',...
    'Color',[0.831372559070587 0.815686285495758 0.7843137383461]);
set(plot2(3),'DisplayName','10 \mum','LineStyle','-.',...
    'Color',[0.831372559070587 0.815686285495758 0.7843137383461]);
set(plot2(4),'DisplayName','20 \mum');
set(plot2(5),'DisplayName','30 \mum','LineStyle','--');
set(plot2(6),'DisplayName','50 \mum','LineWidth',1,'LineStyle',':');
set(plot2(7),'DisplayName','75 \mum','LineStyle','-.');
xlabel(xstr);
ylabel('Weber Number');
ylim(subplot2,[0 max(max(YMatrix2))*1.25]);
box(subplot2,'on');
legend2 = legend(subplot2,'show');
set(legend2,'Orientation','horizontal','Location','north');
textlocation2 = [x_location, 1.05*max(max(YMatrix2))];
text(textlocation2(1), textlocation2(2), '(b)','FontName', 'CMU Bright','HorizontalAlignment','right','FontSize',12)
    