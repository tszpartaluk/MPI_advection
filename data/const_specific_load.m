clear all
close all


D = importtiming_par('upwind_timing/czasyl.dat',1,2000);

numpr = D(:,3);
totaltime = D(:,7);
looptime = D(:,8);
commtime = D(:,9);
tsteps = D(:,6);
npts = D(:,5);

fig = figure(1);

% co chce pokazac?
scatter(numpr,looptime./tsteps,'s');
axis([0 32 0 1e-4])