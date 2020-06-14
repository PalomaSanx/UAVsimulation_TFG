
figPosition(1:2) = [100 0];   % posición deseada
figPosition(3:4) = [700 900]; % tamaño deseado
figAnalitics = figure('NumberTitle','off', ...
                       'Position',figPosition, ...
                       'Resize','on');

%% ------Gráfica 1: distancia recorrida por UAV (direct vs real)------

% Leo distancia recorrida BBCA
distTotalDirect = air.distTotal;
distReal = [];
for i=1:air.numUAVs
    distReal(i) = norm(air.UAVtarget(i,:) - air.UAVposInit(i,:));
end

ax1 = subplot(3,1,1);
b = bar(ax1,[distReal',distTotalDirect']);
b(1).FaceColor = 'y';
b(2).FaceColor = 'r';
grid on
title('Distance travelled vs real distance');
legend('real','direct');
xlabel('UAV');  % etiqueta para el nombre del eje x
ylabel('distance (m)');  % etiqueta para el nombre del eje y

%% ------Gráfica 2: % distancia recorrida por UAV (direct vs real)------

ax2 = subplot(3,1,2);
bar(ax2,(abs(distTotalDirect-distReal)./abs(distReal))*100,'r');
grid on
title('(%) Deviation direct/real');
xlabel('UAV');  % etiqueta para el nombre del eje x
ylabel('increase (%)');  % etiqueta para el nombre del eje y

%% ------ Grafica 3: tiempo empleado por UAV-----

% leo tiempo empleado por UAV
timeTotalDirect = air.timeTotal;
ax3 = subplot(3,1,3);
bar(ax3,timeTotalDirect,'r');
grid on
title('Total time for UAV (s)');
xlabel('UAV');  % etiqueta para el nombre del eje x
ylabel('Time (s)');  % etiqueta para el nombre del eje y


%% leo numero de colisiones
numConflictTotalDirect = air.numConflictTotal;
annotation('textbox',[.1 0.96 .3 .04],'String',['Number of total conflicts: ',num2str(numConflictTotalDirect)],'EdgeColor','red')

%% tiempo total simulación
tSim = max(air.timeTotal);
annotation('textbox',[.45 0.96 .3 .04],'String',['Simulation Time : ',num2str(tSim),' s'],'EdgeColor','blue')

 %% guardar archivos de imagenes de la grafica estadisticas

 print(figAnalitics,[ruta 'img_statistics_',air.typeNav,'_scenario',num2str(k)],'-dpdf');   

 %% Inserto registro en log 'outputLog' 
    outputLog = fopen([ruta 'outputLog_',air.typeNav,'_scenario',num2str(k),'.csv'],'w');
    fprintf(outputLog,'%4.3d\n',numConflictTotalDirect);
    for i=1:numUAVs
        fprintf(outputLog,'%4.3d,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%4.3d\n' ...
                 ,i                    ...
                 ,distTotalDirect(i)         ...
                 ,distReal(i)        ...
                 ,timeTotalDirect(i)     ...
                 ,air.UAVposInit(i,1)  ...
                 ,air.UAVposInit(i,2)  ...
                 ,air.UAVtarget(i,1)   ...
                 ,air.UAVtarget(i,2)   ...
                 ,sum(air.conflictUAV(i,:)));
    end