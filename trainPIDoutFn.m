function stop = trainPIDoutFn(W,optimValues,state,app)

stop = app.stop;

switch state
    case 'init'
        disp('init')

    case {'iter','interrupt'}
        disp(['iter','interrupt'])
 
        if app.SEEDsw == 1
            app.SEED=floor(rand * 10000);
            fprintf('set SEED=%d\n', app.SEED);
        end
        
        app.Counter = 0;
        app.reverseStr = '';
        
    case 'done'
        disp('done')
end