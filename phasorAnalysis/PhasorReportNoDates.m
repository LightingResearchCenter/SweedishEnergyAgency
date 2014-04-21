function PhasorReportNoDates(time,activity,CS,phasorMagnitude,phasorAngle,IS,IV,MagH,f24abs,Title)
%PHASORREPORT Generates graphical summary of CS and Activity

%% Replace time with time index removing gaps
epoch = mode(diff(time));
t1 = time(1) - floor(time(1));
time = (0:numel(time)-1)'*epoch + t1;

%% Create figure
figure1 = figure;
paperPosition = [0 0 11 8.5];
set(figure1,'PaperUnits','inches',...
    'PaperType','usletter',...
    'PaperOrientation','landscape',...
    'PaperPositionMode','manual',...
    'PaperPosition',paperPosition,...
    'Units','inches',...
    'Position',paperPosition);

%% Set spacing values
xMargin = 0.5/paperPosition(3);
xSpace = 0.125/paperPosition(3);
yMargin = 0.5/paperPosition(4);
ySpace = 0.125/paperPosition(4);

%% Create title
titleHandle = annotation(figure1,'textbox',...
    [0.5,1-yMargin,0.1,0.1],...
    'String',Title,...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'LineStyle','none',...
    'FontSize',14);
% Center the title and shift down
titlePosition = get(titleHandle,'Position');
titlePosition(1) = 0.5-titlePosition(3)/2;
titlePosition(2) = 1-yMargin-titlePosition(4);
set(titleHandle,'Position',titlePosition);

%% Create date stamp
dateStamp = ['Printed: ',datestr(now,'mmm. dd, yyyy HH:MM')];
datePosition = [0.8,1-yMargin,0.1,0.1];
dateHandle = annotation(figure1,'textbox',datePosition,...
    'String',dateStamp,...
    'FitBoxToText','on',...
    'HorizontalAlignment','right',...
    'LineStyle','none');
% Shift left and down
datePosition = get(dateHandle,'Position');
datePosition(1) = 1-xMargin-datePosition(3);
datePosition(2) = 1-yMargin-datePosition(4); 
set(dateHandle,'Position',datePosition);
%% Calculate usable space for plots
workHeight = titlePosition(2)-ySpace-yMargin;
workWidth = 1-2*xMargin;

%% Panel 1 Activity and CS
% Set position values
x1 = xMargin; % half an inch from the edge
w1 = 1-2*xMargin; % width fot half inch margins
h1 = workHeight/3-ySpace/2; % half of top half with spacing
y1 = workHeight+yMargin-h1;
% Create plot
axes1 = axes('Parent',figure1,'OuterPosition',[x1 y1 w1 h1]);
hold(axes1);
set(axes1,'Box','off','TickDir','out');
activityPlot = area(axes1,time,activity);
set(activityPlot,'FaceColor',[.2 .2 .2],'EdgeColor',[.2 .2 .2],'DisplayName','Activity');
csPlot = plot(axes1,time,CS);
set(csPlot,'Color',[.6 .6 .6],'LineWidth',1,'DisplayName','Circadian Stimulus');
xlim(axes1,[floor(time(1)) ceil(time(end))]);
set(axes1,'xtick',floor(time(1)):1:ceil(time(end)));
% ymax = ceil(max([max(activity),max(CS)])/.5)*.5;
ymax = 1;
ylim(axes1,[0 ymax]);
legend(axes1,'Location','NorthOutside','Orientation','horizontal');

%% Panel 2 Phasors
h2 = 2*workHeight/3-ySpace/2;
y2 = yMargin;
w2 = h1*paperPosition(3)/paperPosition(4);
x2 = x1+w2/4;
%   Plot phasors
axes('Parent',figure1,'OuterPosition',[x2 y2 w2 h2]);
phasorplot(phasorMagnitude,phasorAngle,.75,3,6,'top','left',.1);
title(gca,'CS/Activity Phasor');

%% Panel 3 Text annotations
h3 = h2;
y3 = y2;
w3 = (workWidth-xSpace)/2;
x3 = xMargin+w3;
notes = cell(8,1);
notes{1} = ['Phasor Magnitude: ', num2str(phasorMagnitude, '%.2f')];
notes{2} = ['Phasor Angle: ', num2str(phasorAngle, '%.2f'), ' hours'];
notes{3} = ' ';
notes{4} = ['IS: ', num2str(IS, '%.2f')];
notes{5} = ['IV: ', num2str(IV, '%.2f')];
notes{6} = ' ';
notes{7} = ['Mag w/ harmonics: ' num2str(MagH,'%.3f')];
notes{8} = ['Mag 1st harmonic: ' num2str(f24abs,'%.3f')];
text3 = annotation(figure1,'textbox', [x3 y3 w3 h3], 'String',notes);
set(text3,'EdgeColor','none','HorizontalAlignment','left',...
    'VerticalAlignment','middle','FontSize',14);
end
