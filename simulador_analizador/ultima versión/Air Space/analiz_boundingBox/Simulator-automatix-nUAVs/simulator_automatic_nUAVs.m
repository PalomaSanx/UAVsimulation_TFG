clear
clc

%% parametros
vel_max = 36.11; %(m/s) == 130 km/h
UAVrad = 0.125; %(m)
prompt = {'Enter number of UAVs:'};
         dlgtitle = 'Input';
         dims = [1 35];
         answer = inputdlg(prompt,dlgtitle,dims);
         numUAVs = str2num(answer{1});
nc = ['sim_',answer{1},'_UAVs'];   % nombre carpeta de simulacion
mkdir(nc);
ruta = ['./' nc '/'];      
area = 5000; %(5km x 5km)
% Guardo parametros en primera línea de outputLog
outputLog = fopen([ruta 'outputLog.csv'],'w');
fprintf(outputLog,"00,%03f,%05.2f,%05.3f,%05.2f\n" ...
                 ,numUAVs        ...
                 ,vel_max        ...
                 ,UAVrad         ...
                 ,area);
             

%% Simular 10 veces 
for k=1:10
    
    %generamos escenario aleatorio
    [UAVpos, UAVtarget] = randScen(numUAVs,area,UAVrad); 
    
    %simulamos escenario con BBCA
    run ("analiz_automatic_BBCA");
    %% Guardar figuras de cada simulación (recorrido final y estadisticas)
    print(figure(1),[ruta 'img_simulation_BBCA_',num2str(k)],'-dpdf');
    run("Analitics_BBCA");
    close all;
    clearvars -except vel_max UAVrad numUAVs UAVpos UAVtarget k ruta area;
    
    %simulamos escenario sin BBCA (direct)
    run ("analiz_automatic_direct");
    %% Guardar figuras de cada simulación (recorrido final y estadisticas)
    print(figure(1),[ruta 'img_simulation_direct_',num2str(k)],'-dpdf');
    run("Analitics_direct");
    close all;
    clearvars -except vel_max UAVrad numUAVs k ruta area;
end





%% funciones

% Generar escenario aleatorio
function [UAVpos, UAVtarget] = randScen(numUAVs, area, UAVrad)
    area= area-50;%para evitar que aparezcan o vayan fuera del escenario
    r = round(-area + (area+area)*rand(numUAVs,4));
    for i=1:numUAVs
        UAVpos(i,:) = r(i,1:2);
        UAVtarget(i,:) = r(i,3:4);
    end
    dMin = UAVrad*2;
    exit = false;
    while ~exit
        exit = true;
        for i=1:numUAVs
            for j=1:numUAVs
                if i==j
                    continue
                end
                if norm(UAVpos(j,:)-UAVpos(i,:))<dMin || norm(UAVtarget(j,:)-UAVtarget(i,:))<dMin
                    exit = false;
                    UAVpos(i,:) = round(-area + (area+area)*rand(1,2));
                    UAVtarget(i,:) = round(-area + (area+area)*rand(1,2));
                end
            end
        end
    end   
end
