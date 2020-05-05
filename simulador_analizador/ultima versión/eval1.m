%% DEFINICION DE UAVS

numUAVs = 6;    %max = 10;

UAVpos = [ 300 -200
          -356 -375
           400  105
          -300  300
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
end

      
vel_max = 100;               %velocidad máxima   (m/s)
UAVvel  = zeros(numUAVs,2); %velocidad actual
UAVvelF = zeros(numUAVs,2); %velocidad en el paso siguiente
      
UAVtarget = [-200  300
              300  300
             -400 -100
              000 -300
             -300  300
              000  400
              300  -400
              400  100
              400 -100
              300 -300 ];
                  
     