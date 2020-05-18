clc; clear;
tic;
%% DEFINICION DE UAVS
% menu para simulaciones
user_choice = menu ('Elige el escenario a simular','Escenario 1','Escenario 2','Escenario 3', 'Escenario 4','Escenario 5');

switch user_choice 
    case 1
         run("banco de pruebas/eval1_2A_100V_50R");
    case 2 
         run("banco de pruebas/eval1_3A_100V_50R");
    case 3 
         run("banco de pruebas/eval1_4A_100V_50R");
    case 4
         run("banco de pruebas/eval1_5A_100V_50R");
    case 5
         run("banco de pruebas/eval1_6A_100V_50R");
    otherwise
        disp('opción incorrecta');      
end

air = AirSpace(UAVpos,UAVtarget,vel_max,UAVrad);

%% SIMULACION          

t_sim_step = 0.05;        %paso de simulación (s)
t_stab     = 0.1;         %tiempo de estabilizacion de velocidad al 63%
if t_sim_step > t_stab
    fprintf('ERROR en definición de tiempos\n');
    return
end
t_nav_step = (air.numUAVs/2)/2;  %intervalo para recalcular navegación (s)
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
    if air.ConflictDetection()
        air.tSim = toc;
        air.statistics();
        return
    end
    
    %detección de fin
    if air.TargetsReached()
        air.tSim = toc;
        air.statistics();
        break
    end
    
end
