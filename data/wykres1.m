clear
close all
data = importsolution("files/serial/data/s_ftc_ca10_t5.dat",1,500);

fig = figure(1);
scatter(data(:,1),data(:,3),'k.')
hold on
%scatter(data(:,1),data(:,2),'b.')
%
data = importsolution("files/serial/data/s_upw_ca10_t5.dat",1,500);
hold on
scatter(data(:,1),data(:,2),'b.')

data = importsolution("files/serial/data/s_lfr_ca10_t5.dat",1,500);
hold on
scatter(data(:,1),data(:,2),'r.')

data = importsolution("files/serial/data/s_lwe_ca10_t5.dat",1,500);
hold on
scatter(data(:,1),data(:,2),'g.')

data = importsolution("files/serial/data/s_mac_ca10_t5.dat",1,500);
hold on
scatter(data(:,1),data(:,2),'y.')
grid on
grid minor


zapiszpdf(fig,10,10,'wykres1.pdf')