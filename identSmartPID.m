function identSmartPID(trainDataName, testDataName, bDoGridSearch, app)

    %% load data to table
    data1_table = readtable(trainDataName,...
        'Delimiter', 'tab', 'ReadVariableNames', false);
    data2_table = readtable(testDataName,...
        'Delimiter', 'tab', 'ReadVariableNames', false);
    dt = 1;
    data1 = iddata(data1_table.Var2, data1_table.Var3, dt);
    data2 = iddata(data2_table.Var2, data2_table.Var3, dt);

if bDoGridSearch
    %% construct model
    nk = 1;%3;
    fileID = fopen('data\feed_forward_net_fit_data.txt','w');
    fprintf(fileID, '');
    for size1 = 2:6
        %for size2 = 2:6
            for na = 1:1:6
                for nb = 1:1:6
                    net_params = size1;%[size1 size2];
                    model_params = [na nb nk];
                    disp(net_params)
                    disp(model_params)                    
                    net = feedforwardnet(net_params);
                    fprintf(fileID,'%d\t%d\t', net_params);
                    net_estimator = neuralnet(net);
                    model = nlarx(data1, model_params, net_estimator);
                    fprintf(fileID,'%d\t%d\t%d\t', model_params);
                    [data1_sim, data1_fit, data1_y0] = compare(data1, model);
                    [data2_sim, data2_fit, data2_y0] = compare(data2, model);
                    disp([data1_fit data2_fit])
                    fprintf(fileID,'%f\t%f\r\n', data1_fit, data2_fit);
                    
                    if app.stop == true
                        disp('stopped by user request');
                        return;
                    end
                end
            end
        %end
    end
    fclose(fileID);
end

    % chose the best model structure
    fitData = dlmread('data\feed_forward_net_fit_data.txt');%,...//'D:\piv\matlab_nets\ps\data-2018-11-08-19-45-39.txt'
       % 'Delimiter', 'tab', 'ReadVariableNames', false);
    
    columns = size(fitData, 2);

    fitData(:,columns + 1) = fitData(:,columns - 1) + fitData(:,columns);
    fitDataSorted = sortrows(fitData, columns + 1, 'descend');

    disp(fitDataSorted(1,:));

    net_params = fitDataSorted(1,1);
    model_params = [fitDataSorted(1,2) fitDataSorted(1,3) fitDataSorted(1,4)];
                  
    net = feedforwardnet(net_params);    
    %view(net)    
    net_estimator = neuralnet(net);
    model = nlarx(data1, model_params, net_estimator);
    disp(getreg(model));
    %gensim(gensim(model.Nonlinearity.Network))
    %[a1, a2, a3] = compare(data2, model)
    disp(model);
    assignin('base','model',model);
    save('models\model','model');
end