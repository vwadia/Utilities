function nonlin = binned_average_perCell_STA(resp, params, options)
% This function is also a stripped down version of STA_figure_original
% It takes in responses to all images (for a given cell) and image parameters 
% then computes the STA, the projection onto the STA, and returns the binned average
% either along the STA or along the principal orthogonal dimension
%
% Inputs:
%     1. Responses 
%     2. Params (image features)
%     3. Options struct (to specify type of screening and which dimension you want average)
%     
% Outputs:
%     1. A structure with the x and y values (dist and binned average fr)
%
% vwadia Dec2021
ndim1 = 25; % number of appearance dimension

fr_raw = resp(options.ind_train);
fr = fr_raw - mean(fr_raw);

nstim = length(fr);

%% STA
para = params(options.ind_train,:);
amp_dim = sqrt(sum(para.^2)); % finding the norm of each dimension 1xndim
if strcmp(options.screenType, 'Object')
    para = param_normalize_per_dim(para, amp_dim, length(options.ind_train));
elseif strcmp(options.screenType, 'Face')
    para = param_normalize(para, amp_dim, ndim1);
end

ndim = size(para, 2);
 
sta=fr'*para;

value_sta_prj = (sta/norm(sta))*para'; 

if isfield(options, 'recalled_stim')
    value_sta_prj = value_sta_prj(options.recalled_stim);
end

%% Principal ortho axis
if isfield(options, 'axis') && strcmp(options.axis, 'ortho')
    para_sub_sta = zeros(size(para));
    for k=1:size(para,1);
        param_sta_prj = sta*(para(k,:)*sta')/(sta*sta'); % vector of params pojected onto STA
        para_sub_sta(k,:) = para(k,:) - param_sta_prj; % subtract STA component from param
    end
    
    % PCA
    COEFF = pca(para_sub_sta);
    
    pc1 = para_sub_sta * COEFF(:,1); % this is the axis
    
    axis_proj = pc1;
    if isfield(options, 'recalled_stim')
        axis_proj = axis_proj(options.recalled_stim);
    end
    
elseif isfield(options, 'axis') && strcmp(options.axis, 'STA')
    axis_proj = value_sta_prj;
end

% compute binned average
if isfield(options, 'nbins') 
    nbin = options.nbins;
else
    nbin = 8;
end
if exist('n_fr')
    nonlin = compute_binned_average(axis_proj, n_fr, nbin, 10); % changed to n_fr by Varun sometimes    
else
    nonlin = compute_binned_average(axis_proj, fr, nbin, 10); % changed to n_fr by Varun sometimes
end


function param = param_normalize(param, amp_dim, ndim1)
%% normalize shape/appearance separately while keeping the relative amplitude within shape or appearance dimensions
%% stevens way - in the cell paper
ndim = size(param, 2);
% para = para./repmat(amp_dim, [NIMAGE 1]);

param(:,1:ndim1)=param(:,1:ndim1) / sqrt(sum(amp_dim(1:ndim1).^2)) / sqrt(2);
param(:, ndim1+1:ndim)=param(:, ndim1+1:ndim) / sqrt(sum(amp_dim(ndim1+1:ndim).^2)) / sqrt(2);


function param = param_normalize_per_dim(param, amp_dim, NIMAGE)
%% normalize each dimension separately 
%% Liang does this only - May2021
param = param./repmat(amp_dim, [NIMAGE 1]);


function nonlin = compute_binned_average(rlin, resp, nbin, least_samples)


%% flexable:
% set an initial bin, combine near bins with too few samples
if nargin<3
    nbin = 8;
end

if nargin<4
    least_samples = 20;
end

mi=min(rlin);
ma=max(rlin);
edge=mi:(ma-mi)/nbin:ma; % min of proj to max of proj in steps of (ma-mi)/nbin

x=zeros(nbin,1);
y=zeros(nbin,1);
e=zeros(nbin,1);
ns=zeros(nbin,1); % number of samples

c = 0; % count

for i=1:nbin
    ind=rlin>edge(i) & rlin<=edge(i+1);
    ns(i)= sum(ind); %num of spikes between edges
end

edge_select = true(nbin+1,1);
 
% for i=1:nbin
%     if ns(i) < least_samples
%         if i<nbin
%             ns(i+1)=ns(i+1)+ns(i);
%             edge_select(i+1) = false;
%         elseif i==nbin
%             ind = find(edge_select(1:end-1),1,'last');  % find last bin edge and combine the last bin to previous one
%             edge_select(ind) = false;
%         end
%     end
% end

edge = edge(edge_select); % deselect some dividing edges
nbin = length(edge)-1;
x=zeros(nbin,1);
y=zeros(nbin,1);
e=zeros(nbin,1);
ns=zeros(nbin,1);
for i=1:nbin
    ind=rlin>edge(i) & rlin<=edge(i+1); % images with sta_proj in this range
    x(i)=mean(rlin(ind));
    y(i)=mean(resp(ind));
    e(i)=std(resp(ind))/sqrt(sum(ind));
    ns(i)= sum(ind);
end

nonlin.x=x;
nonlin.y=y;
nonlin.e=e;
nonlin.ns=ns;
nonlin.rlin_std =std(rlin);

