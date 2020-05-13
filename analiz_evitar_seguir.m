function UAVvel = analiz_evitar_seguir(UAVrad,numUAVs,UAVpos,UAVtarget)

%% GESTION DE LA FIGURA


%% SIMULACION          


t_end  = 10000; %fin de simulación  (s)
t_step = 0.5;     %paso de simulación (s)

vel_max = UAVrad/3;               %velocidad máxima   (m/s)
UAVvel  = zeros(numUAVs,2); %velocidad actual
UAVvelF = zeros(numUAVs,2); %velocidad en el paso siguiente
cerca = zeros(numUAVs,numUAVs);
umbral = vel_max; %margen para maniobrar ante una colision
d2 = double(0);

d=NaN(1,numUAVs);
    
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
                        % para el intruso más cercano
                        if j == find(d2==d)
                            %fprintf('UAV %d muy cerca de %d\n',i,j);
                            % calculo quien esta más cerca del destino
                            route = UAVtarget(i,:) - UAVpos(i,:);
                            distmia = norm(route);
                            route = UAVtarget(j,:) - UAVpos(j,:);
                            distsuya = norm(route);
                            if distmia > distsuya %&& sum(cerca(i,:))<2 && sum(UAVpos(find(d==min(d)),:)==UAVtarget(find(d==min(d)),:))~=2
                                %me evita
                                    %pero si el intruso tiene a más de uno que evitar (lo evito también)
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
%                                 if sum(UAVpos(find(d==min(d)),:)==UAVtarget(find(d==min(d)),:))==2 && (norm(UAVtarget(i,:)-UAVpos(i,:))<UAVrad || round(UAVpos(i,1)-UAVtarget(i,1))==0|| round(UAVpos(i,2)-UAVtarget(i,2))==0) 
%                                     route = UAVtarget(i,:) - UAVpos(i,:);
%                                     dist = norm(route);
%                                     if dist == 0
%                                         vd = [0 0];
%                                     else
%                                         vel_req = dist / tau;
%                                         vd = route / dist * min(vel_req,vel_max);
%                                     end
%                                     vdx = vd(1)/2;
%                                     vdy = vd(2)/2;
%                                     UAVvelF(i,:) = [vdx vdy];
%                                 end
                            end
                        end
                    end  
                end
    end
    
    
    
%-------------------------------------------------            
    
    
    %desplazamiento de UAVs en función de su velocidad actual
    UAVvel = UAVvelF;
    
    
    
end