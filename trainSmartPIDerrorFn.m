function J = trainSmartPIDerrorFn(W, app)

    ind = 1;    
    %Layer1    
    for i = 1:app.layer1Sz 
        app.IW(i,:)=W(ind:ind+app.inpSz-1);ind=ind+app.inpSz;
    end
    app.b1=W(ind:ind+app.layer1Sz-1)';ind=ind+app.layer1Sz;
    %Layer2
    app.LW(1,:)=W(ind:ind+app.layer1Sz-1);ind=ind+app.layer1Sz;
    app.LW(2,:)=W(ind:ind+app.layer1Sz-1);ind=ind+app.layer1Sz;
    app.LW(3,:)=W(ind:ind+app.layer1Sz-1);ind=ind+app.layer1Sz;
    app.b2=W(ind:ind+3-1)';
   
    assignin('base','app',app)
    set_param(app.system,'SimulationCommand','start')
    while strcmp(get_param(app.system,'SimulationStatus'),'running')
        %disp(get_param('test','SimulationStatus'))
        pause(0.1)  
    end    
    
    simout = evalin('base', 'simout');
    simout1 = evalin('base', 'simout1');

    %disp(get_param('test','SimulationStatus'))

    F = simout.Data;
    U = simout1.Data;

    percentDone = 100 * app.Counter / size(W, 2);
    app.Counter = app.Counter + 1;
    msg = sprintf('Percent done: %3.1f', percentDone);
    fprintf([app.reverseStr, msg]);
    app.reverseStr = repmat(sprintf('\b'), 1, length(msg));
   
    if app.SEEDsw == 2 
        app.SEED=floor(rand * 10000); 
    end
    
    % settling time in sec
    t = 20;    
    F(1:t,1) = 0;
    U(t:100,1) = 0;
    
    F(100:100+t,1) = 0;
    U(100+t:200,1) = 0;
    
    F(200:200+t,1) = 0;
    U(200+t:size(F,1),1) = 0;

    J = sqrt(F.^2 + U.^2);

end

