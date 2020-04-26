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
title('Control de colisiones UAV: analizador de algoritmos')


% Circulo tipo
UAVrad = 50;    % radio en m      
numpts = 20;    % cantidad de vertices que tendra el poligono
ls = linspace(0,2*pi,numpts);  
circleX = UAVrad * sin(ls);
circleY = UAVrad * cos(ls);
circle = [circleX' circleY'];

% Linea tipo
X = zeros(1,2);
Y = zeros(1,2);

%% DEFINICION DE UAVS

numUAVs = 10;

UAVpos = [ 000  400
           300  300
           400  100
           400 -100
           300 -300
           000 -400
          -300 -300
          -400 -100
          -400  100
          -300  300 ];


for i = 1:numUAVs
    UAVline(i) = line(X,Y,'color',[i/numUAVs,1-i/numUAVs,0]);
    UAVline(i).XData = X;
    UAVline(i).YData =  Y;
    
end     
      

for i = 1:numUAVs
    UAVcircle(i) = fill([0 1 1 0],[0 1 0 1],[i/numUAVs,1-i/numUAVs,0]);
    UAVcircle(i).Vertices = UAVpos(i,:) + circle;
    UAVcircle(i).Faces =  1:numpts;

    textCircle(i) = text(UAVpos(i,1),UAVpos(i,2),int2str(i));
    conflict(i) = false;
end

      
UAVvel = zeros(numUAVs,2);      
      
UAVtarget = [ 000 -400
             -300 -300
             -400 -100
             -400  100
             -300  300
              000  400
              300  300
              400  100
              400 -100
              300 -300 ];


          
%% SIMULACION          


t_end  = 2000;  %la simulación acaba a los 200s
t_step = 1;    %paso de simulación

vel_max = 1;   %velocidad máxima en m/s


for t = 0:t_step:t_end     
    
    for i = 1:numUAVs
        
        %ruta y distancia al objetivo
        route = UAVtarget(i,:) - UAVpos(i,:);
        dist = norm(route);
        
        %calculo velocidad
        if dist == 0
            UAVvel(i,:) = 0;
        elseif conflict(i)
            % Mecanismo de evitación de colisiones
                UAVvel(i,1) = UAVvel(i,1)-UAVvel(uavMinDist(i,2),1);
                UAVvel(i,2) = UAVvel(i,2)-UAVvel(uavMinDist(i,2),2);
                
        else
            UAVvel(i,:) = route / dist * vel_max;
        end
        
        %nos movemos
        UAVpos(i,:) = UAVpos(i,:) + UAVvel(i,:) * t_step;
        textCircle(i).Position = UAVpos(i,:);
        
        %actualizamos dibujo
        UAVcircle(i).Vertices = UAVpos(i,:) + circle;
        
        %actualizamos lineas
        for j=2:UAVrad*2
            X(1) = UAVpos(i,1);
            Y(1) = UAVpos(i,2);
            X(j) = UAVpos(i,1)+UAVvel(i,1)*j;
            Y(j) = UAVpos(i,2)+UAVvel(i,2)*j;    
        end
        
         UAVline(i).XData=X;
         UAVline(i).YData=Y;
         
        % calculamos UAV más cercano
        count=0;
        for id=1:numUAVs
            for id2=1:numUAVs
                if id2==id
                    id2=id2+1;
                else
                    d(id2,:)=UAVpos(id,:)-UAVpos(id2,:);
                    di(id2)=norm(d(id2,:));
                    % Calculamos si existe conflicto
                    if ~(di < UAVrad+UAVrad)
                        conflict(id)=false;
                    else
                        conflict(id)=true;
                    end
                    uavMinDist(id,:)=[min(di) find(di==min(di),1)];
                end
            end           
        end
        
        
    end
    
    %Redibuja la escena
    drawnow %limitrate nocallbacks;
   
    
end
