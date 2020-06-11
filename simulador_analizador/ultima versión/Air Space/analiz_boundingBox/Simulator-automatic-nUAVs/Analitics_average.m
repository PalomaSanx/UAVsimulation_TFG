clear;

% parametros
min_numUAVs = 10;
inter_numUAVs = 10;
max_numUAVs = 100;
max_numIte  = 10;

%% cuento el numero de carpetas existentes = i
% cuento el numero de iteraciones existentes = k
c=0;
k=0;
for UAVs=min_numUAVs:inter_numUAVs:max_numUAVs
     ruta = ['sim_',num2str(UAVs),'_UAVs'];
     if exist(ruta, 'dir') == 7
        ruta = ['./sim_',num2str(UAVs),'_UAVs/'];   
        c = c + 1;
        UAV(c) = UAVs;
        for ite=1:max_numIte
            try
                load([ruta 'air_',num2str(ite),'_direct.mat'],'air.numUAVs');
                load([ruta 'air_',num2str(ite),'_BBCA.mat'],'air.numUAVs');
                close all;
                k = k + 1;
            end
        end
     end
end
k = k/c;

%% cargo los datos almacenados en ficheros .mat
numConfDir = zeros(c,k);
numConfBBCA = zeros(c,k);
averageTravelled = zeros(1,c);
averageTravelledDirect = zeros(1,c);
averageDeviation = zeros(1,c);
averageTime = zeros(1,c);
i = 0;

for UAVs=UAV(1):inter_numUAVs:max_numUAVs
     ruta = ['sim_',num2str(UAVs),'_UAVs'];
     if exist(ruta, 'dir') == 7
        ruta = ['./sim_',num2str(UAVs),'_UAVs/'];   
        i = i + 1;
        for ite=1:max_numIte
            try
                % cargo los datos almacenados en ficheros .mat (direct)
                load([ruta 'air_',num2str(ite),'_direct.mat']);
                close all;
                numConfDir(i,ite) = numConfDir(i,ite) + air.numConflictTotal;
                distTotalDirect = air.distTotal;
                timeTotalDirect = air.timeTotal;
                if exist('averageTDirect') == 0
                    averageTDirect = air.distTotal;
                else
                    averageTDirect = [averageT air.distTotal];
                end
                % cargo los datos almacenados en ficheros .mat (BBCA)
                load([ruta 'air_',num2str(ite),'_BBCA.mat']);
                close all;
                numConfBBCA(i,ite) = numConfBBCA(i,ite) + air.numConflictTotal;
                if exist('averageT') == 0
                    averageT = air.distTotal;
                    averageD = ((air.distTotal-distTotalDirect)./air.distTotal)*100;
                    averageTi = ((air.timeTotal-timeTotalDirect)./ air.timeTotal)*100;
                else
                    averageT = [averageT air.distTotal];
                    averageD = [averageD ((air.distTotal-distTotalDirect)./air.distTotal)*100];
                    averageTi = [averageTi ((air.timeTotal-timeTotalDirect)./ air.timeTotal)*100];
                end
            end
        end
        averageTravelledDirect(i) = mean(averageTDirect);
        averageTravelled(i) = mean(averageT);
        averageDeviation(i) = mean(averageD);
        averageTime(i) = mean(averageTi);
        clear('averageT','averageD', 'averageTi','averageTDirect');
     end
end
close all;

%% ---------------- GRAFICOS (1 Y 2)--------------------- %%
figPosition(1:2) = [100 0];   % posici�n deseada
figPosition(3:4) = [700 900]; % tama�o deseado
figAnalitics = figure('NumberTitle','off', ...
                       'Position',figPosition, ...
                       'Resize','on');

% -----Gr�fica 1: n� de conflictos ------ 
ax1 = subplot(2,1,1);
col1 = sum(numConfDir')/k ; % Leo media de conflictos directos
col2 = sum(numConfBBCA')/k; % Leo media de conflictos BBCA
col3 = var(numConfDir'); % Leo varianza de conflictos directos
col4 = var(numConfBBCA'); % Leo varianza de conflictos directos
x = linspace(UAV(1),UAV(end),length(UAV));
y = col1;
vari = col3;
errorbar(x,y,vari,'-or');
hold on
y = col2;
vari = col4;
errorbar(x,y,vari,'-ob');
hold off
grid on
xlim([(UAV(1)-5) (UAV(end)+5)]);
xticks(UAV);
title('Average of conflicts');
legend('direct','BBCA');
xlabel('num UAVs');  % etiqueta para el nombre del eje x
ylabel('num conflicts');  % etiqueta para el nombre del eje y

% -----Gr�fica 2: (%) distancia media recorrida (incremento de distancia)------
ax2 = subplot(2,1,2);

y = averageTravelledDirect;
plot(x,y,'-or');
hold on
y = averageTravelled;
plot(x,y,'-ob');
hold off
grid on
xlim([(UAV(1)-5) (UAV(end)+5)]);
xticks(UAV);
legend('direct','BBCA');
title('Average Travelled');
xlabel('num UAVs');  % etiqueta para el nombre del eje x
ylabel('distance (m)');  % etiqueta para el nombre del eje y

% guardar archivos de imagenes de la grafica estadisticas
nc = ['statistics_average_',num2str(k),'_ite'];   % nombre carpeta de simulacion
        mkdir(nc);
        ruta = ['./' nc '/'];  
        
print(figAnalitics,[ruta 'img_statistics_average1_',num2str(k),'_ite'],'-dpdf');  
savefig(figAnalitics,[ruta 'img_statistics_average1_',num2str(k),'_ite'],'compact')

%% ---------------- GRAFICOS (3 Y 4)--------------------- %%

figPosition(1:2) = [100 0];   % posici�n deseada
figPosition(3:4) = [700 900]; % tama�o deseado
figAnalitics2 = figure('NumberTitle','off', ...
                       'Position',figPosition, ...
                       'Resize','on');
% -----Gr�fica 3: (%) desviaci�n media (incremento de distancia)------

y = averageDeviation;
ax3 = subplot(2,1,1);
plot(x,y,'-ob');
grid on
xlim([(UAV(1)-5) (UAV(end)+5)]);
xticks(UAV);
title('Average deviation distance');
xlabel('num UAVs');  % etiqueta para el nombre del eje x
ylabel('increase (%)');  % etiqueta para el nombre del eje y

% -----Gr�fica 4: (%) (incremento de tiempo)------

y = averageTime;
ax4 = subplot(2,1,2);
xlim([(UAV(1)-5) (UAV(end)+5)]);
plot(x,y,'-ob');
grid on
xlim([(UAV(1)-5) (UAV(end)+5)]);
xticks(UAV);
title('Average deviation time');
xlabel('num UAVs');  % etiqueta para el nombre del eje x
ylabel('increase (%)');  % etiqueta para el nombre del eje y

% guardar archivos de imagenes de la grafica estadisticas
print(figAnalitics2,[ruta 'img_statistics_average2_',num2str(k),'_ite'],'-dpdf');  
savefig(figAnalitics2,[ruta 'img_statistics_average2_',num2str(k),'_ite'],'compact')
 