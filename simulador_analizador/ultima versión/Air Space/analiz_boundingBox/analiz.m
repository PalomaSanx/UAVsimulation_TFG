clc; clear;
tic;
%% DEFINICION DE UAVS
% menu para simulaciones
scenario_choice = menu ('Elige el escenario a simular','Aleatorio 1','Escenario 2(Tiempo/radio)(colisiones/radio)','Escenario 3','Escenario 4', 'Escenario 5','Escenario 6','Escenario 7(colisiones/radio)','Escenario 8(colisiones/radio)','Escenario 9(colisiones/vel_max)','Escenario 10(colisiones/vel_max)','Escenario 11(colisiones/vel_max)','Escenario 12(colisiones/vel_max)');

switch scenario_choice 
    case 1
         prompt = {'Enter number of UAVs:','Enter area:'};
         dlgtitle = 'Input';
         dims = [1 35];n.n,
         answer = inputdlg(prompt,dlgtitle,dims);
         [UAVpos, UAVtarget, vel_max, UAVrad] = randScen(str2num(answer{1}),str2num(answer{2}));  
    case 2
         run("../banco de pruebas/eval1_2A_100V_50R");
    case 3 
         run("../banco de pruebas/eval1_3A_100V_50R");
    case 4 
         run("../banco de pruebas/eval1_4A_100V_50R");
    case 5
         run("../banco de pruebas/eval1_5A_100V_50R");
    case 6
         run("../banco de pruebas/eval1_6A_100V_50R");
    case 7
         run("../banco de pruebas/eval2_2A_100V_50R");
    case 8
         run("../banco de pruebas/eval3_2A_100V_50R");
    case 9
         run("../banco de pruebas/eval4_2A_100V_5R");
    case 10
         run("../banco de pruebas/eval5_2A_100V_5R");
    case 11
         run("../banco de pruebas/eval6_2A_100V_5R");
    case 12
         run("../banco de pruebas/eval7_2A_100V_5R");
    otherwise
        disp('opción incorrecta');      
end
if exist('answer')
    air = AirSpace(UAVpos,UAVtarget,vel_max,UAVrad,str2num(answer{2}));
else
    air = AirSpace(UAVpos,UAVtarget,vel_max,UAVrad,500);
end


%% SIMULACION          

t_sim_step = 0.05;        %paso de simulación (s)
t_stab     = 0.1;         %tiempo de estabilizacion de velocidad al 63%
if t_sim_step > t_stab
    fprintf('ERROR en definición de tiempos\n');
    return
end
t_nav_step = (air.numUAVs/2)/2;%1   %intervalo para recalcular navegación (s)

t_prev_nav = -t_nav_step; %intervalo para recalcular navegación (s)
t_sim_end  = 10000;       %tiempo de fin de simulación (s)

for t = 0 : t_sim_step : t_sim_end
    
    if t - t_prev_nav >= t_nav_step
        t_prev_nav = t;
        %navegación de cada UAV
        for i = 1:air.numUAVs
            air = air.BBnav(i,t_nav_step,false);
        end
    end
    
    
    %desplazamiento de UAVs en función de su velocidad actual
    air = air.TimeStep(t_sim_step,t_stab);
    
    %deteccion de conflictos
    [conflict, air] = air.ConflictDetection();
    if conflict
        %return
    end
    
    %detección de fin
    [fin,air] = air.TargetsReached(t);
    if fin
        %guardamos captura
        print(figure(1),'./imagenes_salida/imagen_de_simulacion_pdf','-dpdf');  % para guardar una imagen en un documento pdf
        winopen('./imagenes_salida/imagen_de_simulacion_pdf.pdf');
        %obtengo numero de conflictos totales
        numConflict = countConflict(air);
        %ejecucion de estadisticas
        run("Analitics");
        break
    end
    
end

% Generar escenario aleatorio
function [UAVpos, UAVtarget, vel_max, UAVrad] = randScen(numUAVs, area)
    area= area-50;%para evitar que aparezcan o vayan fuera del escenario
    r = round(-area + (area+area)*rand(numUAVs,4));
    for i=1:numUAVs
        UAVpos(i,:) = r(i,1:2);
        UAVtarget(i,:) = r(i,3:4);
    end
    vel_max = randi([25 100]);
    UAVrad  = randi([5 25]);
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

%obtener numero de conflictos totales
function numConflict = countConflict(air)
    numConflict = 0;
    repeat = 0;
    for i=1:air.numUAVs
        numConflict = numConflict + sum(air.conflictUAV(i,:));
        for j=1:air.numUAVs
            if air.conflictUAV(i,j)==1 && air.conflictUAV(j,i)==1
                repeat = repeat + 1;
            end
        end
    end
    numConflict = numConflict - repeat/2;
end
