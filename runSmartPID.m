set_param(app.system,'FastRestart','on')

%Layer1
IW=app.net.IW{1,1};
b1=app.net.b{1,1};
%Layer2
LW=app.net.LW{2,1};
b2=app.net.b{2,1};
inpR = app.net.input.range;
outR = app.net.output.range;

app.PIDsw=0;

for i=1:100
    app.SEED=floor(rand * 10000);
    fprintf('i=%d, set SEED=%d\n', i, app.SEED);
    
    app.PIDsw=0;
    assignin('base','app',app)
    set_param(app.system,'SimulationCommand','start')
    while strcmp(get_param(app.system,'SimulationStatus'),'running')
        %disp(get_param('test','SimulationStatus'))
        pause(0.1)  
    end
    
    simout = evalin('base', 'simout');
    
    PIDe = simout.Data;
    PIDe = mean(PIDe.^2);
        
    app.PIDsw=1;
    set_param(app.system,'SimulationCommand','start')
    while strcmp(get_param(app.system,'SimulationStatus'),'running')
        %disp(get_param('test','SimulationStatus'))
        pause(0.1)  
    end
    
    simout = evalin('base', 'simout');
    
    SmartPIDe = simout.Data;
    SmartPIDe = mean(SmartPIDe.^2);
    
    fprintf('PIDe=%g, SmartPIDe=%g, Difference=%g\n', PIDe, SmartPIDe, PIDe - SmartPIDe);
    
    if app.stop == true
        disp('stopped by user request');
        break;
    end
end