clc;
clear;


%% GESTION DE LA FIGURA

figName = 'RADAR';
figHandler = findobj('Type','figure','Name',figName)';
if (isempty(figHandler)) 
    figPosition(1:2) = [500 0];   % asignamos la posición deseada
    figPosition(3:4) = [700 700];   % asignamos el tamaño deseado
else
    figPosition = get(figHandler,'Position');
    delete(figHandler);
end


% figura
figHandler = figure( ...
    'Name',figName, ...
    'NumberTitle','off', ...%  'MenuBar', 'none', ...
    'Position',figPosition, ...
    'Resize','on');

% eje 
axesHandler = axes(      ...
  'Parent', figHandler,  ...
  'Units','normalized', ...%   'Position',[0.0800 0.0800 0.9000 0.9000], ...
  'Visible','on');
%     xlabel('axis X (meters)')
%     ylabel('axis Y (meters)')
%     zlabel('altitude  (meters)')
grid(axesHandler,'on')
hold(axesHandler,'on')
axis([-500 +500 -500 +500 0 50]) 
title('Simulador para el testeo de algoritmo')


% Circulo tipo
UAVrad = 50;    % radio en m      
numpts = 40;    % cantidad de vertices que tendra el poligono
ls = linspace(0,2*pi,numpts);  
circleX = UAVrad * sin(ls);
circleY = UAVrad * cos(ls);
circle = [circleX' circleY'];



%% DEFINICION DE UAVS
run("banco de pruebas/eval1_4A_100V");

% pinto destinos de UAVs
for i = 1:numUAVs
    scatter(UAVtarget(i,1),UAVtarget(i,2),1500,[i/numUAVs,1-i/numUAVs,0],'o'); %destinos de UAVs 
end 

%% SIMULACION          


t_end  = 10000; %fin de simulación  (s)
t_step = 1;     %paso de simulación (s)


for t = 1:t_step:t_end
    
    
    equals = false;
    for i = 1:numUAVs
        
        %velocidad actual
        vx = UAVvel(i,1);
        vy = UAVvel(i,2);
        v_ = plot([0 vx],[0 vy],'k-','LineWidth',2);              
                    
        
        %para todos los intrusos
        for j = 1:numUAVs
            
            %me descarto a mi mismo
            if i == j 
                continue
            end
            
            tau    = t_step; % margen de tiempo en el que prevenir conflictos (s)
            conflict = false;
            
            
            % puede existir conflicto con intruso j
            for p=1:numUAVs
                if i == p 
                    distJ(p) = NaN;
                else
                    distJ(p) = norm(UAVpos(p,:) - UAVpos(i,:));
                end
            end
            
            mindistJ = find(distJ==min(distJ));
            
            collisionTime = test_conflict(UAVpos(i,:),UAVvel(i,:),UAVpos(j,:),UAVvel(j,:),UAVrad)
            
            if (~isempty(collisionTime) && collisionTime<Inf && collisionTime<1.5 && collisionTime>=0) || distJ(j) <= UAVrad*2
                conflict = true;
            end
            
            
            % distancia del intruso al objetivo 
            distTarget(i)= norm(UAVtarget(i,:) - UAVpos(i,:));
            distTarget(j)= norm(UAVtarget(j,:) - UAVpos(j,:));
            
            %DECISION DE QUIEN EVITA
            %lo evito
            if conflict && distTarget(i)==distTarget(j) && ~equals
              % lo evita el primero por ejemplo
                %obtengo obstaculo circular para interseccion
                OBpos  = UAVpos(j,:);
                OBrad  = 2 * UAVrad;
                OBpos_ = viscircles(OBpos,OBrad,'LineStyle','--');

                %obtengo el obstaculo circular para prevención
                OBpos2  = UAVpos(j,:);
                OBrad2  = 3 * UAVrad;
                OBpos2_ = viscircles(OBpos2,OBrad2, 'Color','g');
                
                %obtengo los puntos tangentes a circunferencia
                tang = ProyTangentes(UAVpos(i,:),OBpos2,OBrad2)
                
                %elijo el mejor punto
                distPuntoTarget(1,:) = norm(UAVtarget(j,:) - tang(1,:));
                distPuntoTarget(2,:) = norm(UAVtarget(j,:) - tang(2,:));
                
                betterPoint = tang(find(distPuntoTarget==max(distPuntoTarget)),:);
                if size(betterPoint,1)>1
                    route = UAVpos(j,:) - UAVpos(i,:);
                    rt_ = plot([UAVpos(i,1) -UAVpos(j,1)],[UAVpos(i,2) -UAVpos(j,2)],'r--'); 
                else
                    route = betterPoint - UAVpos(i,:);
                    rt_ = plot([UAVpos(i,1) betterPoint(1)],[UAVpos(i,2) betterPoint(2)],'r--'); 
                end
               

                dist = norm(route);
                if dist == 0
                    vd = [0 0];
                else
                    vel_req = dist / tau;
                    vd = route / dist * min(vel_req,vel_max);
                end
                if size(betterPoint,1)>1
                    vdx = -vd(1);
                    vdy = -vd(2);
                else
                    vdx = vd(1);
                    vdy = vd(2);
                end
                    
                UAVvelF(i,:) = [vdx vdy];
                
                delete(rt_);
                delete(OBpos_);
                delete(OBpos2_);
                
                equals = true;
                break
                
            elseif conflict && distTarget(i)>distTarget(j)
                
                %obtengo obstaculo circular para interseccion
                OBpos  = UAVpos(j,:);
                OBrad  = 2 * UAVrad;
                OBpos_ = viscircles(OBpos,OBrad,'LineStyle','--');

                %obtengo el obstaculo circular para prevención
                OBpos2  = UAVpos(j,:);
                OBrad2  = 3 * UAVrad;
                OBpos2_ = viscircles(OBpos2,OBrad2, 'Color','g');
                
                %obtengo los puntos tangentes a circunferencia
                tang = ProyTangentes(UAVpos(i,:),OBpos2,OBrad2)
                
                %elijo el mejor punto
                distPuntoTarget(1,:) = norm(UAVtarget(j,:) - tang(1,:));
                distPuntoTarget(2,:) = norm(UAVtarget(j,:) - tang(2,:));
                
                betterPoint = tang(find(distPuntoTarget==max(distPuntoTarget)),:)
                if size(betterPoint,1)>1
                    route = UAVtarget(i,:) - UAVpos(i,:);
                    rt_ = plot([UAVpos(i,1) UAVtarget(i,1)],[UAVpos(i,2) UAVtarget(i,2)],'r--'); 
                else
                    route = betterPoint - UAVpos(i,:);
                    rt_ = plot([UAVpos(i,1) betterPoint(1)],[UAVpos(i,2) betterPoint(2)],'r--'); 
                end
                dist = norm(route);
                if dist == 0
                    vd = [0 0];
                else
                    vel_req = dist / tau;
                    vd = route / dist * min(vel_req,vel_max);
                end
                if size(betterPoint,1)>1
                    vdx = -vd(1);
                    vdy = -vd(2);
                else
                    vdx = vd(1);
                    vdy = vd(2);
                end
                UAVvelF(i,:) = [vdx vdy];
                
                delete(rt_);
                delete(OBpos_);
                delete(OBpos2_);
                
                break
                
            else %me evita
                % velocidad directa a objetivo
                route = UAVtarget(i,:) - UAVpos(i,:);
                dist = norm(route);
                if dist == 0
                    vd = [0 0];
                else
                    vel_req = dist / tau;
                    vd = route / dist * min(vel_req,vel_max);
                end
                vdx = vd(1);
                vdy = vd(2);
                UAVvelF(i,:) = [vdx vdy];
            end
            
        end
    end
    
    
    
%-------------------------------------------------            
    
    
    %desplazamiento de UAVs en función de su velocidad actual
    UAVvel = UAVvelF;
    UAVvelF = zeros(numUAVs,2);
    for i = 1:numUAVs
        
        %movimiento
        xo = UAVpos(i,1);
        yo = UAVpos(i,2);
        UAVpos(i,:) = UAVpos(i,:) + UAVvel(i,:) * t_step;
      
        %actualizamos dibujo
        plot([xo UAVpos(i,1)],[yo UAVpos(i,2)],'k');
        UAV_(i).Vertices = UAVpos(i,:) + circle;
        textCircle(i).Position = UAVpos(i,:);
        
    end
    drawnow %limitrate nocallbacks;
    
    
    
    %deteccion de conflictos
    for i = 1:numUAVs - 1
        for j = i+1:numUAVs
            dist = norm(UAVpos(j,:) - UAVpos(i,:));
            if dist < 2 * UAVrad
                fprintf('%3.1f\tcolisión entre %d y %d\n',t,i,j);
                return
            end
        end
    end
    
    
    %detección de fin
    fin = true;
    for i = 1:numUAVs
        if norm(UAVvel(i,:)) > 0.01
            fin = false;
            break
        end
    end
    if fin
        break
    end
    
    
end

%test_conflict(p1_0,v1,p2_0,v2,r)


function t_conflict = test_conflict(p1,v1,p2,v2,r)

    p1_x0 = p1(1);  p1_y0 = p1(2);
    v1_x  = v1(1);  v1_y  = v1(2);
    p2_x0 = p2(1);  p2_y0 = p2(2);
    v2_x  = v2(1);  v2_y  = v2(2);


    %planteo ecuacion de segundo grado

    %calculo t^2
    t2 = v1_x^2 + v1_y^2 + v2_x^2 + v2_y^2;
    t2 = t2 - 2*v1_x*v2_x - 2*v1_y*v2_y;

    %calculo t
    t1 = 2*p1_x0*v1_x + 2*p1_y0*v1_y + 2*p2_x0*v2_x + 2*p2_y0*v2_y ;
    t1 = t1 - 2*p1_x0*v2_x - 2*p2_x0*v1_x - 2*p1_y0*v2_y - 2*p2_y0*v1_y ;

    %calculo termino independiente
    t0 = p1_x0^2 + p1_y0^2 + p2_x0^2 + p2_y0^2 ; 
    t0 = t0 - 2*p1_x0*p2_x0 - 2*p1_y0*p2_y0 ;
    t0 = t0 - 4*r^2 ; 

    %resuelvo la ecuación
    t_conflicts = roots([t2 t1 t0]);

    if isreal(t_conflicts)

        t_conflict = min(t_conflicts);
        
        %pinto colisión
        t_conflicts = t_conflict; %solo pinto colision entrante

        p1_conflict = p1 + v1 .* t_conflicts;
        P1_conflict = viscircles(p1_conflict,t_conflicts*0+r);
        %P1_conflict.Children(1).Color = [0 1 0];

        p2_conflict = p2 + v2 .* t_conflicts;
        P2_conflict = viscircles(p2_conflict,t_conflicts*0+r);
        %P2_conflict.Children(1).Color = [1 0 0];
        
        delete(P1_conflict);
        delete(P2_conflict);
        

    else
        %no hay conflicto
        t_conflict = inf;
    end
    
end

% Trasladar p tomando como origen al punto o 
function tras = trasPuntos(O,P) 
    tras = [P(1) - O(1),P(2) - O(2)];
end

% Rotar un punto respecto al origen.
% La rotacion se hace en orden CCW, para
% rotar en CW llamar Rotar(p, M_2PI - rad).
function rot = rotar(P,rad) 
    rot= [P(1)*cos(rad) - P(2)*sin(rad), P(1)*sin(rad) + P(2)*cos(rad)];
end


% Distancia entre dos puntos p y q.
function distPQ = distanciaPQ(P,Q) 
    distPQ = hypot(P(1) - Q(1), P(2) - Q(2));
end

% Distancia de un punto p a un circulo c
function distPuntoCirculo = distPC(P,C,Crad) 
     d = distanciaPQ(P, C) - Crad;
     if d < 0 
        distPuntoCirculo = 0;
     else
        distPuntoCirculo = d;
     end
end

% Magnitud de un vector p.
function mag = magnitud(P) 
    mag = hypot(P(1), P(2));
end

% Escalar un vector p por un factor s.
function esc = escalar(P, s) 
    esc = [P(1) * s, P(2) * s];
end

% Obtener vector opuesto.
function op = opuesto(v) 
    op = [-v(1), -v(2)];
end

% Proyecta un punto fuera de un circulo en su circunferencia.
function proyPC = proyectaPC(P, C, Crad) 
     v = trasPuntos(P, C);
     prop = distPC(P, C, Crad) / magnitud(v);
     proyPC = trasPuntos(opuesto(P), escalar(v, prop));
end


% Obtiene dos puntos que, desde el punto p, forman
% lineas tangentes a la circunferencia del circulo c.
function proyTang = ProyTangentes(P,C, Crad) 
    a = acos(Crad / distanciaPQ(P, C));
    p_ = trasPuntos(C, proyectaPC(P, C, Crad));
    proyTang = [trasPuntos(opuesto(C), rotar(p_, - a)); trasPuntos(opuesto(C), rotar(p_, a))];
end

