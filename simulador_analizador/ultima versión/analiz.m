clc;
clear;


%% GESTION DE LA FIGURA

figName = 'RADAR';
figHandler = findobj('Type','figure','Name',figName)';
if (isempty(figHandler)) 
    figPosition(1:2) = [500 0];   % asignamos la posici�n deseada
    figPosition(3:4) = [700 700];   % asignamos el tama�o deseado
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
run("banco de pruebas/eval2_4A_100V");


%% SIMULACION          


t_end  = 10000; %fin de simulaci�n  (s)
t_step = 1;     %paso de simulaci�n (s)

for t = 1:t_step:t_end
    
    %calculo desplazamiento de cada UAV
    for i = 1:numUAVs
        
        %velocidad actual
        vx = UAVvel(i,1);
        vy = UAVvel(i,2);
        v_ = plot([0 vx],[0 vy],'k-','LineWidth',2);                
        
        
        %defino cuadro VERDE: velocidades validas
        boxG.N =  vel_max;
        boxG.S = -vel_max;
        boxG.E =  vel_max;
        boxG.W = -vel_max;
        boxG_ = fill(...
                    [boxG.W boxG.E boxG.E boxG.W], ...
                    [boxG.N boxG.N boxG.S boxG.S], ...
                    'g',...
                    'EdgeColor','none','LineWidth',0.5,...
                    'FaceColor','g','FaceAlpha',0.1);

        
        %para todos los intrusos
        for j = 1:numUAVs
            
            %me descarto a mi mismo
            if i == j 
                continue
            end
            
            %obtengo el obstaculo de velocidad circular
            %en funci�n de la posici�n del vecino 
            tau    = t_step; % margen de tiempo en el que prevenir conflictos (s)
            OBpos  = (UAVpos(j,:) - UAVpos(i,:)) / tau;
            OBrad  = 2 * UAVrad / tau;
            OBpos_ = viscircles(OBpos,OBrad);

            
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

            
            boxR_ = fill(...
                    [boxR.W boxR.E boxR.E boxR.W],...
                    [boxR.N boxR.N boxR.S boxR.S],...
                    'r',...
                    'EdgeColor','none','LineWidth',0.5,...
                    'FaceColor','r','FaceAlpha',0.1);
            
            
            %desplazo el cuadro ROJO en funci�n de la velocidad relativa
            boxR.N = boxR.N + UAVvel(j,2);
            boxR.S = boxR.S + UAVvel(j,2);
            boxR.E = boxR.E + UAVvel(j,1);
            boxR.W = boxR.W + UAVvel(j,1);

            boxR_.XData = [boxR.W boxR.E boxR.E boxR.W];
            boxR_.YData = [boxR.N boxR.N boxR.S boxR.S];


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
            if better == ladoN
                boxR.S = -10000;
                boxR.E = +10000;
                boxR.W = -10000;
            elseif better == ladoS
                boxR.N = +10000;
                boxR.E = +10000;
                boxR.W = -10000;
            elseif better == ladoE
                boxR.N = +10000;
                boxR.S = -10000;
                boxR.W = -10000;
            else %if better == ladoW
                boxR.N = +10000;
                boxR.S = -10000;
                boxR.E = +10000;
            end
            boxR_.XData = [boxR.W boxR.E boxR.E boxR.W];
            boxR_.YData = [boxR.N boxR.N boxR.S boxR.S];

            
            %ampliamos cuadro rojo hasta la mitad del vector velocidad
            if better == ladoN
                boxR.N = (boxR.N + vy)/2;
            elseif better == ladoS
                boxR.S = (boxR.S + vy)/2;
            elseif better == ladoE
                boxR.E = (boxR.E + vx)/2;
            else %if better == ladoW
                boxR.W = (boxR.W + vx)/2;
            end
            boxR_.XData = [boxR.W boxR.E boxR.E boxR.W];
            boxR_.YData = [boxR.N boxR.N boxR.S boxR.S];
            
            %calculo porcion del cuadro verde que deja el cuadro rojo
            %al convertirse en un semiplano
            if better == ladoN
                boxG.S = max([boxG.S boxR.N]);
            elseif better == ladoS
                boxG.N = min([boxG.N boxR.S]);
            elseif better == ladoE
                boxG.W = max([boxG.W boxR.E]);
            else %if better == ladoW
                boxG.E = min([boxG.E boxR.W]);
            end
            

            boxG_.XData = [boxG.W boxG.E boxG.E boxG.W];
            boxG_.YData = [boxG.N boxG.N boxG.S boxG.S];
            
            delete(OBpos_);
            delete(boxR_)
 
        end
        

        %comprobamos si sigue habiendo margen de movimiento
        if boxG.W >= boxG.E || boxG.S >= boxG.N
            %DETENERLO NO ES LA SOLUCION, PUESTO QUE SE
            %ESPERA QUE SIGA AVANZANDO. LO SUYO ES QUE AVANCE
            %HACIA LA POSICION QUE MINIMICE LA PENETRACION EN EL OBSTACULO
            fprintf('%3.1f\tCuadro de velocidad vacio en nodo %d\n',t,i);             
            
            %calculo distancia de i a intrusos

%             for k = 1:numUAVs
%                 if i == k
%                     continue
%                 end
%                 d(i)=NaN;
%                 d(k) = norm(UAVpos(k,:) - UAVpos(i,:));
%                 d2 = min(d);  
%                 
%             end
%             
%             for m=1:numUAVs
%                         if m==i
%                             continue
%                         end
%                         % para el intruso m�s cercano
%                         if m == find(d2==d) && m==j
%             
%                             UAVvelF(i,1) = (-UAVvel(j,1));
%                             UAVvelF(i,2) = (-UAVvel(j,2));
%                             
%                         else
                          if UAVvel(i,2)<0
                            UAVvelF(i,1) = min(max(boxG.W , boxG.E)*2,-vel_max)
                            UAVvelF(i,2) = min(max(boxG.S , boxG.N)*2,-vel_max)
                          else
                            UAVvelF(i,1) = min(max(boxG.W , boxG.E)*2,vel_max);
                            UAVvelF(i,2) = min(max(boxG.S , boxG.N)*2,vel_max)
                          end
%                         end
%             end
%             destine2 = scatter(UAVpos(i,1)+UAVvelF(i,1)*t_step,UAVpos(i,1)+UAVvelF(i,2)*t_step,100,'g','x'); 
%             delete(destine2);

        else
            %calculamos mejor velocidad de entre las posible
            route = UAVtarget(i,:) - UAVpos(i,:);
            UAVvelF(i,:) = setVel(route,boxG,vel_max,tau);
        
        end
        
        

        figure(1)
        delete(v_)
        delete(boxG_);
    
    end
    
    
    
%-------------------------------------------------            
    
    
    %desplazamiento de UAVs en funci�n de su velocidad actual
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
                fprintf('%3.1f\tcolisi�n entre %d y %d\n',t,i,j);
                return
            end
        end
    end
    
    
    %detecci�n de fin
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

function best_pto = setVel(route,box,vel_max,tau)

    figHandler = figure(2);
    clf
    grid on
    hold on
    axis equal
    
    viscircles([0 0],vel_max);
    
%     box.N =  60; 
%     box.E =  100; 
%     box.S = -50; 
%     box.W =  40;
    
    fill(...
            [box.W box.E box.E box.W], ...
            [box.N box.N box.S box.S], ...
            'g',...
            'EdgeColor','none','LineWidth',0.5,...
            'FaceColor','g','FaceAlpha',0.1);




    %calculo velocidad directa a objetivo truncada al circulo
    dist = norm(route);
    if dist == 0
        vd = [0 0];
    else
        vel_req = dist / tau;
        vd = route / dist * min(vel_req,vel_max);
    end
    plot([0 vd(1)],[0 vd(2)],'c-','LineWidth',0.5);

    
    %si la velocidad directa esta en la caja, es la mejor opci�n
    if inside(vd,box)
        best_pto = vd;
        delete(figHandler)
        return
    end



    %obtengo 8 puntos de corte caja/circulo
    vel = zeros(12,2);
   
    %puntos N
    y = box.N;
    x = sqrt(vel_max^2 - y^2);
    if inside([x y],box)
        plot(x,y,'ob','LineWidth',2);
        vel(1,:) = [x,y];
    end
    if inside([-x y],box)
        plot(-x,y,'ob','LineWidth',2);
        vel(8,:) = [-x,y];
    end

    %puntos S
    y = box.S;
    x = sqrt(vel_max^2 - y^2);
    if inside([x y],box)
        plot(x,y,'ob','LineWidth',2);
        vel(4,:) = [x,y];
    end
    if inside([-x y],box)
        plot(-x,y,'ob','LineWidth',2);
        vel(5,:) = [-x,y];
    end
        
    %puntos E
    x = box.E;
    y = sqrt(vel_max^2 - x^2);
    if inside([x y],box)
        plot(x,y,'ob','LineWidth',2);
        vel(2,:) = [x,y];
    end
    if inside([x -y],box)
        plot(x,-y,'ob','LineWidth',2);
        vel(3,:) = [x,-y];
    end
    
    %puntos W
    x = box.W;
    y = sqrt(vel_max^2 - x^2);
    if inside([x y],box)
        plot(x,y,'ob','LineWidth',2);
        vel(6,:) = [x,y];
    end
    if inside([x -y],box)
        plot(x,-y,'ob','LineWidth',2);
        vel(7,:) = [x,-y];
    end
  
    %esquina NE
    x = box.E; 
    y = box.N;
    if norm([x y]) <= vel_max
        vel(9,:)  = [x,y];
        plot(x,y,'ob','LineWidth',2);
    end
    
    %esquina SE
    x = box.E; 
    y = box.S;
    if norm([x y]) <= vel_max
        vel(10,:)  = [x,y];
        plot(x,y,'ob','LineWidth',2);
    end
    
    %esquina SW
    x = box.W; 
    y = box.S;
    if norm([x y]) <= vel_max
        vel(11,:)  = [x,y];
        plot(x,y,'ob','LineWidth',2);
    end
    
    %esquina NW
    x = box.W; 
    y = box.N;
    if norm([x y]) <= vel_max
        vel(12,:)  = [x,y];
        plot(x,y,'ob','LineWidth',2);
    end
    
    %elijo mejor opcion
    best_pto = [0 0];
    
    
     % punto cercano a mi direcci�n
    
    boxY.N =  vel_max;
    boxY.S = -vel_max;
    boxY.E =  vel_max;
    boxY.W = -vel_max;
    
   if vd(2)>box.N && box.N~=0
        y=box.N;
        x=vd(1);
        if inside([x y],box) && inside([x y],boxY)
            best_pto = [-x y];
        end
        plot(x,y,'or','LineWidth',2);
    elseif vd(2)<box.S 
        y=box.S;
        x=vd(1);
        if inside([x y],box) && inside([x y],boxY)
            best_pto = [x y];
        end
        plot(x,y,'or','LineWidth',2);
    elseif vd(1)<box.W
        y=vd(2);
        x=box.W;
        if inside([x y],box) && inside([x y],boxY)
            best_pto = [x y];
        end
        plot(x,y,'or','LineWidth',2);
    elseif vd(1)>box.E
        y=vd(2);
        x=box.E;
        if inside([x y],box) && inside([x y],boxY)
            best_pto = [x y];
        end
        plot(x,y,'or','LineWidth',2);
    end
    
    
    
    
    for i = 1:12
        ni = norm(vel(i,:));
        nb = norm(best_pto);
        if ni > nb
            ai = angle(route,vel(i,:));
            ab = angle(route,best_pto);
            if ai < ab+10 || nb == 0
                best_pto = vel(i,:);
            end
        elseif ni == nb
            ai = angle(route,vel(i,:));
            ab = angle(route,best_pto);
            if ai < ab
                best_pto = vel(i,:);
            end
        end
    end
    
   
    plot([0 best_pto(1)],[0 best_pto(2)],'g-','LineWidth',0.5);
    delete(figHandler)

end


function in = inside(pto,box)
  x = pto(1);
  y = pto(2);
  %si la velocidad directa esta en la caja, es la mejor opci�n
    if box.S <= y  &&  y <= box.N  &&  box.W <= x  &&  x <= box.E
        in = true;
    else
        in = false;
    end

end

function alpha = angle(v1,v2)
    d = dot(v1,v2);
    c = d / (norm(v1) * norm(v2));
    alpha = acosd(c);
end

