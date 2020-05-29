tic;
%% DEFINICION DE UAVS
    air = AirSpace(UAVpos,UAVtarget,vel_max,UAVrad,radioAnalitic+10);

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
        %obtengo numero de conflictos totales
        numConflict = countConflict(air);
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
