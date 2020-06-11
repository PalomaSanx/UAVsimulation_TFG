%% DEFINICION DE UAVS
    air = AirSpace(UAVpos,UAVtarget,vel_max,UAVrad,area+50,umbral);

%% SIMULACION          

t_sim_step = 0.25;        %paso de simulación (s)
t_stab     = 0.25;         %tiempo de estabilizacion de velocidad al 63%
if t_sim_step > t_stab
    fprintf('ERROR en definición de tiempos\n');
    return
end
t_nav_step = 1;%(air.numUAVs/2)/2;   %intervalo para recalcular navegación (s)

t_prev_nav = -t_nav_step; %intervalo para recalcular navegación (s)
t_sim_end  = 10000;       %tiempo de fin de simulación (s)

for t = 0 : t_sim_step : t_sim_end
    
    if t - t_prev_nav >= t_nav_step
        t_prev_nav = t;
        %navegación de cada UAV (según tipo de navegación)
        switch(typeNav)
            case 'direct'
                for i = 1:air.numUAVs
                    air = air.Directnav(i,false);
                end
            case 'BBCA'   
                for i = 1:air.numUAVs
                    air = air.BBnav(i,t_nav_step,false);
                end
            otherwise
                disp('opción incorrecta');      
        end
    end
    
    
    %desplazamiento de UAVs en función de su velocidad actual
    air = air.TimeStep(t_sim_step,t_stab);
    
    %actualización del estado de la matriz conflictos
    air = air.ConflictUpdate();

    %detección de fin
    [fin,air] = air.TargetsReached(t);
    if fin
        %obtengo numero de conflictos totales
        air = air.countConflict();
        break
    end
    
end




