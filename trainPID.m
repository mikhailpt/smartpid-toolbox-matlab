%% net init (here only to get the Simulink model work)
bNetInit = true;

if bNetInit    
    N = 1000;

    noise = 30;
    x = noise * randn(2,N);
    t = randn(3,N);
    
    for i = 1:N
        x(:,i) = [noise * randn, noise * randn];
        t(:,i) = [0 + noise*randn,    0 + noise*randn,   0 + noise*randn];    
    end
    t(t(:,:) < 0) = 0;
    x(2,x(2,:) < 0) = 0;

    net = feedforwardnet(3);
    net = configure(net,x,t);

    net.input.range
    net.output.range

    K = [0  0  0];

    noise2 = 0.001;%.1;
    x = noise * randn(2,N);
    
    for i = 1:N   
        t(:,i) = [K(1,1) + noise2*randn,    K(1,2) + noise2*randn,   K(1,3) + noise2*randn];
    end

    net = train(net,x,t);

    net.input.range
    net.output.range
end

%%

%Layer1
app.IW=net.IW{1,1};
app.b1=net.b{1,1};
%Layer2
app.LW=net.LW{2,1};
app.b2=net.b{2,1};
app.inpR = net.input.range;
app.outR = net.output.range;
    
%%

% put your own init PID gains here
app.Kp=0.058654;
app.Ki=0.039875;
app.Kd=0.021569;

app.PIDsw=0;
app.SEEDsw=1;

app.SEED=532;
if app.SEEDsw > 0
    app.SEED=floor(rand * 10000);
end

%%

set_param(app.system,'FastRestart','on');

x = [app.Kp app.Ki app.Kd];
options = optimoptions(@lsqnonlin,'Algorithm','trust-region-reflective',...
   'Display','iter','TolX',1e-12,'TolFun',1e-6,'OutputFcn',@(p1,p2,p3)trainPIDoutFn(p1,p2,p3,app));
x = lsqnonlin(@(K)trainPIDerrorFn2(K,app), x, zeros(size(x)), [200 200 200], options);

%%

app.Kp=x(1);
app.Ki=x(2);
app.Kd=x(3);

%%

dlmwrite('data\StdPIDcoeffs.txt',[app.Kp; app.Ki; app.Kd]);