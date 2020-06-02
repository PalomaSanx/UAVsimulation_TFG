clear
clc

%% parametros
vel_max = 36.11; %(m/s) == 130 km/h
UAVrad = 2; %(m)
area = 5000/2; %(5km x 5km)
umbral = vel_max*2; %(m)

for numUAVs=25:25:100
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


    %% Simular 10 veces 
    for k=1:10

        %generamos escenario aleatorio
        [UAVpos, UAVtarget] = randScen(numUAVs,area); 

        %simulamos escenario sin BBCA (direct)
        run ("analiz_automatic_direct");
        %% Guardar figuras de cada simulación (recorrido final y estadisticas)
        print(figure(1),[ruta 'img_simulation_direct_',num2str(k)],'-dpdf');
        run("Analitics_direct");
        close all;
        clearvars -except vel_max UAVrad numUAVs UAVpos UAVtarget k ruta area umbral;
        
        %simulamos escenario con BBCA
        run ("analiz_automatic_BBCA");
        %% Guardar figuras de cada simulación (recorrido final y estadisticas)
        print(figure(1),[ruta 'img_simulation_BBCA_',num2str(k)],'-dpdf');
        run("Analitics_BBCA");
        close all;
        clearvars -except vel_max UAVrad numUAVs UAVpos UAVtarget k ruta area umbral;
    end
end

%envio de mail para avisar de finalización
sendMail();


%% funciones

% Generar escenario aleatorio
function [UAVpos, UAVtarget] = randScen(numUAVs, area)
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
    % [Optional] Remove the preferences (for privacy reasons)
    setpref('Internet','E_mail','');
    setpref('Internet','SMTP_Server','''');
    setpref('Internet','SMTP_Username','');
    setpref('Internet','SMTP_Password','');

end
