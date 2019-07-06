function stop = trainSmartPIDoutFn(W,optimValues,state,app)

stop = app.stop;

switch state
    case 'init'
        disp('init')

    case {'iter','interrupt'}
        disp(['iter','interrupt'])
        
        ind = 1;
        %Layer1    
        for i = 1:app.layer1Sz 
            app.net2.IW{1,1}(i,:)=W(ind:ind+app.inpSz-1);ind=ind+app.inpSz;
        end
        app.net2.b{1}=W(ind:ind+app.layer1Sz-1)';ind=ind+app.layer1Sz;
        %Layer2
        app.net2.LW{2,1}(1,:)=W(ind:ind+app.layer1Sz-1);ind=ind+app.layer1Sz;
        app.net2.LW{2,1}(2,:)=W(ind:ind+app.layer1Sz-1);ind=ind+app.layer1Sz;
        app.net2.LW{2,1}(3,:)=W(ind:ind+app.layer1Sz-1);ind=ind+app.layer1Sz;
        app.net2.b{2,1}=W(ind:ind+3-1)';
        
        if app.inpSz == 1
            disp(app.net2(0))
        elseif app.inpSz == 2
            disp(app.net2([0; 50]))
        end
  
        if app.SEEDsw == 1
            app.SEED=floor(rand * 10000);
            fprintf('set SEED=%d\n', app.SEED);
        end
        
        app.Counter = 0;
        app.reverseStr = '';
        
    case 'done'
        disp('done')
end