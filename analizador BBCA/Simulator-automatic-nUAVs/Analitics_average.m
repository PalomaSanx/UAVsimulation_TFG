clear; clc;
tic 

% parametros
min_numUAVs = 10;
max_numUAVs = 100;
max_k  = 24;

%% cuento el numero de carpetas existentes = c
%  cuento el numero de iteraciones existentes = k

fprintf("Detectando tamaños de simulación...\n");

c=0;
for UAVs = min_numUAVs:max_numUAVs
     ruta = ['sim_',num2str(UAVs),'_UAVs'];
     if exist(ruta, 'dir') == 7
        c = c + 1;
        numUAVs(c) = UAVs;
     end
end




%% cargo los datos almacenados en ficheros .mat
fprintf("Ejecutando Analytics ...\n");


conf_Direct = zeros(c,max_k);
dist_Direct = zeros(c,max_k);
time_Direct = zeros(c,max_k);

conf_BBCA   = zeros(c,max_k);
dist_BBCA   = zeros(c,max_k);
time_BBCA   = zeros(c,max_k);


for n = 1:length(numUAVs)

    fprintf("\n%3d UAVs \titeracion ",numUAVs(n));
    ruta = ['./sim_',num2str(numUAVs(n)),'_UAVs/'];   
    for k = 1:max_k
        fprintf("%d ",k);
        
        ruta1 = [ruta 'air_',num2str(k),'_direct.mat'];
        ruta2 = [ruta 'air_',num2str(k),'_BBCA.mat'];
        
        if exist(ruta1) == 2 && exist(ruta2) == 2

            load(ruta1);
            close all;
            conf_Direct(n,k) = air.numConflictTotal;
            dist_Direct(n,k) = mean(air.distTotal);
            time_Direct(n,k) = mean(air.timeTotal);

            load(ruta2);
            close all;
            conf_BBCA(n,k) = air.numConflictTotal;
            dist_BBCA(n,k) = mean(air.distTotal);
            time_BBCA(n,k) = mean(air.timeTotal);

          else
              fprintf("ERROR: no existe la simulación %d con %d UAVs!\n");
          end
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

mDirect = mean(conf_Direct,2);  % media de conflictos Direct
sDirect = std(conf_Direct,0,2); % desviación estandar Directos
errorbar(numUAVs,mDirect,sDirect,'-or');

mBBCA   = mean(conf_BBCA,2);    % media de conflictos BBCA
sBBCA   = std(conf_BBCA,0,2);   % desviación estandar BBCA
errorbar(numUAVs,mBBCA,sBBCA,'-ob');

xlim([(numUAVs(1)-5) (numUAVs(end)+5)]);
xticks(numUAVs);
%title('Amount of conflicts between UAVs');
xlabel('UAVs');  % etiqueta para el nombre del eje x
ylabel('conflicts');  % etiqueta para el nombre del eje y
legend('direct','BBCA','Location','northwest');

% guardar archivos de imagenes de la grafica estadisticas
nc = ['statistics_',num2str(max_k),'_ite'];   % nombre carpeta de simulacion
if ~exist(nc, 'dir')
    mkdir(nc);
end
ruta = ['./' nc '/'];  
        
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

mDirect = mean(dist_Direct,2);  % media de distancias Direct
sDirect = std(dist_Direct,0,2); % desviación estandar Directos
errorbar(numUAVs,mDirect,sDirect,'-or');

mBBCA   = mean(dist_BBCA,2);    % media de conflictos BBCA
sBBCA   = std(dist_BBCA,0,2);   % desviación estandar BBCA
errorbar(numUAVs,mBBCA,sBBCA,'-ob');

xlim([(numUAVs(1)-5) (numUAVs(end)+5)]);
xticks(numUAVs);
yl = ylim;
ylim([0 yl(2)])
%title('Average travelled distance');
xlabel('UAVs');  % etiqueta para el nombre del eje x
ylabel('distance (m)');  % etiqueta para el nombre del eje y
legend('direct','BBCA','Location','southeast');

% -----Gráfica 2.2: (%) desviación media (incremento de distancia)------
subplot(2,1,2);
hold on
grid on

relInc = (mBBCA - mDirect) ./ mDirect * 100;
plot(numUAVs,relInc,'-ob')

xlim([(numUAVs(1)-5) (numUAVs(end)+5)]);
xticks(numUAVs);
%title('Relative increment on travelled distance')
xlabel('UAVs')
ylabel('rel inc (%)')


% guardar archivos de imagenes de la grafica estadisticas
nc = ['statistics_',num2str(max_k),'_ite'];   % nombre carpeta de simulacion
if ~exist(nc, 'dir')
    mkdir(nc);
end
ruta = ['./' nc '/'];  
        
print(  figAnalitics,[ruta 'img_statistics_distance'],'-dpdf');  
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

mDirect = mean(time_Direct,2);  
sDirect = std(time_Direct,0,2); 
errorbar(numUAVs,mDirect,sDirect,'-or');

mBBCA   = mean(time_BBCA,2);    
sBBCA   = std(time_BBCA,0,2);   
errorbar(numUAVs,mBBCA,sBBCA,'-ob');

xlim([(numUAVs(1)-5) (numUAVs(end)+5)]);
xticks(numUAVs);
yl = ylim;
ylim([0 yl(2)])
%title('Average time consumed');
xlabel('UAVs');  
ylabel('time (s)');  
legend('direct','BBCA','Location','southeast');

% -----Gráfica 3.2: (%) desviación media (incremento de distancia)------
subplot(2,1,2);
hold on
grid on

relInc = (mBBCA - mDirect) ./ mDirect * 100;
plot(numUAVs,relInc,'-ob')

xlim([(numUAVs(1)-5) (numUAVs(end)+5)]);
xticks(numUAVs);
%title('Relative increment on time consumed')
xlabel('UAVs')
ylabel('rel inc (%)')

% guardar archivos de imagenes de la grafica estadisticas
nc = ['statistics_',num2str(max_k),'_ite'];   % nombre carpeta de simulacion
if ~exist(nc, 'dir')
    mkdir(nc);
end
ruta = ['./' nc '/'];  
        
print(  figAnalitics,[ruta 'img_statistics_time'],'-dpdf');  
savefig(figAnalitics,[ruta 'img_statistics_time'],'compact')



fprintf("[*] Fin Analitic (%5.2f segundos).\n",toc);