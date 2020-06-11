figPosition(1:2) = [100 0];   % posición deseada
figPosition(3:4) = [700 900]; % tamaño deseado
figAnalitics = figure('NumberTitle','off', ...
                       'Position',figPosition, ...
                       'Resize','on');

%% -----Gráfica 1: distancia recorrida por UAV (BBCA,direct,real)------

% Leo distancia recorrida BBCA
distTotalBBCA = air.distTotal;
%Guardo (%) media de la distancia recorrida
 outputLogDistTravelled = fopen('outputLogDistTravelled.csv','a');
 fprintf(outputLogDistTravelled,"%5.3f,",distTotalBBCA(1:air.numUAVs));
 fprintf(outputLogDistTravelled,"%5.3f\n",var(distTotalBBCA));

for i=1:air.numUAVs
    distReal(i) = norm(air.UAVtarget(i,:) - air.UAVposInit(i,:));
end

ax1 = subplot(4,1,1);
bar(ax1,[distTotalBBCA', distTotalDirect',distReal']);
grid on
title('BBCA distance vs Direct distance vs real distance');
legend('BBCA','direct','real');
xlabel('UAVid');  % etiqueta para el nombre del eje x
ylabel('distance (m)');  % etiqueta para el nombre del eje y

%% -----Gráfica 2: % distancia recorrida por UAV (BBCA vs direct)----
increseDist = ((distTotalBBCA-distTotalDirect)./distTotalBBCA)*100;
 %Guardo (%) incremento de distancia  
 outputLogDist = fopen('outputLogDist.csv','a');
 fprintf(outputLogDist,"%5.3f,",increseDist(1:air.numUAVs));
 fprintf(outputLogDist,"\n");
  
ax2 = subplot(4,1,2);
bar(ax2,increseDist);
grid on
title('(%) Deviation for UAV using algorithm BBCA');
xlabel('UAVid');  % etiqueta para el nombre del eje x
ylabel('increase (%)');  % etiqueta para el nombre del eje y

%% ---- Grafica 3: tiempo empleado por UAV en (s)-----

% leo tiempo empleado por UAV
timeTotalBBCA = air.timeTotal;
ax3 = subplot(4,1,3);
bar(ax3,[timeTotalBBCA',timeTotalDirect']);
grid on
title('Total time for UAV (s)');
legend('BBCA','direct');
xlabel('UAVid');  % etiqueta para el nombre del eje x
ylabel('Time (s)');  % etiqueta para el nombre del eje y

%% --------Grafica 4:  % tiempo empleado por UAV----

increaseTime = ((timeTotalBBCA-timeTotalDirect)./timeTotalBBCA)*100;
%Guardo (%) incremento de tiempo  
 outputLogTime = fopen('outputLogTime.csv','a');
 fprintf(outputLogTime,"%5.3f,",increseDist(1:air.numUAVs));
 fprintf(outputLogTime,"\n");
 
ax4 = subplot(4,1,4);
bar(ax4,increaseTime);
grid on
title('% Total time for UAV');
xlabel('UAVid');  % etiqueta para el nombre del eje x
ylabel('increase (%)');  % etiqueta para el nombre del eje y


%% leo numero de colisiones
numConflictTotalBBCA = air.numConflictTotal;
annotation('textbox',[.1 0.96 .3 .04],'String',['Number of total conflicts: ',num2str(numConflictTotalBBCA)],'EdgeColor','red')

%% tiempo total simulación
tSim = max(air.timeTotal);
annotation('textbox',[.45 0.96 .3 .04],'String',['Simulation Time : ',num2str(tSim),' s'],'EdgeColor','blue')

 %% guardar archivos de imagenes de la grafica estadisticas

 print(figAnalitics,[ruta 'img_statistics_',typeNav,'_',num2str(k)],'-dpdf');  

 %% Inserto registro en log 'outputLog' 
    outputLog = fopen([ruta 'outputLog_',typeNav,'_',num2str(k),'.csv'],'w');
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