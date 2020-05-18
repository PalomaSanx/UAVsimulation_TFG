clc
hold on
connectionObj = uavDubinsConnection;


startPose = [10 10 20 0]; % [meters, meters, meters, radians]
goalPose = [0 0 0 0];


[pathSegObj,pathCosts] = connect(connectionObj,startPose,goalPose);


show(pathSegObj{1})


fprintf('Tipo de movimeinto: %s\nCoste ruta: %f\n',strjoin(pathSegObj{1}.MotionTypes),pathCosts);



