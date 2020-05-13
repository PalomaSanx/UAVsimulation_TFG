% Trasladar p tomando como origen al punto o 
function tras = trasPuntos(O,P) 
    tras = [P(1) - O(1),P(2) - O(2)];
end

% Rotar un punto respecto al origen.
% La rotacion se hace en orden CCW, para
% rotar en CW llamar Rotar(p, M_2PI - rad).
function rot = rotar(P,rad) 
    rot= [P(1)*cos(rad) - P(2)*sin(rad), P(1)*sin(rad) + P(2)*cos(rad)];
end


% Distancia entre dos puntos p y q.
function distPQ = distanciaPQ(P,Q) 
    distPQ = hypot(P(1) - Q(1), P(2) - Q(2));
end

% Distancia de un punto p a un circulo c
function distPuntoCirculo = distPC(P,C,Crad) 
     d = distanciaPQ(P, C) - Crad;
     if d < 0 
        distPuntoCirculo = 0;
     else
        distPuntoCirculo = d;
     end
end

% Magnitud de un vector p.
function mag = magnitud(P) 
    mag = hypot(P(1), P(2));
end

% Escalar un vector p por un factor s.
function esc = escalar(P, s) 
    esc = [P(1) * s, P(2) * s];
end

% Obtener vector opuesto.
function op = opuesto(v) 
    op = [-v(1), -v(2)];
end

% Proyecta un punto fuera de un circulo en su circunferencia.
function proyPC = proyectaPC(P, C, Crad) 
     v = trasPuntos(P, C);
     prop = distPC(P, C, Crad) / magnitud(v);
     proyPC = trasPuntos(opuesto(P), escalar(v, prop));
end


% Obtiene dos puntos que, desde el punto p, forman
% lineas tangentes a la circunferencia del circulo c.
function proyTang = ProyTangentes(P,C, Crad) 
    a = acos(Crad / distanciaPQ(P, C));
    p_ = trasPuntos(C, proyectaPC(P, C, Crad));
    proyTang = [trasPuntos(opuesto(C), rotar(p_, - a)); trasPuntos(opuesto(C), rotar(p_, a))];
end

