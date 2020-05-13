%% DEFINICION DE UAVS

numUAVs = 3;    %max = 10;

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
    UAV_(i) = fill([0 1 1 0],[0 1 0 1],'w',...
                    'EdgeColor','k',...
                    'LineWidth',1,...
                    'FaceColor',[i/numUAVs,1-i/numUAVs,0],...
                    'FaceAlpha',0.5);
    UAV_(i).Vertices = UAVpos(i,:) + circle;
    UAV_(i).Faces =  1:numpts;
    textCircle(i) = text(UAVpos(i,1),UAVpos(i,2),int2str(i));
end

      
vel_max = 50;               %velocidad máxima   (m/s)
UAVvel  = zeros(numUAVs,2); %velocidad actual
UAVvelF = zeros(numUAVs,2); %velocidad en el paso siguiente
      
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
                  
     