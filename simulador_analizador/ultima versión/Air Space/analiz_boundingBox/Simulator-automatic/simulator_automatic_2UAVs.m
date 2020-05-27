clear
clc
nc = 'img_output_2';   % nombre carpeta de capturas
mkdir(nc);
ruta = ['./' nc '/'];
%% parametros
vel_max = 31.9; %(m/s) == 115km/h
UAVrad = 0.25; %(m)
numUAVs = 2;
radioAnalitic = 100; %(m)

% Guardo parametros en primera línea de outputLog
outputLog = fopen('./img_output_2/outputLog.csv','w');
fprintf(outputLog,"00,%+05.2f,%+05.2f,%05.2f\n" ...
                 ,vel_max         ...
                 ,UAVrad        ...
                 ,radioAnalitic);
             
j = 1;
for k=0:10:350
    pos(j,:) = [cos(deg2rad(k))*radioAnalitic sin(deg2rad(k))*radioAnalitic];
    target(j,:) = -pos(j,:);
    j = j + 1;
end

%% Simular X veces (posiciones en circunferencia cada 10º)
for k=2:length(pos)
    j=1;
    UAVpos(j,:) = pos(1,:);
    UAVtarget(j,:) = target(1,:);
    UAVpos(j+1,:) = pos(k,:);
    UAVtarget(j+1,:) = target(k,:);
    
    run ("analiz_automatic");
    %% Guardar figuras de cada simulación (recorrido final y estadisticas)
    print(figure(1),['./img_output_2/img_simulation_',num2str(k-1)],'-dpdf');
    
    run("Analitics");
    
    close all;
    clearvars -except vel_max UAVrad numUAVs radioAnalitic pos target k;
end
