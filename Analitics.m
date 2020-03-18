clear
clc
close all

% Leo archivo  
data = csvread('logDelivery.csv');
col1 = data(:, 1); %curTime
col2 = data(:, 2); %UAVid
col3 = data(:, 3); %posX delivery
col4 = data(:, 4); %posY delivery

%Gráfica de Puntos de entrega por UAV
histo = sqrt((col3.^2)+(col4.^2));
bar(col2, histo);
grid on
title('Point Delivery - UAVid');
xlabel('X axis UAVid');  % etiqueta para el nombre del eje x
ylabel('Y axis distance in meters');  % etiqueta para el nombre del eje y

 %% guardar archivos de imagenes de la grafica
 nc = 'imagenes_salida';   % nombre carpeta
 mkdir(nc);
 ruta = ['./' nc '/'];
  
 print(figure(1),[ruta 'imagen_de_datos_png'],'-dpng');  % para guardar una imagen pixelada
 print(figure(1),[ruta 'imagen_de_datos_eps'],'-depsc'); % para guardar una imagen vectorial (para latex)
 print(figure(1),[ruta 'imagen_de_datos_pdf'],'-dpdf');  % para guardar una imagen en un documento pdf
 print(figure(1),[ruta 'imagen_de_datos_svg'],'-dsvg');  % para guardar una imagen en svg (vectorial para web)
  
winopen(['./' nc '/imagen_de_datos_pdf.pdf']);