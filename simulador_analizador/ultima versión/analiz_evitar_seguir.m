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
title('Control de colisiones UAV')


% Circulo tipo
UAVrad = 50;    % radio en m      
numpts = 40;    % cantidad de vertices que tendra el poligono
ls = linspace(0,2*pi,numpts);  
circleX = UAVrad * sin(ls);
circleY = UAVrad * cos(ls);
circle = [circleX' circleY'];



%% DEFINICION DE UAVS

numUAVs = 6;    %max = 10; (min = 2) 

UAVpos = [  300 -100
           -300 -100
           300 -300
           000 -400
          -300 300
          -400 -200
          -400  100
          300  300
          200 100
          100 -200
          300 100
          200 -400];


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

      
vel_max = UAVrad/3;               %velocidad m�xima   (m/s)
UAVvel  = zeros(numUAVs,2); %velocidad actual
UAVvelF = zeros(numUAVs,2); %velocidad en el paso siguiente
umbral = vel_max; %margen para maniobrar ante una colision

UAVtarget = [ -400 -100
             000 000
             -400 -300
              300  300
              200  000
              -200 200
              300 -300 
              -400 -400
              -200 100
              -400 000 
              200 -400
               300 100];
          
                 
for i = 1:numUAVs
    scatter(UAVtarget(i,1),UAVtarget(i,2),1500,[i/numUAVs,1-i/numUAVs,0],'o'); %destinos de UAVs 
end 


%% SIMULACION          


t_end  = 10000; %fin de simulaci�n  (s)
t_step = 0.5;     %paso de simulaci�n (s)

for t = 1:t_step:t_end
    
    %calculo desplazamiento de cada UAV
    for i = 1:numUAVs
        
        % descarto si ya he llegado al destino 
        if UAVpos(i,:)==UAVtarget(i,:)
            continue;
        end     
        
        tau=t_step;
        
        %velocidad actual
        vx = UAVvel(i,1);
        vy = UAVvel(i,2);
             
        
       
            %calculo distancia de i a intrusos
            for k = 1:numUAVs
                if i == k
                    continue
                end
                d(i)=NaN;
                d(k) = norm(UAVpos(k,:) - UAVpos(i,:));
                d2 = min(d);  
                if d(k)<(UAVrad*2)+umbral
                    cerca(i,k)=1;
                else
                    cerca(i,k)=0;
                end
            end
            
            % Si no hay conflicto (sigo mi velocidad a objetivo)
                if ~(d2<(UAVrad*2)+umbral)
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

                else % Hay conflicto
                    for j=1:numUAVs
                        if j==i
                            continue
                        end
                        % para el intruso m�s cercano
                        if j == find(d2==d)
                            fprintf('UAV %d muy cerca de %d\n',i,j);
                            % calculo quien esta m�s cerca del destino
                            route = UAVtarget(i,:) - UAVpos(i,:);
                            distmia = norm(route);
                            route = UAVtarget(j,:) - UAVpos(j,:);
                            distsuya = norm(route);
                            if distmia > distsuya && sum(cerca(i,:))<2 && sum(UAVpos(find(d==min(d)),:)==UAVtarget(find(d==min(d)),:))~=2
                                %me evita
                                    %pero si el intruso tiene a m�s de uno que evitar (lo evito tambi�n)
                                    if sum(cerca(j,:))>=2
                                        route = UAVpos(find(d==min(d)),:) - UAVpos(i,:);
                                        dist = norm(route);
                                        if dist == 0
                                            vd = [0 0];
                                        else
                                            vel_req = dist / tau;
                                            vd = route / dist * min(vel_req,vel_max);
                                        end
                                        %selecciono velocidad (que evite al intruso)
                                        vdx = -vd(1)/2;
                                        vdy = -vd(2)/2;
                                        UAVvelF(i,:) = [vdx vdy];
                                    else
                                        route = UAVtarget(i,:) - UAVpos(i,:);
                                        dist = norm(route);
                                        if dist == 0
                                            vd = [0 0];
                                        else
                                            vel_req = dist / tau;
                                            vd = route / dist * min(vel_req,vel_max);
                                        end
                                        vdx = vd(1)/2;
                                        vdy = vd(2)/2;
                                        UAVvelF(i,:) = [vdx vdy];
                                    end
                            else
                                %lo evito
                                %calculo velocidad directa a intruso cercano
                                route = UAVpos(find(d==min(d)),:) - UAVpos(i,:);
                                dist = norm(route);
                                if dist == 0
                                    vd = [0 0];
                                else
                                    vel_req = dist / tau;
                                    vd = route / dist * min(vel_req,vel_max);
                                end
                                %selecciono velocidad (que evite al intruso)
                                vdx = -vd(1)/2;
                                vdy = -vd(2)/2;
                                UAVvelF(i,:) = [vdx vdy];
                                % Si el intruso que quiero evitar ya esta en su destino 
                                % y el mio esta cerca (mi velocidad es la directa a mi destino)
                                if sum(UAVpos(find(d==min(d)),:)==UAVtarget(find(d==min(d)),:))==2 && (norm(UAVtarget(i,:)-UAVpos(i,:))<UAVrad || round(UAVpos(i,1)-UAVtarget(i,1))==0|| round(UAVpos(i,2)-UAVtarget(i,2))==0) 
                                    route = UAVtarget(i,:) - UAVpos(i,:);
                                    dist = norm(route);
                                    if dist == 0
                                        vd = [0 0];
                                    else
                                        vel_req = dist / tau;
                                        vd = route / dist * min(vel_req,vel_max);
                                    end
                                    vdx = vd(1)/2;
                                    vdy = vd(2)/2;
                                    UAVvelF(i,:) = [vdx vdy];
                                end
                            end
                        end
                    end  
                end
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
            if dist < 2 * UAVrad -2
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
