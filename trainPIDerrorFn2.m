function J = trainPIDerrorFn2(parms,app)
    
    app.Kp = parms(1);
    app.Ki = parms(2);
    app.Kd = parms(3);
    
    assignin('base','app',app)
    set_param(app.system,'SimulationCommand','start')
    
    while strcmp(get_param(app.system,'SimulationStatus'),'running')
        %disp(get_param('test','SimulationStatus'))
        pause(0.1)  
    end

    %disp(get_param('test','SimulationStatus'))
    
    simout = evalin('base', 'simout');
    simout1 = evalin('base', 'simout1');
    
    F = simout.Data;
    U = simout1.Data;
     
    % settling time in sec
    t = 20; 
    
    F(1:t,1) = 0;
    U(t:100,1) = 0;
    
    F(100:100+t,1) = 0;
    U(100+t:200,1) = 0;
    
    F(200:200+t,1) = 0;
    U(200+t:size(F,1),1) = 0;
    
    J = sqrt(F.^2 + U.^2);
    
    %plot(J)
    
    fprintf('J=%g Kp=%g Ki=%g Kd=%g\n', mean(J.^2), app.Kp, app.Ki, app.Kd);

    if app.SEEDsw == 2
        app.SEED=floor(rand * 10000);
        fprintf('set SEED=%d\n', app.SEED);
    end
    
end