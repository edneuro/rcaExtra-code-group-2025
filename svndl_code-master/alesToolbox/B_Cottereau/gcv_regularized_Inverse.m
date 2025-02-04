function [ sol , inverse_name ] = gcv_regularized_Inverse(fwd,Axx,gcv_params)

if isfield(gcv_params,'TimeWindow')
    time_ndx = findclosest( gcv_params.TimeWindow , Axx(1).dTms * [ 0 : size( Axx(1).Wave , 1 ) - 1 ] );
    % Choice of the data to use in the computation of the error
    b = [];
    for k = 1 : length(Axx)
        b = [ b , Axx(k).Wave(time_ndx(1):time_ndx(2),:)'];
    end
else
    freq_ndx = [];
    if gcv_params.f1_Odd
        freq_ndx = ( (2*gcv_params.f1_Odd - 1) * Axx(1).i1F1 + 1 );
    end
    if gcv_params.f1_Even
        freq_ndx = ([ freq_ndx , 2*(gcv_params.f1_Even) * Axx(1).i1F1 + 1 ] );
    end
    if find(Axx(1).i1F2)
        freq_ndx = ([ freq_ndx , (2*gcv_params.f2_Odd - 1) * Axx(1).i1F2 + 1 ] );
        freq_ndx = ([ freq_ndx , 2 * (gcv_params.f2_Even) * Axx(1).i1F2 + 1 ] );
        if gcv_params.Intermodulation_order
            high_freq_ndx = max( Axx(1).i1F1+1 , Axx(1).i1F2+1 );
            small_freq_ndx = min( Axx(1).i1F1+1 , Axx(1).i1F2+1 );
            for k = 1 : gcv_params.Intermodulation_order
                freq_ndx = ([ freq_ndx , high_freq_ndx - k * small_freq_ndx ] );
                freq_ndx = ([ freq_ndx , high_freq_ndx + k * small_freq_ndx ] );
            end
        end
    end
    freq_ndx = sort(freq_ndx(freq_ndx>1&freq_ndx<length(Axx(1).Cos)));
    % Choice of the data to use in the computation of the error
    b = [];
    for k = 1 : length(Axx)
        b = [ b , Axx(k).Cos(freq_ndx,:)' , Axx(k).Sin(freq_ndx,:)' ];
    end
end
% Decomposition of the forward matrix in singular values
[u,s,v] = csvd(fwd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If some sensors have to many noise auto-covariance, it could 
% introduce errors in the estimation of the gcv error.
% We assume that if a sensor noise auto-covariance is above mean 
% + 6 standard deviation, it is better to get rid of it to compute
% the optimal lambda.
noisy_sensors = find(diag(Axx(1).Cov) > mean(diag(Axx(1).Cov)) + 2.5 * std(diag(Axx(1).Cov)) );
if noisy_sensors
    good_sensors = setdiff( 1 : size(b,1) , noisy_sensors );
    b = b(good_sensors,:);
    fwd_tmp = fwd(good_sensors,:);
    [u_tmp,s_tmp,v_tmp] = csvd(fwd_tmp);
    lambda = gcv(u_tmp,s_tmp,b,'Tikh')
else 
    lambda = gcv(u,s,b,'Tikh')
end

%Tikhonov regularized inverse matrix
reg_s = diag( s ./ (s.^2 + lambda^2 ));
sol = v * reg_s * u';
% Name of the inverse
 inverse_name = gcv_inverse_name(gcv_params);


