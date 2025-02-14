function flipWeights(pathRCFile, tc)
    
    load(pathRCFile);
    % display data
    rcaData_old = rcaData;
    A_old = A;
    W_old = W;
    plotRCAResults(rcaData_old, tc, A_old);
    
    % clear the original data
    A = [];
    W = [];
    rcaData = [];
    
    % collect user input
    try
        res = input('Enter weights signs and positions [-1/1, -2/2, -3/3, ....]?\n', 's');
        if (isempty(res))
            return;
        end     
    catch
    end
    
    
    sign_pos = str2num(res);
    
    s0 = sign(sign_pos);
    new_pos = abs(sign_pos);
    new_sign = s0(new_pos);
    
    %% sign
    default_sign = [1 1 1];
    if (~isequal(default_sign, new_sign))    
        s = repmat(new_sign, [128 1]);
        W_sign = W_old.*s;
        A_sign = A_old.*s;
        rcaData_newsign = cellfun(@(x) x.*repmat(new_sign, [size(x, 1) 1 size(x, 3)]), rcaData_old, 'uni', false);
    else
        W_sign = W_old;
        A_sign = A_old;
        rcaData_newsign = rcaData_old;
    end
    plotRCAResults(rcaData_newsign, tc, A_sign);
    
    %% position
    
    default_pos = [1 2 3];
    if (~isequal(new_pos, default_pos))
        W_pos = W_sign(:, new_pos);
        A_pos = A_sign(:, new_pos);
        rcaData_newpos = cellfun(@(x) x(:, new_pos, :), rcaData_newsign, 'uni', false);
    else
        W_pos = W_sign;
        A_pos = A_sign;
        rcaData_newpos = rcaData_newsign;
    end
    
    W = W_pos;
    A = A_pos;
    rcaData = rcaData_newpos;
    
    plotRCAResults(rcaData, tc, A);
    try
        res = input('New waveforms\n', 's');
        if (isempty(res))
        end     
    catch
    end
    try
        save(pathRCFile, 'W', 'A', 'rcaData');
    catch err
        disp('RC file was not updated')
    end
end
