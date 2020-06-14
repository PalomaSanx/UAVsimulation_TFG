clc; clear;
tic;
%% DEFINICION DE ESCENARIO
nc = 'results_analitic';   % nombre carpeta de simulacion
    mkdir(nc);
    ruta = ['./' nc '/']; 

radioAnalitic = 2000; %(m)

j = 1;
for k=0:10:180
    pos(j,:) = [cos(deg2rad(k))*radioAnalitic sin(deg2rad(k))*radioAnalitic];
    target(j,:) = -pos(j,:);
    j = j + 1;
end


%% Simular X veces (posiciones en circunferencia cada 10º)
for k=1:length(pos)
    j = 19;
    UAVpos(1,:) = pos(j,:);
    UAVtarget(1,:) = target(j,:);
    if k == j
        continue;
    end
    UAVpos(2,:) = pos(k,:);
    UAVtarget(2,:) = target(k,:);
    
        
    %definición del escenario
    numUAVs = 2;
    air = AirSpace(numUAVs);
    air.t_step   = 1;        %paso de simulación
    air.t_nav    = 10;
    air.UAVrad   = 50;   %(m)
    air.vel_max  = 13.89;  %(m/s) 
    air.area     = 5000/2;   %(5km x 5km)
    air.UAVposInit = UAVpos;
    air.UAVtarget = UAVtarget;

    %ejecución direct
    tic
    fprintf("Navegación directa\t\t");
    air.typeNav = 'direct';
    air.Run();  
    fprintf("%2.0f conflictos\t",air.numConflictTotal);
    fprintf("%5.2f segundos\n",toc);
    % Guardar figuras de cada simulación (recorrido final y estadisticas)
    print(figure(1),[ruta 'img_simulation_direct_scenario',num2str(k)],'-dpdf');
    savefig(figure(1),[ruta 'img_simulation_direct_scenario',num2str(k)],'compact')
    run("Analitics_direct");
    close all
    save([ruta 'air_',num2str(k),'_direct.mat'],'air');
    
    %ejecución con BBCA
    tic
    fprintf("Navegación BBCA\t\t");
    air.typeNav = 'BBCA';
    air.Run();  
    fprintf("%2.0f conflictos\t",air.numConflictTotal);
    fprintf("%5.2f segundos\n",toc);
    % Guardar figuras de cada simulación (recorrido final y estadisticas)
    print(figure(1),[ruta 'img_simulation_BBCA_scenario',num2str(k)],'-dpdf');
    savefig(figure(1),[ruta 'img_simulation_BBCA_scenario',num2str(k)],'compact')
    run("Analitics_BBCA");
    close all
    save([ruta 'air_',num2str(k),'_BBCA.mat'],'air');
    
    clearvars -except vel_max UAVrad numUAVs radioAnalitic pos target k ruta;
end

run("Analitics_average");





