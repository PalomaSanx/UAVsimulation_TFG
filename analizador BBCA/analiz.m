clc; clear;
tic;
%% DEFINICION DE ESCENARIO
nc = 'results_analitic_scenario';   % nombre carpeta de simulacion
        mkdir(nc);
        ruta = ['./' nc '/']; 
% menu para simulaciones
scenario_choice = menu ('Choose the scenario to simulate','random 1','scenario 2','scenario 3','scenario 4', 'scenario 5','scenario 6','scenario 7','scenario 8','scenario 9','scenario 10','scenario 11','scenario 12','scenario 13', 'analiz automatic 2 UAVs');
k = scenario_choice;
nc = ['scenario',num2str(scenario_choice)];   % nombre carpeta de simulacion
        mkdir([ruta nc]);
        ruta = [ruta '/' nc '/'];
switch scenario_choice 
    case 1
        prompt = {'Enter number of UAVs:','Enter area (m x m):'};
        dlgtitle = 'Input';
        dims = [1 35];
        answer = inputdlg(prompt,dlgtitle,dims);
        %definición del escenario
        numUAVs = str2num(answer{1});
        air = AirSpace(numUAVs);
        air.t_step   = 0.05;        %paso de simulación
        air.t_nav    = 1;
        air.area     = str2num(answer{2})/2;
        air.randScen(); 
        %ejecución direct
        tic
        fprintf("Navegación directa\t\t");
        air.typeNav = 'direct';
        air.Run();  
        fprintf("%2.0f conflictos\t",air.numConflictTotal);
        fprintf("%5.2f segundos\n",toc);
        % Guardar figuras de cada simulación (recorrido final y estadisticas)
        print(figure(1),[ruta 'img_simulation_direct_scenario',num2str(scenario_choice)],'-dpdf');
        savefig(figure(1),[ruta 'img_simulation_direct_scenario',num2str(scenario_choice)],'compact')
        run("Analitics_direct");
        close all
        save([ruta 'air_direct_scenario',num2str(scenario_choice)],'air');
        %ejecución con BBCA
        tic
        fprintf("Navegación BBCA\t\t");
        air.typeNav = 'BBCA';
        air.Run();  
        fprintf("%2.0f conflictos\t",air.numConflictTotal);
        fprintf("%5.2f segundos\n",toc); 
        % Guardar figuras de cada simulación (recorrido final y estadisticas)
        print(figure(1),[ruta 'img_simulation_BBCA_scenario',num2str(scenario_choice)],'-dpdf');
        savefig(figure(1),[ruta 'img_simulation_BBCA_scenario',num2str(scenario_choice)],'compact')
        run("Analitics_BBCA");
        close all
        save([ruta 'air_BBCA_scenario',num2str(scenario_choice)],'air');
    case 2
        run("./banco de pruebas/eval1_2A_100V_50R");
    case 3 
        run("./banco de pruebas/eval1_3A_100V_50R");
    case 4 
        run("./banco de pruebas/eval1_4A_100V_50R");
    case 5
        run("./banco de pruebas/eval1_5A_100V_50R");
    case 6
        run("./banco de pruebas/eval1_6A_100V_50R");
    case 7
        run("./banco de pruebas/eval2_2A_100V_50R");
    case 8
        run("./banco de pruebas/eval3_2A_100V_50R");
    case 9
        run("./banco de pruebas/eval4_2A_100V_5R");
    case 10
        run("./banco de pruebas/eval5_2A_100V_5R");
    case 11
        run("./banco de pruebas/eval6_2A_100V_5R");
    case 12
        run("./banco de pruebas/eval7_2A_100V_5R");
    case 13
        run("./banco de pruebas/eval8_2A_100V_025R");
    case 14
        prompt = {'Enter radio analitic:','Minimum degree:', 'inter degree', 'maximum degree'};
        dlgtitle = 'Input';
        dims = [1 35];
        answer = inputdlg(prompt,dlgtitle,dims);
        %definición del escenario
        radioAnalitic = str2num(answer{1});
        minDegree = str2num(answer{2});
        interDegree = str2num(answer{3});
        maxDegree = str2num(answer{4});
        %definición del escenario
        numUAVs = 2;
        air = AirSpace(numUAVs);
        air.t_step   = 1;        %paso de simulación
        air.t_nav    = 10;
        air.UAVrad   = 50;   %(m)
        air.vel_max  = 13.89;  %(m/s) 
        air.area     = radioAnalitic+air.UAVrad*2;
        tic;
        air.analiz_automatic_2UAVs(radioAnalitic,minDegree,interDegree,maxDegree);
        %% Simular X veces (posiciones en circunferencia cada interDegreeº)
        for k=1:length(air.UAVposDegree)
            j = length(air.UAVposDegree);
            air.UAVposInit(1,:) = air.UAVposDegree(j,:);
            air.UAVtarget(1,:) = air.UAVtargetDegree(j,:);
            if k == j
                continue;
            end
            air.UAVposInit(2,:) = air.UAVposDegree(k,:);
            air.UAVtarget(2,:) = air.UAVtargetDegree(k,:);

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

            clearvars -except vel_max UAVrad numUAVs radioAnalitic pos target k ruta air scenario_choice;
        end

        run("Analitics_average");
    otherwise
        disp('opción incorrecta');      
end
if ~exist('answer')
    %definición del escenario
    numUAVs = length(UAVpos);
    air = AirSpace(numUAVs);
    air.t_step   = 1;        %paso de simulación
    air.t_nav    = 10;
    air.UAVrad   = 50;   %(m)
    air.vel_max  = 13.89;  %(m/s) 
    air.area     = 10000/2;   %(5km x 5km)
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
    print(figure(1),[ruta 'img_simulation_direct_scenario',num2str(scenario_choice)],'-dpdf');
    savefig(figure(1),[ruta 'img_simulation_direct_scenario',num2str(scenario_choice)],'compact')
    run("Analitics_direct");
    close all
    save([ruta 'air_direct_scenario',num2str(scenario_choice)],'air');
    %ejecución con BBCA
    tic
    fprintf("Navegación BBCA\t\t");
    air.typeNav = 'BBCA';
    air.Run();  
    fprintf("%2.0f conflictos\t",air.numConflictTotal);
    fprintf("%5.2f segundos\n",toc);
    % Guardar figuras de cada simulación (recorrido final y estadisticas)
    print(figure(1),[ruta 'img_simulation_BBCA_scenario',num2str(scenario_choice)],'-dpdf');
    savefig(figure(1),[ruta 'img_simulation_BBCA_scenario',num2str(scenario_choice)],'compact')
    run("Analitics_BBCA");
    close all
    save([ruta 'air_BBCA_scenario',num2str(scenario_choice)],'air');
    
    
end





