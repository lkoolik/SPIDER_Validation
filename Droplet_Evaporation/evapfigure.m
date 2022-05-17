% Koolik et al. (2022) Droplet Evaporation Model
% evapfigure function
% % % % % % % % % % % % % % % % % % % % % % % % % % % % %

function evapfigure(X1, YMatrix1, YMatrix2, YMatrix3, YMatrix4)
%evapfigure(X1, YMATRIX1, YMATRIX2, YMATRIX3, YMATRIX4)
%  X1:  vector of time
%  YMATRIX1:  matrix of droplet evaporation vectors at 25% RH
%  YMATRIX2:  matrix of droplet evaporation vectors at 50% RH
%  YMATRIX3:  matrix of droplet evaporation vectors at 75% RH
%  YMATRIX4:  matrix of droplet evaporation vectors at 100% RH

% define colors
c0 = [0 0 0]/255;%[191 191 191]/255;
c1 = [0 0 0]/255;%[159 159 159]/255;
c2 = [0 0 0]/255;%[96 96 96]/255;
c3 = [0 0 0]/255;%[32 32 32]/255;
c4 = [0 0 0]/255;%[16 16 16]/255;
c5 = [0 0 0]/255;
lw = 2;
x_ticks = [0, 5, 10, 15, 20, 25];
y_ticks = [0, 10, 20, 30, 40, 50];

% Create figure
figure1 = figure;

% Create subplot
subplot1 = subplot(2,2,1,'Parent',figure1);
hold(subplot1,'on');

% Create multiple lines using matrix input to plot
plot1 = plot(X1,YMatrix1,'Parent',subplot1,'LineWidth',1,...
    'Color',c0);
set(plot1(1),'DisplayName','D_d = 5 \mum','LineWidth',lw,...
    'Color',c1);
set(plot1(2),'DisplayName','D_d = 12.5 \mum','LineStyle','--',...
    'Color',c2, 'LineWidth',lw);
set(plot1(3),'DisplayName','D_d = 25 \mum','LineStyle',':',...
    'Color',c3, 'LineWidth',lw);
set(plot1(4),'DisplayName','D_d = 37.5 \mum','LineStyle','-.',...
    'Color',c4, 'LineWidth',lw);
set(plot1(5),'DisplayName','D_d = 50 \mum',...
    'Color',c5,...
     'LineWidth',lw);
xlabel('Time in Chamber [s]');
xlim([0, max(X1)]);
ylim([0, 55 ]);
xticks(x_ticks);
yticks(y_ticks);
title('S = 0.25');
ylabel('Droplet Radius [\mum]');
box(subplot1,'on');
set(subplot1,'FontName','Arial');



subplot2 = subplot(2,2,2,'Parent',figure1);
hold(subplot2,'on');

% Create multiple lines using matrix input to plot
plot2 = plot(X1,YMatrix2,'Parent',subplot2,'LineWidth',1,...
    'Color',c0);
set(plot2(1),'DisplayName','D_d = 10 \mum','LineWidth',lw,...
    'Color',c1);
set(plot2(2),'DisplayName','D_d = 25 \mum','LineStyle','--',...
    'Color',c2, 'LineWidth',lw);
set(plot2(3),'DisplayName','D_d = 50 \mum','LineStyle',':',...
    'Color',c3, 'LineWidth',lw);
set(plot2(4),'DisplayName','D_d = 75 \mum','LineStyle','-.',...
    'Color',c4, 'LineWidth',lw);
set(plot2(5),'DisplayName','D_d = 100 \mum',...
    'Color',c5,...
    'LineWidth',0.5);
xlabel('Time in Chamber [s]');
xlim([0, max(X1)]);
ylim([0, 55]);
xticks(x_ticks);
yticks(y_ticks);
title('S = 0.5');
ylabel('Droplet Radius [\mum]');
box(subplot2,'on');
set(subplot2,'FontName','Arial');


% Create subplot
subplot3 = subplot(2,2,3,'Parent',figure1);
hold(subplot3,'on');
plot3 = plot(X1,YMatrix3,'Parent',subplot3,'LineWidth',1,...
    'Color',c0);
set(plot3(1),'DisplayName','D_d = 10 \mum','LineWidth',lw,...
    'Color',c1);
set(plot3(2),'DisplayName','D_d = 25 \mum','LineStyle','--',...
    'Color',c2, 'LineWidth',lw);
set(plot3(3),'DisplayName','D_d = 50 \mum','LineStyle',':',...
    'Color',c3, 'LineWidth',lw);
set(plot3(4),'DisplayName','D_d = 75 \mum','LineStyle','-.',...
    'Color',c4, 'LineWidth',lw);
set(plot3(5),'DisplayName','D_d = 100 \mum',...
    'Color',c5,...
    'LineWidth',lw);
xlabel('Time in Chamber [s]');
xlim([0, max(X1)]);
ylim([0, 55]);
xticks(x_ticks);
yticks(y_ticks);
title('S = 0.75');
ylabel('Droplet Radius [\mum]');
box(subplot3,'on');
set(subplot3,'FontName','Arial');


% Create subplot
subplot4 = subplot(2,2,4,'Parent',figure1);
hold(subplot4,'on');

% Create multiple lines using matrix input to plot
plot4 = plot(X1,YMatrix4,'Parent',subplot4,'LineWidth',1,...
    'Color',c0);
set(plot4(1),'DisplayName','D_d = 10 \mum','LineWidth',lw,...
    'Color',c1);
set(plot4(2),'DisplayName','D_d = 25 \mum','LineStyle','--',...
    'Color',c2, 'LineWidth',lw);
set(plot4(3),'DisplayName','D_d = 50 \mum','LineStyle',':',...
    'Color',c3, 'LineWidth',lw);
set(plot4(4),'DisplayName','D_d = 75 \mum','LineStyle','-.',...
    'Color',c4, 'LineWidth',lw); 
set(plot4(5),'DisplayName','D_d = 100 \mum',...
    'Color',c5,...
    'LineWidth',lw);
xlabel('Time in Chamber [s]');
xlim([0, max(X1)]);
ylim([0, 55]);
xticks(x_ticks);
yticks(y_ticks);
title('S = 1');
ylabel('Droplet Radius [\mum]');
box(subplot4,'on');
set(subplot4,'FontName','Arial');

