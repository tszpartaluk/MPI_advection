clear all
close all


D = importtiming_par('timing/loads_32000.dat',1,2000);

numpr = D(:,3);
totaltime = D(:,7);
looptime = D(:,8);
commtime = D(:,9);
tsteps = D(:,6);
npts = D(:,5);


xdata = -1+1./numpr;
ydata = looptime./tsteps*1000;

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( xdata, ydata );

% Set up fittype and options.
ft = fittype( 'poly1' );

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft );


p = 0.9893;

S = 1/(1-p);