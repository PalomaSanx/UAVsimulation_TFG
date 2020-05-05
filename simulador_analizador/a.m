function a

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
title('Control de colisiones UAV')


% Circulo tipo
UAVrad = 50;    % radio en m      
numpts = 40;    % cantidad de vertices que tendra el poligono
ls = linspace(0,2*pi,numpts);  
circleX = UAVrad * sin(ls);
circleY = UAVrad * cos(ls);
circle = [circleX' circleY'];



%% DEFINICION DE UAVS

numUAVs = 2;    %max = 10; (min = 2) 

UAVpos = [ -400 -100
           -400 -200
           000 400
           -400 -100
           -300 -300
           000 400
           400 -100
           300 -300
           000 -400
          -300 -300
          -400 -100
          -400  100
          -300  300 ];


for i = 1:numUAVs
    UAV_(i) = fill([0 1 1 0],[0 1 0 1],'w',...
                    'EdgeColor','k',...
                    'LineWidth',1,...
                    'FaceColor',[i/numUAVs,1-i/numUAVs,0],...
                    'FaceAlpha',0.5);
    UAV_(i).Vertices = UAVpos(i,:) + circle;
    UAV_(i).Faces =  1:numpts;
    textCircle(i) = text(UAVpos(i,1),UAVpos(i,2),int2str(i));
end

      
vel_max = 100;               %velocidad máxima   (m/s)
UAVvel  = zeros(numUAVs,2); %velocidad actual
UAVvelF = zeros(numUAVs,2); %velocidad en el paso siguiente
      
UAVtarget = [ 000 -400
             000 -200
             100 -400
             000 -400
             -400 -100
             -400 -100
             -400  100
             -300  300
              000  400
              300  300
              400  100
              400 -100
              300 -300  ];
                  
          
%% SIMULACION          


t_end  = 10000; %fin de simulación  (s)
t_step = 1;     %paso de simulación (s)

for t = 1:t_step:t_end
    
    %calculo desplazamiento de cada UAV
    for i = 1:numUAVs
        
        % descarto si ya he llegado al destino 
        if UAVpos(i,:)==UAVtarget(i,:) 
            continue
        end

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
            %en función de la posición del vecino 
            tau    = 1; % margen de tiempo en el que prevenir conflictos (s)
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
            
            boxY.N =  boxR.N;
            boxY.S =  boxR.S;
            boxY.E =  boxR.E;
            boxY.W =  boxR.W;
            
            boxY_ = fill(...
                    [boxY.W boxY.E boxY.E boxY.W],...
                    [boxY.N boxY.N boxY.S boxY.S],...
                    'y',...
                    'EdgeColor','none','LineWidth',0.5,...
                    'FaceColor','y','FaceAlpha',0.1);
            %desplazo el cuadro ROJO en función de la velocidad relativa
            boxR.N = boxR.N - vy + UAVvel(j,2);
            boxR.S = boxR.S - vy + UAVvel(j,2);
            boxR.E = boxR.E - vx + UAVvel(j,1);
            boxR.W = boxR.W - vx + UAVvel(j,1);

            boxR_.XData = [boxR.W boxR.E boxR.E boxR.W];
            boxR_.YData = [boxR.N boxR.N boxR.S boxR.S];
            

            
            %trunco rectangulo verde con cuartiplano rojo
            if     boxR.S < boxG.S && boxG.N < boxR.N && ...
                   boxR.W < boxG.W && boxG.E < boxR.E
                %el rectangulo rojo cubre completamente al rectangulo verde
                %ESTO ESTA MAL
                
                boxG.N = 0;
                boxG.S = 0;
                boxG.E = 0;
                boxG.W = 0;
               
                 fprintf('%3.1f\tRECTANGULO ROJO CUBRE AL VERDE\n',t,i,j);
                 
               
%                 if UAVvel(i,1)>=UAVpos(i,1) % estaba girando derecha
%                     boxG.N = boxG.N;
%                     boxG.S = boxG.S;
%                     boxG.E = boxG.E+25;
%                     boxG.W = boxG.W;
%                 elseif UAVvel(i,1)<UAVpos(i,1) % estaba girando izquierda
%                     boxG.N = boxG.N;
%                     boxG.S = boxG.S;
%                     boxG.E = boxG.E;
%                     boxG.W = boxG.W-25;
%                 end 
% 
%                 if UAVvel(i,2)>0 % estaba subiendo
%                     boxG.N = boxG.N+25;
%                     boxG.S = boxG.S;
%                     boxG.E = boxG.E;
%                     boxG.W = boxG.W;
%                 elseif UAVvel(i,2)<0 % estaba bajando
%                     boxG.N = boxG.N;
%                     boxG.S = boxG.S-25;
%                     boxG.E = boxG.E;
%                     boxG.W = boxG.W;
%                 end                 
                
            elseif boxR.S > boxG.N || boxR.N < boxG.S || ...
                   boxR.W > boxG.E || boxR.E < boxG.W
                %el rectangulo rojo no toca al rectangulo verde
                %no hay que hacer nada
            else
            
                if boxR.S > boxG.S
                    boxG.N = min(boxG.N,boxR.S);   %trunco arriba
                    
                elseif boxR.N < boxG.N
                    boxG.S = max(boxG.S,boxR.N);   %trunco abajo
                
                elseif boxR.E < boxG.E
                    boxG.W = max(boxG.W,boxR.E);   %trunco izquierda
                
                else %boxR.W > boxG.W
                    boxG.E = min(boxG.E,boxR.W);   %trunco derecha
                end
                
                boxG_.XData = [boxG.W boxG.E boxG.E boxG.W];
                boxG_.YData = [boxG.N boxG.N boxG.S boxG.S];
                
            end
            
%-----------------------------------------------------------------------             
            %calculo distancia a lados
            %(distancia negativa indica que estoy dentro)
            disN = vy     - boxR.N;
            disS = boxR.S - vy;
            disE = vx     - boxR.E;
            disW = boxR.W - vx;
            
            N=1;
            S=1;
            E=1;
            W=1;
            if boxY.E==10000 && boxY.S==-10000
                N=boxR.N;
                W=boxR.W;
            elseif boxY.W==-10000 && boxY.S==-10000
                N=boxR.N;
                E=boxR.E;
                
            elseif boxY.N==10000 && boxY.E==10000
                W=boxR.W;
                S=boxR.S;
                
            else % boxY.W==-10000 && boxY.N==10000
                E=boxR.E;
                S=boxR.S;
                
            end
            
            %elijo lado mas apropiado
            %(mas cerca de salir o mas lejos de entrar)
            better = max([disN disS disE disW]);
            
            %generamos obstaculo de velocidad lineal
            %(semiplano vertical u horizontal)
            
            if disN == better
                boxR.N = vy - disN/2;
                boxG.S  = max([boxG.S boxR.N]);
                boxR.S = -10000;
                boxR.E = +10000;
                boxR.W = -10000;
            elseif disS == better
                boxR.N = +10000;
                boxR.S = vy + disS/2;
                boxG.N  = min([boxG.N boxR.S]);
                boxR.E = +10000;
                boxR.W = -10000;
            elseif disE == better
                boxR.N = +10000;
                boxR.S = -10000;
                boxR.E = vx - disE/2;
                boxG.W  = max([boxG.W boxR.E]);
                boxR.W = -10000;
            else %if disW == better
                boxR.N = +10000;
                boxR.S = -10000;
                boxR.E = +10000;
                boxR.W = vx + disW/2;
                boxG.E  = min([boxG.E boxR.W]);
            end
%-----------------------------------------------------------------------             

            
            %comprobamos si sigue habiendo margen de movimiento
            if boxG.W >= boxG.E || boxG.S >= boxG.N
                %DETENERLO NO ES LA SOLUCION, PUESTO QUE SE
                %ESPERA QUE SIGA AVANZANDO. LO SUYO ES QUE AVANCE
                %HACIA LA POSICION QUE MINIMICE LA PENETRACION EN EL OBSTACULO
                fprintf('%3.1f\tRECTANGULO VERDE VACIO (%01.f,%01.f)\n',t,i,j);
                
                
                boxG.N=S;
                boxG.S=N;
                boxG.E=W;
                boxG.W=E;
                if boxR.S > boxG.S
                    boxG.N = min(boxG.N,boxR.S);   %trunco arriba
                    
                elseif boxR.N < boxG.N
                    boxG.S = max(boxG.S,boxR.N);   %trunco abajo
                
                elseif boxR.E < boxG.E
                    boxG.W = max(boxG.W,boxR.E);   %trunco izquierda
                
                else %boxR.W > boxG.W
                    boxG.E = min(boxG.E,boxR.W);   %trunco derecha
                end
                
                
                boxG_.XData = [boxG.W boxG.E boxG.E boxG.W];
                boxG_.YData = [boxG.N boxG.N boxG.S boxG.S];
                
                %return
   
               
            end    
            
            boxR_.XData = [boxR.W boxR.E boxR.E boxR.W];
            boxR_.YData = [boxR.N boxR.N boxR.S boxR.S];

            boxG_.XData = [boxG.W boxG.E boxG.E boxG.W];
            boxG_.YData = [boxG.N boxG.N boxG.S boxG.S];
            
            boxY_.XData = [boxY.W boxY.E boxY.E boxY.W];
            boxY_.YData = [boxY.N boxY.N boxY.S boxY.S];
            
            delete(OBpos_);
            delete(boxR_)
            delete(boxY_)
            
            
        end
        
        %calculo velocidad directa a objetivo
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
        vd_ = plot([0 vdx],[0 vdy],'c-','LineWidth',0.5);
        
        
        % obtengo velocidad siguiente de entre las validas
        vdx = min(vdx,boxG.E);   %trunco por derecha
        vdx = max(vdx,boxG.W);   %trunco por izquierda
        vdy = min(vdy,boxG.N);   %trunco por arriba
        vdy = max(vdy,boxG.S);   %trunco por abajo
        vF_ = plot([0 vdx],[0 vdy],'g-','LineWidth',2);                
        
        UAVvelF(i,:) = [vdx vdy];
        
        delete(v_)
        delete(vF_)
        delete(vd_)
        delete(boxG_);
    
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



end