function [] = sim_RADAR( u )
   
    global radar
    persistent firstIteration
    if(isempty(firstIteration))
        firstIteration = false;
        radar = RADARclass;

    end
    
    radar.checkFig();


    %% Cargo datos 
    id   = u(1);
    x    = u(2);
    y    = u(3);
    z    = u(4);        

    % Datos invalidos
    if (id == 0)
        return;
    end

    
    %Actualizo el punto en la pantalla del RADAR
    radar.updateACpto(1,id,x,y,z);
    
%     coder.extrinsic('get_param')
%     simtime = get_param('simulator','SimulationTime');

    


    
        
    

end
