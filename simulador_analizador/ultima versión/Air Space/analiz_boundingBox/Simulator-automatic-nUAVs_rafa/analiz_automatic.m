%% DEFINICION DE UAVS
    air = AirSpace(UAVpos,UAVtarget,vel_max,UAVrad,area+50,umbral);

%% SIMULACION          

t_sim_step = 0.25;        %paso de simulaci�n (s)
t_stab     = 0.25;         %tiempo de estabilizacion de velocidad al 63%
if t_sim_step > t_stab
    fprintf('ERROR en definici�n de tiempos\n');
    return
end
t_nav_step = 1;%(air.numUAVs/2)/2;   %intervalo para recalcular navegaci�n (s)

t_prev_nav = -t_nav_step; %intervalo para recalcular navegaci�n (s)
t_sim_end  = 10000;       %tiempo de fin de simulaci�n (s)

for t = 0 : t_sim_step : t_sim_end
    
    if t - t_prev_nav >= t_nav_step
        t_prev_nav = t;
        %navegaci�n de cada UAV (seg�n tipo de navegaci�n)
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
                disp('opci�n incorrecta');      
        end
    end
    
    
    %desplazamiento de UAVs en funci�n de su velocidad actual
    air = air.TimeStep(t_sim_step,t_stab);
    
    %actualizaci�n del estado de la matriz conflictos
    air = air.ConflictUpdate();

    %detecci�n de fin
    [fin,air] = air.TargetsReached(t);
    if fin
        %obtengo numero de conflictos totales
        air = air.countConflict();
        break
    end
    
end




