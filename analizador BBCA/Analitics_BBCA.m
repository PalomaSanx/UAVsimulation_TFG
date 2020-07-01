
figPosition(1:2) = [100 0];   % posición deseada
figPosition(3:4) = [700 900]; % tamaño deseado
figAnalitics = figure('NumberTitle','off', ...
                       'Position',figPosition, ...
                       'Resize','on');

%% -----Gráfica 1: distancia recorrida por UAV (BBCA,direct,real)------

% Leo distancia recorrida BBCA
distTotalBBCA = air.distTotal;
distReal = [];

for i=1:air.numUAVs
    distReal(i) = norm(air.UAVtarget(i,:) - air.UAVposInit(i,:));
end

ax1 = subplot(4,1,1);
b = bar(ax1,[distReal', distTotalDirect',distTotalBBCA'],'BarWidth',0.5);
b(1).FaceColor = 'y';
b(2).FaceColor = 'r';
b(3).FaceColor = 'b';

grid on
title('BBCA distance vs Direct distance vs real distance');
legend('real','direct','BBCA','Location','southeast');
xlabel('UAV');  % etiqueta para el nombre del eje x
ylabel('distance (m)');  % etiqueta para el nombre del eje y

%% -----Gráfica 2: % distancia recorrida por UAV (BBCA vs direct)----
increseDist = (abs(distTotalBBCA-distTotalDirect)./abs(distTotalDirect))*100;
  
ax2 = subplot(4,1,2);
bar(ax2,increseDist,'b','BarWidth',0.2);
grid on
title('(%) Deviation BBCA/direct');
xlabel('UAV');  % etiqueta para el nombre del eje x
ylabel('increment (%)');  % etiqueta para el nombre del eje y

%% ---- Grafica 3: tiempo empleado por UAV en (s)-----

% leo tiempo empleado por UAV
timeTotalBBCA = air.timeTotal;
ax3 = subplot(4,1,3);
b = bar(ax3,[timeTotalDirect',timeTotalBBCA'],'BarWidth',0.5);
b(1).FaceColor = 'r';
b(2).FaceColor = 'b';
grid on
title('Total time for UAV (s)');
legend('direct','BBCA','Location','southeast');
xlabel('UAV');  % etiqueta para el nombre del eje x
ylabel('Time (s)');  % etiqueta para el nombre del eje y

%% --------Grafica 4:  % tiempo empleado por UAV----

increaseTime = (abs(timeTotalBBCA-timeTotalDirect)./abs(timeTotalDirect))*100;
 
ax4 = subplot(4,1,4);
bar(ax4,increaseTime,'b','BarWidth',0.5);
grid on
title('% Total time for UAV');
xlabel('UAVid');  % etiqueta para el nombre del eje x
ylabel('increment (%)');  % etiqueta para el nombre del eje y


%% leo numero de colisiones
numConflictTotalBBCA = air.numConflictTotal;
annotation('textbox',[.1 0.96 .3 .04],'String',['Number of total conflicts: ',num2str(numConflictTotalBBCA)],'EdgeColor','red')

%% tiempo total simulación
tSim = max(air.timeTotal);
annotation('textbox',[.45 0.96 .3 .04],'String',['Simulation Time : ',num2str(tSim),' s'],'EdgeColor','blue')

 %% guardar archivos de imagenes de la grafica estadisticas

 print(figAnalitics,[ruta 'img_statistics_',air.typeNav,'_scenario',num2str(k)],'-dpdf');  
 savefig(figAnalitics,[ruta 'img_statistics_',air.typeNav,'_scenario',num2str(k)],'compact')
 %% Inserto registro en log 'outputLog' 
    outputLog = fopen([ruta 'outputLog_',air.typeNav,'_scenario',num2str(k),'.csv'],'w');
    fprintf(outputLog,'%4.3d\n',numConflictTotalBBCA);
    for i=1:numUAVs
        fprintf(outputLog,'%4.3d,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%4.3d\n' ...
                 ,i                    ...
                 ,distTotalBBCA(i)     ...
                 ,distTotalDirect(i)   ...
                 ,distReal(i)          ...
                 ,air.timeTotal(i)     ...
                 ,air.UAVposInit(i,1)  ...
                 ,air.UAVposInit(i,2)  ...
                 ,air.UAVtarget(i,1)   ...
                 ,air.UAVtarget(i,2)   ...
                 ,sum(air.conflictUAV(i,:)));
    end
    
 