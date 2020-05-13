clear; clc;

figure(1); clf;
axis([0 100 0 100])
grid on; hold on;

r = 5;          % radio de los objetos
v = 10;         % velocidad de desplazamiento
t = (0:1:10)';  % instantes en los que pintar la estela

%objeto 1 (verde)
%posición 
p1_0 = [10 50];
P1_0 = viscircles(p1_0,r);
P1_0.Children(1).Color = [0 1 0];

%velocidad
v1 = [1 0]; 
v1 = v1 * v / norm(v1);
p1_t = p1_0 + v1 .* t;
P1_t = plot(p1_t(:,1),p1_t(:,2),'og');


%objeto 2 (rojo)
%posición 
p2_0 = [30 10];
P2_0  = viscircles(p2_0,r);
P2_0.Children(1).Color = [1 0 0];

%velocidad
v2 = [1 5]; 
v2 = v2 * v / norm(v2);
p2_t = p2_0 + v2 .* t;
P2_t = plot(p2_t(:,1),p2_t(:,2),'or');



test_conflict(p1_0,v1,p2_0,v2,r)




function t_conflict = test_conflict(p1,v1,p2,v2,r)

    p1_x0 = p1(1);  p1_y0 = p1(2);
    v1_x  = v1(1);  v1_y  = v1(2);
    p2_x0 = p2(1);  p2_y0 = p2(2);
    v2_x  = v2(1);  v2_y  = v2(2);


    %planteo ecuacion de segundo grado

    %calculo t^2
    t2 = v1_x^2 + v1_y^2 + v2_x^2 + v2_y^2;
    t2 = t2 - 2*v1_x*v2_x - 2*v1_y*v2_y;

    %calculo t
    t1 = 2*p1_x0*v1_x + 2*p1_y0*v1_y + 2*p2_x0*v2_x + 2*p2_y0*v2_y ;
    t1 = t1 - 2*p1_x0*v2_x - 2*p2_x0*v1_x - 2*p1_y0*v2_y - 2*p2_y0*v1_y ;

    %calculo termino independiente
    t0 = p1_x0^2 + p1_y0^2 + p2_x0^2 + p2_y0^2 ; 
    t0 = t0 - 2*p1_x0*p2_x0 - 2*p1_y0*p2_y0 ;
    t0 = t0 - 4*r^2 ; 

    %resuelvo la ecuación
    t_conflicts = roots([t2 t1 t0]);

    if isreal(t_conflicts)

        t_conflict = min(t_conflicts);
        
        %pinto colisión
        t_conflicts = t_conflict; %solo pinto colision entrante

        p1_conflict = p1 + v1 .* t_conflicts;
        P1_conflict = viscircles(p1_conflict,t_conflicts*0+r);
        P1_conflict.Children(1).Color = [0 1 0];

        p2_conflict = p2 + v2 .* t_conflicts;
        P2_conflict = viscircles(p2_conflict,t_conflicts*0+r);
        P2_conflict.Children(1).Color = [1 0 0];

    else
        %no hay conflicto
        t_conflict = inf;

    end
end