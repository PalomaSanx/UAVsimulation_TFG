figPosition(1:2) = [100 0];   % posición deseada
figPosition(3:4) = [700 900]; % tamaño deseado
figAnalitics = figure('NumberTitle','off', ...
                       'Position',figPosition, ...
                       'Resize','on');

%% Gráfica de distancia recorrida por UAV con desviación vs distancia recorrida por UAV directa
% Leo distancia recorrida
distTotal = air.distTotal;
for i=1:air.numUAVs
    distDirect(i) = norm(air.UAVtarget(i,:) - air.UAVposInit(i,:));
end


ax1 = subplot(3,1,1);
bar(ax1,[distTotal',distDirect'],'hist');
grid on
title('Distance travelled vs Direct distance');
xlabel('UAVid');  % etiqueta para el nombre del eje x
ylabel('distance(m)');  % etiqueta para el nombre del eje y

%% Gráfica de desviacion por UAV
ax1 = subplot(3,1,2);
bar(ax1,((distTotal-distDirect)./distTotal)*100);
grid on
title('% Deviation for UAV');
xlabel('UAVid');  % etiqueta para el nombre del eje x
ylabel('increase(%)');  % etiqueta para el nombre del eje y

%% Grafica con tiempo empleado por UAV
% leo tiempo empleado por UAV
timeTotal = air.timeTotal;
%calculo tiempo aproximado sin algoritmo
for i=1:air.numUAVs
    tt(i)=(norm(air.UAVtarget(i,:)-air.UAVposInit(i,:))/air.vel_max);
end
increaseTime = ((timeTotal-tt)./timeTotal)*100;
ax2 = subplot(3,1,3);
bar(ax2,increaseTime);
grid on
title('% Total time for UAV');
xlabel('UAVid');  % etiqueta para el nombre del eje x
ylabel('increase(%)');  % etiqueta para el nombre del eje y

%% leo numero de colisiones
numConf = numConflict;
annotation('textbox',[.1 0.96 .3 .04],'String',['Number of total conflicts: ',num2str(numConf)],'EdgeColor','red')

%% tiempo total simulación
tSim = max(air.timeTotal);
annotation('textbox',[.45 0.96 .3 .04],'String',['Simulation Time : ',num2str(tSim),' s'],'EdgeColor','blue')

 %% guardar archivos de imagenes de la grafica
 nc = 'imagenes_salida';   % nombre carpeta
 mkdir(nc);
 ruta = ['./' nc '/'];
 print(figAnalitics,[ruta 'imagen_de_estadisticas_pdf'],'-dpdf');  % para guardar una imagen en un documento pdf 
 winopen(['./' nc '/imagen_de_estadisticas_pdf.pdf']);

 %% Inserto registro en log 'outputLog' 
 %(código 01: tiempo vs radio)
 %(código 02: colisiones vs radio).
 %(código 03: colisiones vs vel_max).
 %(código 04: escenario realista 2 UAVs).
    outputLog = fopen('outputLog_7.csv','a');
    for i=1:air.numUAVs
        fprintf(outputLog,"04,%05.0f,%+05.2f,%05.2f,%05.2f,%05.2f,%05.2f,%05.2f,%05.2f,%05.2f\n" ...
                 ,scenario_choice    ...
                 ,distTotal(i)       ...
                 ,air.timeTotal(i)   ...
                 ,tt(i)              ...
                 ,air.UAVposInit(i,1)  ...
                 ,air.UAVposInit(i,2)  ...
                 ,air.UAVtarget(i,1)   ...
                 ,air.UAVtarget(i,2)   ...
                 ,numConf);
    end
 close all;