classdef AirSpace < handle
%simulador de espacio aereo
    
properties

    %valores por defecto que pueden ser modificados
    
    t_step  = 1        %paso de simulación
    t_stab  = 1        %tiempo de estabilización de la velocidad
    t_nav   = 1        %tiempo de refresco de navegación
    typeNav            %mecanismo de navegación a emplear
    t_end   = 10000    %tiempo de fin de simulacion 

    numUAVs            %cantidad de UAVs en la simulacion
    UAVrad  = 10       %radio de un UAV (m)
    vel_max = 10       %velocidad maxima (m/s)
    area    = 100      %tamaño escenario (m)
    
    UAVposInit         %posiciones iniciales
    UAVpos             %posiciones actuales
    UAVvel             %velocidades actuales
    UAVvelF            %velocidades en el paso siguiente
    UAVtarget          %posiciones objetivo
    finUAV             %matriz para control de finalización
    
    conflictUAV        %matriz para control de conflictos
    numConflictTotal   %contador de conflictos totales

    AREAfig            %figura de visualizacion de UAVs
    circle             %circulo con el que se pinta cada UAV
    textCircle
    UAV_               %manejadores de circulo en la figura AREAfig
    
    VELfig             %figura de gestion de obstaculos de velocidad
    
    distTotal          %Distancia total recorrida
    timeTotal          %Tiempo total al objetivo

end

methods


function obj = AirSpace(numUAVs)

    obj.numUAVs  = numUAVs;
    
end


function  obj = randScen(obj)
%Genera un escenario aleatorio
    
    obj.vel_max = randi([14 40]); %(m/s) == [50km/h -- 144km/h]
    obj.UAVrad  = randi([10 50]); %(m)  == [10m    -- 50m]
    dMin = 4 * obj.UAVrad; %separación mínima entre posiciones
    rng('shuffle');        % reestaurar numeros aleatorios
    
    for i = 1:obj.numUAVs

        UAVok = false;
        while ~UAVok

            r = rand(1,4) * 2 - 1;
            r = round( (obj.area - 2*obj.UAVrad) * r);
            obj.UAVposInit(i,:) = r(:,1:2);
            obj.UAVtarget(i,:)  = r(:,3:4);

            route = norm(obj.UAVposInit(i,:)-obj.UAVtarget(i,:));
            if route < obj.area/2
                continue
            end
            
            UAVok = true;
            for j = 1:i-1
                pDist = norm(obj.UAVposInit(j,:)-obj.UAVposInit(i,:));
                tDist = norm(obj.UAVtarget(j,:)-obj.UAVtarget(i,:));
                if pDist < dMin || tDist < dMin
                    UAVok = false;
                    break
                end
            end
        end
    end  
end


function obj = Run(obj)
    
    if obj.t_step > obj.t_stab
        fprintf('ERROR en definición de tiempos\n');
        return
    end
    
    sp = size(obj.UAVposInit);
    st = size(obj.UAVtarget);
    if sp(2)~=2 || st(2)~=2 || sp(1)~=st(1)
        disp('ERROR en posiciones proporcionadas');
        return
    end
    
    %Inicializo espacio aereo
    obj.UAVpos = obj.UAVposInit;

    obj.UAVvel  = zeros(obj.numUAVs,2); 
    obj.UAVvelF = obj.UAVvel; 
    
    obj.finUAV = zeros(1,obj.numUAVs);

    obj.conflictUAV = zeros(obj.numUAVs,obj.numUAVs);
    obj.numConflictTotal = 0;
    
    obj.distTotal = zeros(1,obj.numUAVs);
    obj.timeTotal = zeros(1,obj.numUAVs);
    
    obj = obj.CreateAREAfig();
    obj = obj.CreateVELfig();

    
    %bucle temporal
    t_prev_nav = -obj.t_nav; %intervalo para recalcular navegación (s)

    for t = 0 : obj.t_step : obj.t_end

        if t - t_prev_nav >= obj.t_nav
            t_prev_nav = t;
            %navegación de cada UAV (según tipo de navegación)
            
            for i = 1:obj.numUAVs
                switch(obj.typeNav)
                    case 'direct'
                        obj = obj.Directnav(i,false);
                    case 'BBCA'   
                        obj = obj.BBnav(i,false);
                    otherwise
                        disp('ERROR: sistema de navegación incorrecto');      
                end
            end
        end

        %desplazamiento de UAVs en función de su velocidad actual
        obj = obj.TimeStep();

        %actualización del estado de la matriz conflictos
        obj = obj.ConflictUpdate();

        %detección de fin
        [fin,obj] = obj.TargetsReached(t);
        if fin
            %obtengo numero de conflictos totales
            obj = obj.countConflict();
            break
        end
    end    
end


function obj = TimeStep(obj)
    
    figure(obj.AREAfig)
    for i = 1:obj.numUAVs
        if obj.finUAV(i) == 1
            continue; 
        end
        
        %actualización de la velocidad actual
        %implemento un sistema de primer orden
        w = 1/obj.t_stab; %t_stab: tiempo requerido para que la señal 
                      %        alcance el 63% de su valor
        acel = -w * obj.UAVvel(i,:) + w * obj.UAVvelF(i,:);
        obj.UAVvel(i,:) = obj.UAVvel(i,:) + acel * obj.t_step;
        
        %movimiento
        xo = obj.UAVpos(i,1);
        yo = obj.UAVpos(i,2);
        obj.UAVpos(i,:) = obj.UAVpos(i,:) + obj.UAVvel(i,:) * obj.t_step;
        
        obj.distTotal(i) =  obj.distTotal(i) + norm([xo yo]-obj.UAVpos(i,:));
        %actualizamos dibujo
        plot([xo obj.UAVpos(i,1)],[yo obj.UAVpos(i,2)],...
             'Color',[i/obj.numUAVs,1-i/obj.numUAVs,0],'LineWidth',1);
        obj.UAV_(i).Vertices = obj.UAVpos(i,:) + obj.circle;

    end
    drawnow limitrate nocallbacks
    
end


function obj = BBnav(obj,i,verbose)
%metodo que genera la velocidad futura
%a partir de la situación relativa de los UAVs
%empleando boundig boxes

    if obj.finUAV(i)
       return; 
    end
    %velocidad actual
    vx = obj.UAVvel(i,1);
    vy = obj.UAVvel(i,2);
    
    %defino cuadro VERDE: velocidades validas
    boxG.N =  obj.vel_max;
    boxG.S = -obj.vel_max;
    boxG.E =  obj.vel_max;
    boxG.W = -obj.vel_max;

    if verbose
        figure(obj.VELfig)
        clf; hold on; grid on;
        v_ = plot([0 vx],[0 vy],'k-','LineWidth',2);                
        boxG_ = fill(...
                    [boxG.W boxG.E boxG.E boxG.W], ...
                    [boxG.N boxG.N boxG.S boxG.S], ...
                    'g',...
                    'EdgeColor','none','LineWidth',0.5,...
                    'FaceColor','g','FaceAlpha',0.1);
    end

    %para todos los intrusos
    for j = 1:obj.numUAVs

        %me descarto a mi mismo
        if i == j
            continue
        end
        %descarto al intruso si ha llego a su destino
        if obj.finUAV(j)
            continue
        end
        %descarto al intruso si está muy lejos
        dist = norm(obj.UAVpos(j,:) - obj.UAVpos(i,:));
%         if dist > 10 * obj.UAVrad
%             continue
%         end

        %obtengo el obstaculo de velocidad circular
        %en función de la posición del vecino 
        OBpos  = (obj.UAVpos(j,:) - obj.UAVpos(i,:)) / obj.t_nav;
        OBrad  = 3 * obj.UAVrad / obj.t_nav;
        if verbose
            OBpos_ = viscircles(OBpos,OBrad);
            l = max(abs(OBpos)) + OBrad; 
            axis([-l +l -l +l]) 
        end

        %defino cuadro ROJO: obstaculo de velocidad cuartiplano (medio semiplano)
        if OBpos(2) < 0
            boxR.N = OBpos(2) + OBrad;
            boxR.S = -10000;
        else
            boxR.N = +10000;
            boxR.S = OBpos(2) - OBrad;
        end
        if OBpos(1) < 0
            boxR.E = OBpos(1) + OBrad;
            boxR.W = -10000;
        else
            boxR.E = +10000;
            boxR.W = OBpos(1) - OBrad;
        end

        if verbose
            boxR_ = fill(...
                    [boxR.W boxR.E boxR.E boxR.W],...
                    [boxR.N boxR.N boxR.S boxR.S],...
                    'r',...
                    'EdgeColor','none','LineWidth',0.5,...
                    'FaceColor','r','FaceAlpha',0.1);
        end
        
        %desplazo el cuadro ROJO en función de la velocidad relativa
        boxR.N = boxR.N + obj.UAVvel(j,2);
        boxR.S = boxR.S + obj.UAVvel(j,2);
        boxR.E = boxR.E + obj.UAVvel(j,1);
        boxR.W = boxR.W + obj.UAVvel(j,1);

        if verbose
            boxR_.XData = [boxR.W boxR.E boxR.E boxR.W];
            boxR_.YData = [boxR.N boxR.N boxR.S boxR.S];
        end


        %obtengo distancias del centro a los lados de cuadro rojo
        %(valor negativo indica que estoy dentro)
        ladoN = vy     - boxR.N;
        ladoS = boxR.S - vy;
        ladoE = vx     - boxR.E;
        ladoW = boxR.W - vx;
        %elijo lado mas lejano
        better = max([ladoN ladoS ladoE ladoW]);

        %generamos obstaculo de velocidad lineal
        %(semiplano vertical u horizontal)
        switch better
            case ladoN
                boxR.S = -10000;
                boxR.E = +10000;
                boxR.W = -10000;
            case ladoS
                boxR.N = +10000;
                boxR.E = +10000;
                boxR.W = -10000;
            case ladoE
                boxR.N = +10000;
                boxR.S = -10000;
                boxR.W = -10000;
            otherwise %ladoW
                boxR.N = +10000;
                boxR.S = -10000;
                boxR.E = +10000;
        end        
        
        if verbose
            boxR_.XData = [boxR.W boxR.E boxR.E boxR.W];
            boxR_.YData = [boxR.N boxR.N boxR.S boxR.S];
        end

        %ampliamos cuadro rojo hasta la mitad del vector velocidad
        switch better
            case ladoN
                boxR.N = (boxR.N + vy)/2;
            case ladoS
                boxR.S = (boxR.S + vy)/2;
            case ladoE
                boxR.E = (boxR.E + vx)/2;
            otherwise %ladoW
                boxR.W = (boxR.W + vx)/2;
        end
        
        if verbose
            boxR_.XData = [boxR.W boxR.E boxR.E boxR.W];
            boxR_.YData = [boxR.N boxR.N boxR.S boxR.S];
        end

        %calculo porcion del cuadro verde que deja el cuadro rojo
        %al convertirse en un semiplano
        switch better
            case ladoN
                boxG.S = max([boxG.S boxR.N]);
            case ladoS
                boxG.N = min([boxG.N boxR.S]);
            case ladoE
                boxG.W = max([boxG.W boxR.E]);
            otherwise %ladoW
                boxG.E = min([boxG.E boxR.W]);
        end

        if verbose
            boxG_.XData = [boxG.W boxG.E boxG.E boxG.W];
            boxG_.YData = [boxG.N boxG.N boxG.S boxG.S];
            delete(OBpos_);
            delete(boxR_)
        end

    end


    %comprobamos si sigue habiendo margen de movimiento
    if boxG.W >= boxG.E || boxG.S >= boxG.N
        %DETENERLO NO ES LA SOLUCION, PUESTO QUE SE
        %ESPERA QUE SIGA AVANZANDO. LO SUYO ES QUE AVANCE
        %HACIA LA POSICION QUE MINIMICE LA PENETRACION EN EL OBSTACULO
%         fprintf('Cuadro de velocidad vacio en nodo %d\n',i);

        obj.UAVvelF(i,1) = (boxG.W + boxG.E)/2;
        obj.UAVvelF(i,2) = (boxG.S + boxG.N)/2;

    else
        %calculamos mejor velocidad de entre las posible
        route = obj.UAVtarget(i,:) - obj.UAVpos(i,:);
        obj.UAVvelF(i,:) = obj.selectVel(route,boxG,obj.vel_max,verbose,i);
    end

end


function obj = Directnav(obj,i,verbose)
%metodo que genera la velocidad futura

    if obj.finUAV(i)
       return; 
    end

    %calculo velocidad directa a objetivo
    route = obj.UAVtarget(i,:) - obj.UAVpos(i,:);
    dist = norm(route);
    if dist == 0
        vd = [0 0];
    else
        vel_req = dist / obj.t_nav;
        vd = route / dist * min(vel_req,obj.vel_max);
    end
    vdx = vd(1);
    vdy = vd(2);
    obj.UAVvelF(i,:) = [vdx vdy];

end


function best_pto = selectVel(obj,route,box,vel_max,verbose,idUAV)

    if verbose
        axis([-vel_max +vel_max -vel_max +vel_max]) 
        c_ = viscircles([0 0],vel_max);
    end
    
    %calculo velocidad directa a objetivo truncada al circulo
    dist = norm(route);
    if dist == 0
        vd = [0 0];
    else
        vel_req = dist / obj.t_nav;
        vd = route / dist * min(vel_req,vel_max);
    end
    
    if verbose
        best_ = plot([0 vd(1)],[0 vd(2)],'c-','LineWidth',0.5);
    end

    %si la velocidad directa esta en la caja, es la mejor opción
    if obj.inside(vd,box)
        best_pto = vd;
        if verbose
            delete(c_)
            delete(best_)
        end
        return
    end

    %obtengo 8 puntos de corte caja/circulo
    vel = zeros(12,2);

    %puntos N
    y = box.N;
    x = sqrt(vel_max^2 - y^2);
    if obj.inside([x y],box)
        if verbose
            plot(x,y,'ob','LineWidth',2);
        end
        vel(1,:) = [x,y];
    end
    if obj.inside([-x y],box)
        if verbose
            plot(-x,y,'ob','LineWidth',2);
        end
        vel(8,:) = [-x,y];
    end

    %puntos S
    y = box.S;
    x = sqrt(vel_max^2 - y^2);
    if obj.inside([x y],box)
        if verbose
            plot(x,y,'ob','LineWidth',2);
        end
        vel(4,:) = [x,y];
    end
    if obj.inside([-x y],box)
        if verbose
            plot(-x,y,'ob','LineWidth',2);
        end
        vel(5,:) = [-x,y];
    end

    %puntos E
    x = box.E;
    y = sqrt(vel_max^2 - x^2);
    if obj.inside([x y],box)
        if verbose
            plot(x,y,'ob','LineWidth',2);
        end
        vel(2,:) = [x,y];
    end
    if obj.inside([x -y],box)
        if verbose
            plot(x,-y,'ob','LineWidth',2);
        end
        vel(3,:) = [x,-y];
    end

    %puntos W
    x = box.W;
    y = sqrt(vel_max^2 - x^2);
    if obj.inside([x y],box)
        if verbose
            plot(x,y,'ob','LineWidth',2);
        end
        vel(6,:) = [x,y];
    end
    if obj.inside([x -y],box)
        if verbose
            plot(x,-y,'ob','LineWidth',2);
        end
        vel(7,:) = [x,-y];
    end

    %esquina NE
    x = box.E; 
    y = box.N;
    if norm([x y]) <= vel_max
        vel(9,:)  = [x,y];
        if verbose
            plot(x,y,'ob','LineWidth',2);
        end
    end

    %esquina SE
    x = box.E; 
    y = box.S;
    if norm([x y]) <= vel_max
        vel(10,:)  = [x,y];
        if verbose
            plot(x,y,'ob','LineWidth',2);
        end
    end

    %esquina SW
    x = box.W; 
    y = box.S;
    if norm([x y]) <= vel_max
        vel(11,:)  = [x,y];
        if verbose
            plot(x,y,'ob','LineWidth',2);
        end
    end

    %esquina NW
    x = box.W; 
    y = box.N;
    if norm([x y]) <= vel_max
        vel(12,:)  = [x,y];
        if verbose
            plot(x,y,'ob','LineWidth',2);
        end
    end


    %elijo mejor opcion
    best_pto = [0 0];
    for i = 1:12
        ni = norm(vel(i,:));
        nb = norm(best_pto);
        if ni > nb
            best_pto = vel(i,:);
        elseif ni == nb
            ai = obj.angle(route,vel(i,:));
            ab = obj.angle(route,best_pto);
            %girar hacia derecha siempre (se podría elegir girar a la izq)
            if ai==ab && obj.UAVvel(idUAV,1)>0 %UAV con direccion derecha 
                if vel(i,2)<0 
                    best_pto = vel(i,:);
                end     
            elseif ai==ab && obj.UAVvel(idUAV,1)<0 %UAV con direccion izquierda
                if vel(i,2)>0 
                    best_pto = vel(i,:);
                end 
            elseif ai==ab && obj.UAVvel(idUAV,2)>0 %UAV con direccion arriba 
                if vel(i,1)>0 
                    best_pto = vel(i,:);
                end 
            elseif ai==ab && obj.UAVvel(idUAV,2)<0 %UAV con direccion abajo
            if vel(i,1)<0 
                best_pto = vel(i,:);
            end 
            elseif ai < ab
                best_pto = vel(i,:);
            end
        end
    end

    if verbose
        plot([0 best_pto(1)],[0 best_pto(2)],'g-','LineWidth',0.5);
    end
    
end


function in = inside(~,pto,box)
% indica si el punto esta en el interior de la caja
  x = pto(1);
  y = pto(2);

    if box.S <= y  &&  y <= box.N  &&  box.W <= x  &&  x <= box.E
        in = true;
    else
        in = false;
    end

end


function alpha = angle(~,v1,v2)
%obtiene el ángulo (en grados) entre dos vectores dados
    d = dot(v1,v2);
    c = d / (norm(v1) * norm(v2));
    alpha = acosd(c);
end


function obj = ConflictUpdate(obj)
    %deteccion de conflictos
    for i = 1:obj.numUAVs - 1 
        if obj.finUAV(i)
            continue
        end
        for j = i+1:obj.numUAVs
            if obj.finUAV(j)
                continue
            end
            dist = norm(obj.UAVpos(j,:) - obj.UAVpos(i,:));
            if dist < 2 * obj.UAVrad
                %fprintf('COLISION entre %d y %d\n',i,j);
                obj.conflictUAV(i,j)=1; 
            end
        end
    end    
end


function [fin,obj] = TargetsReached(obj,t)
    %deteccion de fin de simulación
    fin = true;
    for i = 1:obj.numUAVs
        %comprobamos si ha terminado
        if obj.finUAV(i) == 1
            continue;
        else
            dist = norm(obj.UAVtarget(i,:) - obj.UAVpos(i,:));
            if dist > 1
                fin = false;
                %return
            else
                obj.finUAV(i) = 1;
                if obj.timeTotal(i)==0
                    obj.timeTotal(i) = t; 
                end      
            end
        end
    end
end


function obj = CreateAREAfig(obj)
    figName = 'AREA';
    obj.AREAfig = findobj('Type','figure','Name',figName)';
    if (isempty(obj.AREAfig)) 
        figPosition(1:2) = [100 0];   % posición deseada
        figPosition(3:4) = [700 700]; % tamaño deseado
        obj.AREAfig = figure( ...
            'Name',figName, ...
            'NumberTitle','off', ...
            'Position',figPosition, ...
            'Resize','on');
    else
        clf(obj.AREAfig);
    end


    figure(obj.AREAfig)

    % eje 
    axesHandler = axes(      ...
      'Parent', obj.AREAfig,  ...
      'Units','normalized', ...
      'Visible','on');
    grid(axesHandler,'on')
    hold(axesHandler,'on')
    axis([-obj.area +obj.area -obj.area +obj.area 0 50]) 
    % mapa fondo
%     I = imread('mapa.jpg'); 
%     h = image(xlim,-ylim,I); 
%     uistack(h,'bottom')

    %pinto los circulos de los UAVs
    handle = fill([0 1 1 0],[0 0 1 1],'r');
    obj.UAV_ = repmat(handle,obj.numUAVs,1);
    delete(handle)
    % Circulo tipo
    numpts = 17;    % cantidad de vertices que tendra el poligono 
    ls = linspace(0,2*pi,numpts);  
    circleX = obj.UAVrad * sin(ls);
    circleY = obj.UAVrad * cos(ls);
    obj.circle = [circleX' circleY'];

    for i = 1:obj.numUAVs
        handle = fill([0 1 1 0],[0 0 1 1],'w',...
                        'EdgeColor','k',...
                        'LineWidth',1,...
                        'FaceColor',[i/obj.numUAVs,1-i/obj.numUAVs,0],...
                        'FaceAlpha',0.5);
        obj.UAV_(i) = handle;
        obj.UAV_(i).Vertices = obj.UAVpos(i,:) + obj.circle;
        obj.UAV_(i).Faces =  1:numpts;
        obj.textCircle(i) = text(obj.UAVpos(i,1),obj.UAVpos(i,2),int2str(i));

    end
end


function obj = CreateVELfig(obj)
    figName = 'VEL';
    obj.VELfig = findobj('Type','figure','Name',figName)';
    if (isempty(obj.VELfig)) 
        figPosition(1:2) = [900 0];   % posición deseada
        figPosition(3:4) = [400 400]; % tamaño deseado
        obj.VELfig = figure( ...
            'Name',figName, ...
            'NumberTitle','off', ...
            'Position',figPosition, ...
            'Resize','on');
    else
        clf(obj.VELfig);
    end

    figure(obj.VELfig)

    % eje 
    axesHandler = axes(      ...
      'Parent', obj.VELfig,  ...
      'Units','normalized', ...
      'Visible','on');
    grid(axesHandler,'on')
    hold(axesHandler,'on')

end


function obj = countConflict(obj)
    for i = 1:obj.numUAVs - 1 
        for j = i+1:obj.numUAVs
            if obj.conflictUAV(i,j)
                obj.numConflictTotal =  obj.numConflictTotal + 1;
            end
        end
    end  
end


end %methods
end %classdef

