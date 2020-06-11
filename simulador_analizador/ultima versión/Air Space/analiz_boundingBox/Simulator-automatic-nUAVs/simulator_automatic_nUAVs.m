clear
clc


for k = 3:100 %simular varias veces 
    
    fprintf("\nIteración %d\n",k);
    
    for numUAVs = 10:10:100

        fprintf("\n\n\n\nSimulación de %d UAVs\n\n",numUAVs);
        nc = ['sim_',num2str(numUAVs),'_UAVs'];   % nombre carpeta de simulacion
        mkdir(nc);
        ruta = ['./' nc '/'];      


        %definición del escenario
        air = AirSpace(numUAVs);
        air.t_step   = 1;        %paso de simulación
        air.t_nav    = 10;
        air.UAVrad   = 50;       %(m)
        air.vel_max  = 13.89;    %(m/s) == 50 km/h
        air.area     = 5000/2;   %(5km x 5km)
        air.randScen(); 
%         air.UAVposInit = [-1000 0; 0 -1000];
%         air.UAVtarget  = [ 1000 0; 0  1000];

        %simulamos escenario directo (direct)
        tic
        fprintf("Navegación directa\t\t");
        air.typeNav = 'direct';
        air.Run();  
        save([ruta 'air_',num2str(k),'_direct'],'air');
        fprintf("%2.0f conflictos\t",air.numConflictTotal);
        fprintf("%5.2f segundos\n",toc);


        % Guardar figuras de cada simulación (recorrido final y estadisticas)
        print(figure(1),[ruta 'img_simulation_direct_',num2str(k)],'-dpdf');
        savefig(figure(1),[ruta 'img_simulation_direct_',num2str(k)],'compact')
        Analitics_direct;

        close all;



        %simulamos escenario con BBCA
        tic
        fprintf("Navegación BBCA   \t\t");
        air.typeNav = 'BBCA';
        air.Run();      
        save([ruta 'air_',num2str(k),'_BBCA'],'air');
        fprintf("%2.0f conflictos\t",air.numConflictTotal);
        fprintf("%5.2f segundos\n",toc);

        % Guardar figuras de cada simulación (recorrido final y estadisticas)
        print(figure(1),[ruta 'img_simulation_BBCA_',num2str(k)],'-dpdf');
        savefig(figure(1),[ruta 'img_simulation_BBCA_',num2str(k)],'compact')
        Analitics_BBCA();

        close all;

    end
end

%obtengo gráficas estadísticas generales
Analitics_average();

%envio de mail para avisar de finalización
%sendMail();


%% funciones


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
