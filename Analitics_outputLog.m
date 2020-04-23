clear
clc
close all

% Leo archivo  
data = csvread('outputLog.csv');
col1 = data(:, 1); %code

% Guardo valores de colisiones en outputLog
    log = data(data(:,1)==07,:);
    
    col5 = log(:, 5); %posX
    col6 = log(:, 6); %posy 
    nConflictos = length(log);
    
%Gráfica de conflictos

scatter(col5,col6,'r','x');

grid on
legend(strcat(num2str(nConflictos),' mensajes de conflictos'));
title('Colisiones entre UAVs en simulación');
xlabel('X axis');  % etiqueta para el nombre del eje x
ylabel('Y axis');  % etiqueta para el nombre del eje y

 %% guardar archivos de imagenes de la grafica
 nc = 'imagenes_salida_outputLog';   % nombre carpeta
 mkdir(nc);
 ruta = ['./' nc '/'];

 print(figure(1),[ruta 'imagen_de_datos_pdf'],'-dpdf');  % para guardar una imagen en un documento pdf
  
winopen(['./' nc '/imagen_de_datos_pdf.pdf']);
