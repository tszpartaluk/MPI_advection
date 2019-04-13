clear all
close all


D = importtiming_par('timing/czasy_vloac_cproc_upwind.dat',1,2000);

numpr = D(:,3);
totaltime = D(:,7);
looptime = D(:,8);
commtime = D(:,9);
tsteps = D(:,6);
npts = D(:,5);

fig = figure(1);

% co chce pokazac?
scatter(npts,commtime./tsteps*1000,'r.');
hold on
scatter(npts,looptime./tsteps*1000,'ks');
hold on
%set(gca,'yscale','log')
%set(gca,'xscale','log')
grid on
grid minor
xlabel('grid points');
ylabel('time per time step [ms]');
legend('communication','total loop','location','best');
%axis([0 32 0 1e-4])
zapiszpdf(fig,12,12,'cproc.pdf');