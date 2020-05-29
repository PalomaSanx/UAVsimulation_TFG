tic;
%% DEFINICION DE UAVS
    air = AirSpace_direct(UAVpos,UAVtarget,vel_max,UAVrad,area);

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
    
%     if t - t_prev_nav >= t_nav_step
%         t_prev_nav = t;
%         %navegación de cada UAV
%         for i = 1:air.numUAVs
%             air = air.BBnav(i,t_nav_step,false);
%         end
%     end
    
    
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

%% funciones

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
