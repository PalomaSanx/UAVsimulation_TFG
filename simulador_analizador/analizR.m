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
numpts = 20;    % cantidad de vertices que tendra el poligono
ls = linspace(0,2*pi,numpts);  
circleX = UAVrad * sin(ls);
circleY = UAVrad * cos(ls);
circle = [circleX' circleY'];



%% DEFINICION DE UAVS

numUAVs = 10;    %max = 10;

UAVpos = [ 000  400
           400  000
           400  100
           400 -100
           300 -300
           000 -400
          -300 -300
          -400 -100
          -400  100
          -300  300 ];


for i = 1:numUAVs
    UAV_(i) = fill([0 1 1 0],[0 1 0 1],[i/numUAVs,1-i/numUAVs,0]);
    UAV_(i).Vertices = UAVpos(i,:) + circle;
    UAV_(i).Faces =  1:numpts;
    textCircle(i) = text(UAVpos(i,1),UAVpos(i,2),int2str(i));
end

      
vel_max = 5;               %velocidad máxima   (m/s)
UAVvel  = zeros(numUAVs,2); %velocidad actual
UAVvelF = zeros(numUAVs,2); %velocidad en el paso siguiente

for i=1:4
    div(i) = 2;
end

count=zeros(1,4);

deadlock=zeros(1,numUAVs);
      
UAVtarget = [ 000 -400
              -400 200
             -400 -100
             -400  100
             -300  300
              000  400
              300  300
              400  100
              400 -100
              300 -300 ];
                  
          
%% SIMULACION          


t_end  = 10000; %fin de simulación  (s)
t_step = 1;    %paso de simulación (s)

for t = 0:t_step:t_end
    
    %desplazamiento de UAVs en función de su velocidad actual
    for i = 1:numUAVs

               

        %defino rectangulo valido de velocidad 
        box.N =  vel_max;
        box.S = -vel_max;
        box.E =  vel_max;
        box.W = -vel_max;
%         box_ = plot([box.W box.E box.E box.W box.W],[box.N box.N box.S box.S box.N]);
        
        % para todos los intrusos
        for j = 1:numUAVs
            if i == j 
                continue
            end
            
            %obtengo el obstaculo de velocidad circular
            tau    = 5; % margen de tiempo en el que prevenir conflictos (s)
            OBpos  = (UAVpos(j,:) - UAVpos(i,:)) / tau;
%             plot(OBpos(1),OBpos(2),'rx');
            OBrad  = 2* UAVrad / tau+1;
%            OBpos_ = viscircles(OBpos,OBrad);

            
            %defino obstaculo de velocidad rectangular
            box2.N = +10000;
            box2.S = -10000;
            box2.E = +10000;
            box2.W = -10000;
           
            if OBpos(1) < 0
                box2.E = OBpos(1) + OBrad;
            else
                box2.W = OBpos(1) - OBrad;
            end
            if OBpos(2) < 0
                box2.N = OBpos(2) + OBrad;
            else
                box2.S = OBpos(2) - OBrad;
            end
            

%             if OBpos(1) + OBrad <= 0
%                 box2.E = OBpos(1) + OBrad;
%             end
%             if OBpos(1) - OBrad >= 0
%                 box2.W = OBpos(1) - OBrad;
%             end
%             if OBpos(2) + OBrad <= 0
%                 box2.N = OBpos(2) + OBrad;
%             end
%             if OBpos(2) - OBrad >= 0
%                 box2.S = OBpos(2) - OBrad;
%             end
            
%                box2_ = plot([box2.W box2.E box2.E box2.W box2.W],[box2.N box2.N box2.S box2.S box2.N],'g');
            
               %            delete(OBpos_);

            
            %obtengo velocidad conjunta
            OBvel  = (UAVvel(i,:) - UAVvel(j,:));
%             OBvel_ = plot([0 OBvel(1)],[0 OBvel(2)],'o-');
            
            %calculo distancia a lados
            %(distancia negativa indica que estoy dentro)
            disN = OBvel(2) - box2.N;
            disS = box2.S   - OBvel(2);
            disE = OBvel(1) - box2.E;
            disW = box2.W   - OBvel(1);
            
            %elijo lado mas apropiado
            %(mas cerca de salir o mas lejos de entrar)
            better = max([disN disS disE disW]);
            
            %generamos obstaculo de velocidad lineal
            %(semiplano vertical u horizontal)
            
            
            if deadlock(i)
              A=[disN disS disE disW];
              [M,I] = max(A);
            end

            
            if disN == better
                box2.N = UAVvel(i,2) - disN/2;
                box.S  = max([box.S box2.N]);
                box2.S = -10000;
                box2.E = +10000;
                box2.W = -10000;
            elseif disS == better
                box2.N = +10000;
                box2.S = UAVvel(i,1) + disS/2;
                box.N  = min([box.N box2.S]);
                box2.E = +10000;
                box2.W = -10000;
            elseif disE == better
                box2.N = +10000;
                box2.S = -10000;
                box2.E = UAVvel(i,1) - disE/2;
                box.W  = max([box.W box2.E]);
                box2.W = -10000;
            else %if disW == better
                box2.N = +10000;
                box2.S = -10000;
                box2.E = +10000;
                box2.W = UAVvel(i,1) + disW/2;
                box.E  = min([box.E box2.W]);
            end
            
              
%             box2_ = ([box2.W box2.E box2.E box2.W box2.W],[box2.N box2.N box2.S box2.S box2.N]);
   
            
%             box2_.XData = [box2.W box2.E box2.E box2.W box2.W];
%             box2_.YData = [box2.N box2.N box2.S box2.S box2.N];
% 
%             box_.XData = [box.W box.E box.E box.W box.W];
%             box_.YData = [box.N box.N box.S box.S box.N];
%             
%             delete(OBvel_)
%             delete(box2_)
            
            
        end
        
        %calculo velocidad directa a objetivo
        route = UAVtarget(i,:) - UAVpos(i,:);
        dist = norm(route);
        if dist == 0
            vel_dir = [0 0];
        else
            vel_req = dist / tau;
            vel_dir = route / dist * min(vel_req,vel_max);
        end 
        
        
        % obtengo velocidad siguiente de entre las validas
        UAVvelF(i,:) = vel_dir;
        UAVvelF(i,1) = min(UAVvelF(i,1),box.E);   %trunco por derecha
        UAVvelF(i,1) = max(UAVvelF(i,1),box.W);   %trunco por izquierda
        UAVvelF(i,2) = min(UAVvelF(i,2),box.N);   %trunco por arriba
        UAVvelF(i,2) = max(UAVvelF(i,2),box.S);   %trunco por abajo
        
%         delete(box_);
        

        
        
    end
    
    
    
%-------------------------------------------------            
    
    
    %desplazamiento de UAVs en función de su velocidad actual
    UAVvel = UAVvelF;
    UAVvelF = zeros(numUAVs,2);
    for i = 1:numUAVs
        %movimiento
        UAVpos(i,:) = UAVpos(i,:) + UAVvel(i,:) * t_step;
        textCircle(i).Position = UAVpos(i,:);
        
        
        if abs(UAVpos(i,1)) > 1000 || abs(UAVpos(i,2)) > 1000
            kk = 0;
        end
        
        if sum(abs(round(UAVpos(i,:))-UAVtarget(i,:))>[50 50])>=1 && (sum(round(UAVvel(i,:))==0)==2)
           deadlock(i) = 1
        else
           deadlock(i) = 0;
        end
        
        
        %actualizamos dibujo
        UAV_(i).Vertices = UAVpos(i,:) + circle;
    end
    drawnow %limitrate nocallbacks;
    
    
    
    %deteccion de conflictos
    conflict = false;
    for i = 1:numUAVs - 1
        if conflict
            break
        end
        for j = i+1:numUAVs
            dist = norm(UAVpos(j,:) - UAVpos(i,:));
            if dist < 2 * UAVrad
                fprintf('%3.1f\tcolisión entre %d y %d a %3f\n',t,i,j,dist);
                conflict = true;
                break
            end
        end
    end
    if conflict
        break
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
