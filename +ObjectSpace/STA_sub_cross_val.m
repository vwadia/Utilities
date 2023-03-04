function [ ev ] = STA_sub_cross_val( resp_raw, params, method, alpha, sub_stim_ind)
%STA subpopulation
if nargin>4
    resp_raw = resp_raw(sub_stim_ind, :);
    params = params(sub_stim_ind, :);
end


n = size(resp_raw, 2); % the columns of resp_raw are different cells
nstim = size(resp_raw,1);

ev = zeros(n,1);
% ev2 = zeros(n,1);
for i=1:n % number of cells

    % leave-one-out cross validation
    resp = resp_raw(:,i);
    pred = zeros(nstim,1);
    
    for j=1:nstim
        ind_test = j;
        ind_train = setdiff(1:nstim, ind_test);
        
        [sta, ~] = Utilities.ObjectSpace.analysis_STA(resp(ind_train), params(ind_train,:), method, alpha);

        prj = params*sta'; % all params
        p = polyfit(prj(ind_train), resp(ind_train),1); % resp here is NOT mean subtracted
        pred(ind_test) = polyval(p, prj(ind_test));
    end
    
    error_regress = sum( (pred - resp).^2 );
    error_total = sum((resp-mean(resp)).^2);
    ev1 = 1-error_regress./error_total;
    ev1(ev1==-Inf) = -1;
    
    ev(i) = ev1;
       
    %% test compare non cross val
%     sta = analysis_STA(resp, params);
%     [ ev2(i) ] = explained_variance_by_STA( sta, resp, params);
    
end

end

