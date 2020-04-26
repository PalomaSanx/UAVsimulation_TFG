classdef RADARclass < handle
properties

    %figura del radar
    figName;
    figHandler;
    figPosition;
    
    %lista de puntos en pantalla
    UAVptos;
    

end
methods(Static)

function obj = RADARclass()
    obj.figName = 'RADAR';
    obj.figHandler = findobj('Type','figure','Name',obj.figName)';
    if (isempty(obj.figHandler)) 
        obj.figPosition(1:2) = [500 0];   % asignamos la posición deseada
        obj.figPosition(3:4) = [700 700];   % asignamos el tamaño deseado
    else
        obj.figPosition = get(obj.figHandler,'Position');
        delete(obj.figHandler);
    end
end

end
methods

function checkFig(obj)
    % construimos la figura en caso de que se haya cerrado
    obj.figHandler = findobj('Type','figure','Name',obj.figName)';
    if ~isempty(obj.figHandler)
        return
    end
    
    % figura
    obj.figHandler = figure( ...
        'Name',obj.figName, ...
        'NumberTitle','off', ...%  'MenuBar', 'none', ...
        'Position',obj.figPosition, ...
        'Resize','on');

    % eje 
    axesHandler = axes(      ...
      'Parent', obj.figHandler,  ...
      'Units','normalized', ...%   'Position',[0.0800 0.0800 0.9000 0.9000], ...
      'Visible','on');
%     xlabel('axis X (meters)')
%     ylabel('axis Y (meters)')
%     zlabel('altitude  (meters)')
    grid(axesHandler,'on')
    hold(axesHandler,'on')
    axis([-500 +500 -500 +500 0 30]) 
    title('Control de colisiones UAV')

    % Quito manejadores de puntos eliminados
    obj.UAVptos = plot3(0,0,0,'o','MarkerEdgeColor','none','Tag','0','Visible','off');
        
end
    
    
function updateACpto(obj,UAVenabled,UAVid,UAVx,UAVy,UAVz)
    %Actualiza un punto en la pantalla del RADAR
    %Buscamos el punto correspondiente a este drone
    UAVfound = false;
    UAVid2 = num2str(UAVid);
    for i = 1:length(obj.UAVptos)
        if strcmp(UAVid2,obj.UAVptos(i).Tag)
            UAVfound = true;            
            break
        end
    end
    
    %Gestionamos el punto
    if (UAVenabled)
        if (~UAVfound)
            % Crea un nuevo punto
            UAVpto = plot3(UAVx,UAVy,UAVz,'^',...
                          'MarkerEdgeColor','none',...
                          'MarkerFaceColor','r',...
                          'Tag',UAVid2);
            
            obj.UAVptos = [obj.UAVptos UAVpto];
        else        
            % Pintamos la estela del punto
            plot3([obj.UAVptos(i).XData UAVx],...
                  [obj.UAVptos(i).YData UAVy],...
                  [obj.UAVptos(i).ZData UAVz],...
                   ':','Color','blue');
            % Actualiza la posición del punto
            obj.UAVptos(i).XData = UAVx;
            obj.UAVptos(i).YData = UAVy;
            obj.UAVptos(i).ZData = UAVz;         
%            text(ACx,ACy,ACz,num2str(ACid),'HorizontalAlignment','left','FontSize',8);
        end
    else
        if (UAVfound)
            % borra el punto
            delete(obj.UAVptos(i));
            obj.UAVptos = [obj.UAVptos(1:i-1) obj.UAVptos(i+1:length(obj.UAVptos))];
        end
    end

    %Redibuja la escena
    drawnow limitrate nocallbacks;


end
    


end % methods
end % classdef

