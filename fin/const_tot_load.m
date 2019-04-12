clear all
close all


D = importtiming_par('timing/czasy_cload_vproc_upwind.dat',1,2000);

numpr = D(:,3);
totaltime = D(:,7);
looptime = D(:,8);
commtime = D(:,9);
tsteps = D(:,6);
npts = D(:,5);

fig = figure(1);

% co chce pokazac?
scatter(numpr,commtime./tsteps*1000,'r.');
hold on
scatter(numpr,looptime./tsteps*1000,'ks');
hold on
set(gca,'yscale','log')
grid on
grid minor
xlabel('processes');
ylabel('time [ms]');
legend('communication','total loop');
%axis([0 32 0 1e-4])