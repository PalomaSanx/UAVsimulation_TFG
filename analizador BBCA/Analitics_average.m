tic 

%parametros
numPos = 1:length(air.UAVposDegree);
max_k = length(numPos); %numero de escenarios     


%% cargo los datos almacenados en ficheros .mat
fprintf("Ejecutando Analytics ...\n");


conf_Direct = zeros(1,max_k);
dist_Direct = zeros(1,max_k);
time_Direct = zeros(1,max_k);

conf_BBCA   = zeros(1,max_k);
dist_BBCA   = zeros(1,max_k);
time_BBCA   = zeros(1,max_k);


for k = 1:max_k 
    
    ruta1 = [ruta 'air_',num2str(k),'_direct.mat'];
    ruta2 = [ruta 'air_',num2str(k),'_BBCA.mat'];

    if exist(ruta1) == 2 && exist(ruta2) == 2

        load(ruta1);
        close all;
        conf_Direct(1,k) = air.numConflictTotal;
        dist_Direct(1,k) = mean(air.distTotal);
        time_Direct(1,k) = mean(air.timeTotal);

        load(ruta2);
        close all;
        conf_BBCA(1,k) = air.numConflictTotal;
        dist_BBCA(1,k) = mean(air.distTotal);
        time_BBCA(1,k) = mean(air.timeTotal);

      else
          fprintf("ERROR: no existe la simulación %d con %d UAVs!\n");
      end

end

  

%% -----Gráfica de conflictos ------ 
figPosition(1:2) = [100 100]; % posición deseada
figPosition(3:4) = [700 400]; % tamaño deseado
figAnalitics = figure('NumberTitle','off', ...
                       'Position',figPosition, ...
                       'Resize','on');

hold on
grid on

mDirect = conf_Direct;  % media de conflictos Direct
plot(numPos,mDirect,'-or');

mBBCA   = conf_BBCA;    % media de conflictos BBCA
plot(numPos,mBBCA,'-ob');
yl = ylim;
ylim([0 yl(2)])
xticks(numPos);
title('Amount of conflicts between 2 UAVs');
xlabel('scenario');  % etiqueta para el nombre del eje x
ylabel('conflicts');  % etiqueta para el nombre del eje y
legend('direct','BBCA','Location','northeast');

% guardar archivos de imagenes de la grafica estadisticas
     
print(  figAnalitics,[ruta 'img_statistics_conflicts'],'-dpdf');  
savefig(figAnalitics,[ruta 'img_statistics_conflicts'],'compact')



%% -----Gráfica de distancia------ 
figPosition(1:2) = [100 0];   % posición deseada
figPosition(3:4) = [700 900]; % tamaño deseado
figAnalitics = figure('NumberTitle','off', ...
                       'Position',figPosition, ...
                       'Resize','on');

% -----Gráfica 2.1: (%) distancia media recorrida ------
subplot(2,1,1);
hold on
grid on

mDirect = dist_Direct;  % media de distancias Direct
plot(numPos,mDirect,'-or');

mBBCA   = dist_BBCA;    % media de conflictos BBCA
plot(numPos,mBBCA,'-ob');

yl = ylim;
ylim([0 yl(2)])
xticks(numPos);
title('Average travelled distance');
xlabel('scenario');  % etiqueta para el nombre del eje x
ylabel('distance (m)');  % etiqueta para el nombre del eje y
legend('direct','BBCA','Location','southwest');

% -----Gráfica 2.2: (%) desviación media (incremento de distancia)------
subplot(2,1,2);
hold on
grid on

relInc = (mBBCA - mDirect) ./ mDirect * 100;
plot(numPos,relInc,'-ob')


xticks(numPos);
yl = ylim;
ylim([0 yl(2)])
title('Relative increment on travelled distance')
xlabel('scenario')
ylabel('rel inc (%)')


% guardar archivos de imagenes de la grafica estadisticas  

print(figAnalitics,[ruta 'img_statistics_distance'],'-dpdf');  
savefig(figAnalitics,[ruta 'img_statistics_distance'],'compact')




%% -----Gráfica de tiempo------ 
figPosition(1:2) = [100 0];   % posición deseada
figPosition(3:4) = [700 900]; % tamaño deseado
figAnalitics = figure('NumberTitle','off', ...
                       'Position',figPosition, ...
                       'Resize','on');

% -----Gráfica 3.1: (%) tiempo medio empleado------
subplot(2,1,1);
hold on
grid on

mDirect =time_Direct;  
plot(numPos,mDirect,'-or');

mBBCA   = time_BBCA;    
plot(numPos,mBBCA,'-ob');

yl = ylim;
ylim([0 yl(2)])
xticks(numPos);
title('Average time consumed');
xlabel('scenario');  
ylabel('time (s)');  
legend('direct','BBCA','Location','southwest');

% -----Gráfica 3.2: (%) desviación media (incremento de distancia)------
subplot(2,1,2);
hold on
grid on

relInc = (mBBCA - mDirect) ./ mDirect * 100;
plot(numPos,relInc,'-ob')

yl = ylim;
ylim([0 yl(2)])
xticks(numPos);
title('Relative increment on time consumed')
xlabel('scenario')
ylabel('rel inc (%)')

% guardar archivos de imagenes de la grafica estadisticas        
print(  figAnalitics,[ruta 'img_statistics_time'],'-dpdf');  
savefig(figAnalitics,[ruta 'img_statistics_time'],'compact')



fprintf("[*] Fin Analitic (%5.2f segundos).\n",toc);