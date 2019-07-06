%% net init
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

    K = [app.Kp  app.Ki  app.Kd];

    noise2 = 0.001;%.1;
    x = noise * randn(2,N);
    for i = 1:N   
        t(:,i) = [K(1,1) + noise2*randn, K(1,2) + noise2*randn, K(1,3) + noise2*randn];
    end

    net = train(net,x,t);

    net.input.range
    net.output.range
end

%%
app.inpSz = 2;
app.layer1Sz = 3;

app.net2 = net;
 
%Layer1
app.IW=net.IW{1,1};
app.b1=net.b{1,1};
%Layer2
app.LW=net.LW{2,1};
app.b2=net.b{2,1};
app.inpR = net.input.range;
app.outR = net.output.range;

app.PIDsw=1;
app.SEEDsw=1;

app.SEED=532;
if app.SEEDsw > 0
    app.SEED=floor(rand * 10000);
end
app.Counter=0;
app.reverseStr = '';

%%

%%%%%%%%%%%%%%%%%%%%%% init params %%%%%%%%%%%%%%%%%%%%%%
ind = 1;
%Layer1    
for i = 1:app.layer1Sz 
    W0(ind:ind+app.inpSz-1)=app.IW(i,:);ind=ind+app.inpSz;
end
W0(ind:ind+app.layer1Sz-1)=app.b1;ind=ind+app.layer1Sz;
%Layer2
W0(ind:ind+app.layer1Sz-1)=app.LW(1,:);ind=ind+app.layer1Sz;
W0(ind:ind+app.layer1Sz-1)=app.LW(2,:);ind=ind+app.layer1Sz;
W0(ind:ind+app.layer1Sz-1)=app.LW(3,:);ind=ind+app.layer1Sz;
W0(ind:ind+3-1)=app.b2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%

set_param(app.system,'FastRestart','on')

options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt',...
   'Display','iter','TolX',1e-12,'TolFun',1e-6,'OutputFcn',@(p1,p2,p3)trainSmartPIDoutFn(p1,p2,p3,app));
W = lsqnonlin(@(p)trainSmartPIDerrorFn(p,app), W0, [], [], options);

%%
%%%%%%%%%%%%%%%%%%%%%% output params %%%%%%%%%%%%%%%%%%%%
ind = 1;

% when stopped lsqnonlin returns transposed W
if size(W, 1) ~= 1
    W = W';
end    
    
%Layer1    
for i = 1:app.layer1Sz 
    net.IW{1,1}(i,:)=W(ind:ind+app.inpSz-1);ind=ind+app.inpSz;
end
net.b{1,1}=W(ind:ind+app.layer1Sz-1)';ind=ind+app.layer1Sz;
%Layer2
net.LW{2,1}(1,:)=W(ind:ind+app.layer1Sz-1);ind=ind+app.layer1Sz;
net.LW{2,1}(2,:)=W(ind:ind+app.layer1Sz-1);ind=ind+app.layer1Sz;
net.LW{2,1}(3,:)=W(ind:ind+app.layer1Sz-1);ind=ind+app.layer1Sz;
net.b{2,1}=W(ind:ind+3-1)';

app.net = net;