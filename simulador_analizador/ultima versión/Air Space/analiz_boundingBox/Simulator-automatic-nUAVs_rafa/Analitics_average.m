figPosition(1:2) = [100 0];   % posición deseada
figPosition(3:4) = [700 900]; % tamaño deseado
figAnalitics = figure('NumberTitle','off', ...
                       'Position',figPosition, ...
                       'Resize','on');

%% -----Gráfica 1: nº de conflictos ------
% Guardo la media de los conflictos totales en las 5 simulaciones  
% outputLog = fopen('outputLogConflict.csv','w');
%     fprintf(outputLog,"%5.3f,%5.3f,%5.3f,%5.3f\n"      ...
%                      ,sum(confDir')/k                  ...
%                      ,sum(confBBCA')/k                 ...
%                      ,var(confDir')                    ...
%                      ,var(confBBCA'));
data = csvread('outputLogConflict.csv');
col1 = data(1,:); % Leo media de conflictos directos
col2 = data(2,:); % Leo media de conflictos BBCA
col3 = data(3,:); % Leo varianza de conflictos directos
col4 = data(4,:); % Leo varianza de conflictos directos
ax1 = subplot(4,1,1);
x = linspace(25,100,4);
y = col1;
vari = col3;
errorbar(x,y,vari,'-o');
hold on
y = col2;
vari = col4;
errorbar(x,y,vari,'-o');
xlim([0 125]);
hold off
xticks([25 50 75 100]);
grid on
title('Average of conflicts');
legend('direct','BBCA');
xlabel('num UAVs');  % etiqueta para el nombre del eje x
ylabel('num conflicts');  % etiqueta para el nombre del eje y

%% -----Gráfica 2: (%) distancia media recorrida (incremento de distancia)------
data = csvread('outputLogDistTravelled.csv');
averageTravelled = zeros(1,4); % (%)
vari = zeros(1,4);

averageTravelled(1) = mean(mean(data(1:5,1:25)));
averageTravelled(2) = mean(mean(data(6:10,1:50)));
averageTravelled(3) = mean(mean(data(11:15,1:75)));
averageTravelled(4) = mean(mean(data(16:20,1:100)));

x = linspace(25,100,4);
y = averageTravelled;
ax2 = subplot(4,1,2);
bar(x,y);
xticks([25 50 75 100]);
grid on
title('Average Travelled');
xlabel('num UAVs');  % etiqueta para el nombre del eje x
ylabel('distance (m)');  % etiqueta para el nombre del eje y

%% -----Gráfica 3: (%) desviación media (incremento de distancia)------
data = csvread('outputLogDist.csv');
averageDeviation = zeros(1,4); % (%)

averageDeviation(1) = mean(mean(data(1:5,1:25)));
averageDeviation(2) = mean(mean(data(6:10,1:50)));
averageDeviation(3) = mean(mean(data(11:15,1:75)));
averageDeviation(4) = mean(mean(data(16:20,1:100)));

x = linspace(25,100,4);
y = averageDeviation;
ax3 = subplot(4,1,3);
bar(x,y);
grid on
title('Average deviation');
xlabel('num UAVs');  % etiqueta para el nombre del eje x
ylabel('increase (%)');  % etiqueta para el nombre del eje y

%% -----Gráfica 4: (%) (incremento de tiempo)------
data = csvread('outputLogTime.csv');
averageTime = zeros(1,4); % (%)

averageTime(1) = mean(mean(data(1:5,1:25)));
averageTime(2) = mean(mean(data(6:10,1:50)));
averageTime(3) = mean(mean(data(11:15,1:75)));
averageTime(4) = mean(mean(data(16:20,1:100)));

x = linspace(25,100,4);
y = averageTime;
ax4 = subplot(4,1,4);
bar(x,y);
grid on
title('Average time');
xlabel('num UAVs');  % etiqueta para el nombre del eje x
ylabel('increase (%)');  % etiqueta para el nombre del eje y

 %% guardar archivos de imagenes de la grafica estadisticas
 print(figAnalitics,['img_statistics_average_',num2str(k),'sim'],'-dpdf');  

 