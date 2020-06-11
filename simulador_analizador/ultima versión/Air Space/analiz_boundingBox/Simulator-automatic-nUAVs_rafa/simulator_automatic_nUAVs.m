clear
clc

%% parametros
vel_max = 20.83; %(m/s) == 75 km/h
UAVrad = 10; %(m)
area = 5000/2; %(5km x 5km)
umbral = vel_max*2; %(m)

confBBCA = zeros(4,5);
confDir  = zeros(4,5);
h = 1;
for numUAVs=25:25:100
    fprintf("\n\n\n\nSimulación de %d UAVs\n\n",numUAVs);
    % prompt = {'Enter number of UAVs:'};
    %          dlgtitle = 'Input';
    %          dims = [1 35];
    %          answer = inputdlg(prompt,dlgtitle,dims);
    %          numUAVs = str2num(answer{1});
    nc = ['sim_',num2str(numUAVs),'_UAVs'];   % nombre carpeta de simulacion
    mkdir(nc);
    ruta = ['./' nc '/'];      
    % Guardo parametros en primera línea de outputLog
    outputLog = fopen([ruta 'outputLog.csv'],'w');
    fprintf(outputLog,"00,%03f,%05.2f,%05.3f,%05.2f,%05.2f\n" ...
                     ,numUAVs        ...
                     ,vel_max        ...
                     ,UAVrad         ...
                     ,area           ...
                     ,umbral);


    %% Simular 5 veces 
    for k=1:5
        fprintf("Iteración %d\n",k);
        %generamos escenario aleatorio
        [UAVpos, UAVtarget] = randScen(numUAVs,area); 

        %simulamos escenario sin BBCA (direct)
        tic
        fprintf("analiz_automatic_direct\t\t");
        typeNav = 'direct';
        run ("analiz_automatic");
        fprintf("%5.2f segundos\n",toc);
        
        %% Guardar figuras de cada simulación (recorrido final y estadisticas)
        print(figure(1),[ruta 'img_simulation_direct_',num2str(k)],'-dpdf');
        savefig(figure(1),[ruta 'img_simulation_direct_',num2str(k)],'compact')
        
        tic
        fprintf("Analitics_direct\t\t");
        run("Analitics_direct");
        fprintf("%5.2f segundos\n",toc);
        close all;
        confDir(h,k) = air.numConflictTotal;
        clearvars -except vel_max UAVrad numUAVs UAVpos UAVtarget k ruta area umbral distTotalDirect timeTotalDirect confDir confBBCA h;
        
        
        %simulamos escenario con BBCA
        tic
        fprintf("analiz_automatic_BBCA\t\t");
        typeNav = 'BBCA';
        run ("analiz_automatic");
        fprintf("%5.2f segundos\n",toc);
        
        %% Guardar figuras de cada simulación (recorrido final y estadisticas)
        print(figure(1),[ruta 'img_simulation_BBCA_',num2str(k)],'-dpdf');
        savefig(figure(1),[ruta 'img_simulation_BBCA_',num2str(k)],'compact')

        tic
        fprintf("Analitics_BBCA\t\t");
        run("Analitics_BBCA");
        fprintf("%5.2f segundos\n",toc);
        close all;
        confBBCA(h,k) = air.numConflictTotal;
        clearvars -except vel_max UAVrad numUAVs UAVpos UAVtarget k ruta area umbral confDir confBBCA h;
        
    end
    h = h + 1;
end

%obtengo gráficas estadísticas generales
run("Analitics_average");

%envio de mail para avisar de finalización
%sendMail();


%% funciones

% Generar escenario aleatorio
function [UAVpos, UAVtarget] = randScen(numUAVs, area)
    rng('shuffle'); % reestaurar numeros aleatorios
    area= area-50;%para evitar que aparezcan o vayan fuera del escenario
    r = round(-area + (area+area)*rand(numUAVs,4));
    for i=1:numUAVs
        UAVpos(i,:) = r(i,1:2);
        UAVtarget(i,:) = r(i,3:4);
    end
   
    dMin = 100; %separación mínima entre posiciones
    exit = false;
    while ~exit
        exit = true;
        for i=1:numUAVs
            for j=1:numUAVs
                if i==j
                    continue
                end
                if norm(UAVpos(j,:)-UAVpos(i,:))<dMin || norm(UAVtarget(j,:)-UAVtarget(i,:))<dMin
                    exit = false;
                    UAVpos(i,:) = round(-area + (area+area)*rand(1,2));
                    UAVtarget(i,:) = round(-area + (area+area)*rand(1,2));
                end
            end
        end
    end   
end

% enviar mail
function sendMail()
    % User input
    run("C:/Users/palom/Desktop/mail.m"); % include(source, myEmailPassword and destination)
    
    subj = 'Simulator BBCA';  % subject line
    msg = 'The simulation has finished';     % main body of email.
    %set up SMTP service for Gmail
    setpref('Internet','E_mail',source);
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','SMTP_Username',source);
    setpref('Internet','SMTP_Password',myEmailPassword);
    % Gmail server.
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    % Send the email
    sendmail(destination,subj,msg);

end
