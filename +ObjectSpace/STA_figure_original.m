
function [hfig, p, options] = STA_figure_original(resp, params, options)
% hfig = STA_figure(resp, params, options)

%INPUT: 
%       resp(n, 1) firing responses of each image
%       params(n, dim) shape appearance parameters 
%       options.ind_train: index of images to compute sta
% 
%OUTPUT:
%       hfig: handle of the figure
% 
% example:
%       options.ind_train = 1:length(resp) % use all faces to compute STA
%       STA_figure(resp, params, options)

ndim1 = 25; % number of appearance dimension

if isfield(options,'fam') 
    fam = options.fam;
    fam_stim_ind = options.fam_stim_ind;
    fam_para_ind = options.fam_para_ind;
else
    fam = false;
end


hfig = figure('position', [286 50 600 550]);

fr_raw = resp(options.ind_train);
fr = fr_raw - mean(fr_raw);
% n_fr = fr./std(fr); % normalized fr - added by Varun. to pass to compute-binned average

if fam
    fr_fam = resp(fam_stim_ind) - mean(fr_raw);
end


nstim = length(fr);

if isfield(options,'unfam') 
    unfam = options.unfam;
    unfam_stim_ind = options.unfam_stim_ind;
    unfam_para_ind = options.unfam_para_ind;
end

if unfam
    fr_unfam = resp(unfam_stim_ind) - mean(fr_raw);
end


%% STA
para = params(options.ind_train,:);
amp_dim = sqrt(sum(para.^2)); % finding the norm of each dimension 1xndim
amp_dim(amp_dim == 0) = 1;
if strcmp(options.screenType, 'Object')
    para = param_normalize_per_dim(para, amp_dim, length(options.ind_train));
elseif strcmp(options.screenType, 'Face')
    para = param_normalize(para, amp_dim, ndim1);
end
ndim = size(para, 2);
 
if isfield(options, 'sta') && ~isempty(options.sta)
    sta = options.sta;
else
    sta=fr'*para;
end

value_sta_prj = (sta/norm(sta))*para'; 

if fam
    para_fam = params(fam_para_ind,:);
%     amp_dim = sqrt(sum(para_fam.^2));
    if strcmp(options.screenType, 'Object')
        para_fam = param_normalize_per_dim(para_fam, amp_dim, length(options.fam_stim_ind));
    elseif strcmp(options.screenType, 'Face')       
        para_fam = param_normalize(para_fam, amp_dim, ndim1);
    end
    value_sta_prj_fam = (sta/norm(sta))*para_fam';
end

if unfam
    para_unfam = params(unfam_para_ind,:);
%     amp_dim = sqrt(sum(para_unfam.^2));
    if strcmp(options.screenType, 'Object')
        para_unfam = param_normalize_per_dim(para_unfam, amp_dim, length(options.unfam_stim_ind));
    elseif strcmp(options.screenType, 'Face')
        para_unfam = param_normalize(para_unfam, amp_dim, ndim1);
    end
    value_sta_prj_unfam = (sta/norm(sta))*para_unfam';
end

%% shuffled control for sta
n_repeats = 1000;
cc_rand = zeros(n_repeats,1);
sta_shuffle = zeros(n_repeats,ndim);

for i=1:n_repeats
    
    para_shuffle = para(randsample(nstim, nstim),:);
    sta_shuffle(i,:) = fr'*para_shuffle;
    
    value_sta_shuffle = sta_shuffle(i,:)*para_shuffle';
    cc_rand(i) = corr(value_sta_shuffle',fr);
    %mag=max(abs(gen2));
end

cc = corr(value_sta_prj',fr); % 
p = sum(cc_rand > cc)/length(cc_rand);


%% firing rate along STA

nbin = 8; 
if exist('n_fr')
    nonlin = compute_binned_average(value_sta_prj, n_fr, nbin, 10); % changed to n_fr by Varun sometimes    
else
    nonlin = compute_binned_average(value_sta_prj, fr, nbin, 10); % changed to n_fr by Varun sometimes
end
h1 = subplot(3, 3, [2 3]);
errorbar(nonlin.x, nonlin.y, nonlin.e, 'k');
% xlim([-x_lim x_lim])
yl_sta = ylim;
% xlabel('STA axis')
% ylabel('mean firing rate')



if fam
    hold on
    scatter(value_sta_prj_fam, fr_fam, 'filled', 'o', ...
        'LineWidth', 1.5, 'MarkerEdgeColor', [1 1 0], 'MarkerFaceColor', 'k') % [0.9 0.7 0]
end

%% sta projection significance

subplot(3, 3, 1)
h = histogram(cc_rand,0:0.01:1);
h.FaceColor = [1 1 1 ];
hold on;
plot([cc cc],[0 50], 'LineWidth', 2, 'Color', 'r');
text(.5, 100, num2str(p,'p = %.3f'))
% text(.5, 100, ['p = ' num2str(p)]); 

%% scatter plot STA vs max orth STA
para_sub_sta = zeros(size(para));
for k=1:size(para,1);
    param_sta_prj = sta*(para(k,:)*sta')/(sta*sta'); % vector of params pojected onto STA
    para_sub_sta(k,:) = para(k,:) - param_sta_prj; % subtract STA component from param
end


if isfield(options, 'orthAx') && ~isempty(options.orthAx)
    COEFF(:, 1) = options.orthAx;
else
    % PCA
    COEFF = pca(para_sub_sta);
end

pc1 = para_sub_sta * COEFF(:,1);

if fam
    pc1_fam = para_fam * COEFF(:,1);
end

if unfam
    pc1_unfam = para_unfam * COEFF(:,1);
end

if fam && unfam
    fr_all = [fr; fr_fam; fr_unfam];
    max_fr = max(fr_all);
    min_fr = min(fr_all);
elseif fam && ~unfam
    fr_all = [fr; fr_fam];
    max_fr = max(fr_all);
    min_fr = min(fr_all);
else
    max_fr = max(fr);
    min_fr = min(fr);
end
% fprintf('max_firing_rate %f\n', max_fr);

dot_color = zeros(size(fr,1),3); 
dot_color(:,1) = ((fr-min_fr)/(max_fr-min_fr));
dot_color(:,3) = 1- dot_color(:,1);

h2 = subplot(3, 3, [5 6 8 9]);


[sorted_fr, reorder_ind] = sort(fr);
% [sorted_fr, reorder_ind] = sort(value_sta_prj); % is the same bc of how axis is computed
x = value_sta_prj(reorder_ind); 
y = pc1(reorder_ind);
c = dot_color(reorder_ind,:);
dot_size = 20;

scatter( x, y, dot_size, c , 'filled');
% highlight the encoding stimuli later recalled or highlight stimuli along
% 2D projection of axis
if isfield(options, 'encoded_stim')
    for i = 1:length(options.encoded_stim)
        es_val(i) = find(reorder_ind == options.encoded_stim(i));
    end
    hold on
    ax = x(es_val);
    ay = y(es_val);
    scatter(ax, ay, dot_size, 'o', 'MarkerEdgeColor', [0 1 0], 'LineWidth', 3.5);
end

% highlight stimuli on orthogonal axis
if isfield(options, 'encoded_stim_ortho')
    for i = 1:length(options.encoded_stim_ortho)
        es_val_ortho(i) = find(reorder_ind == options.encoded_stim_ortho(i));
    end
    hold on
    ax_ortho = x(es_val_ortho);
    ay_ortho = y(es_val_ortho);
    scatter(ax_ortho, ay_ortho, dot_size, 'o', 'MarkerEdgeColor', [1 0.65 0], 'LineWidth', 3.5);
end

if isfield(options, 'pot_rec_stim')
    
    hold on
    for i = 1:length(options.pot_rec_stim)
        pot_stim_pos(i, 1) = find(x == options.pot_rec_stim(i, 1));
    end
    for i = 1:length(options.pot_rec_stim)
        pot_stim_pos(i, 2) = find(y == options.pot_rec_stim(i, 2));
    end
    assert(isequal(pot_stim_pos(:, 1), pot_stim_pos(:, 2)))
    
    keyboard
    ax_pot_rec =  x(pot_stim_pos(:, 1));
    ay_pot_rec =  y(pot_stim_pos(:, 1));
    scatter(ax_pot_rec, ay_pot_rec, dot_size, 'o', 'MarkerEdgeColor', [0 1 0], 'LineWidth', 3.5);
    options.recalled_stim = sort(reorder_ind(pot_stim_pos(:, 1)))';
    % write down pot_stim_pos as options.marked_postitions in screeningScript 
    % see screening script for details
end

if isfield(options, 'recalled_stim')

    for i = 1:length(options.recalled_stim)
        es_val(i) = find(reorder_ind == options.recalled_stim(i));
    end
    hold on
    ax = x(es_val);
    ay = y(es_val);
    options.xvals = ax;
    options.yvals = ay;
%     hold on
%     ax = x(options.recalled_stim);
%     ay = y(options.recalled_stim);
    if isfield(options, 'recalledCols')
        for j = 1:length(ax)
            scatter(ax(j), ay(j), dot_size, 'o', 'MarkerEdgeColor', options.recalledCols(j, :), 'LineWidth', 3.5);
        end
    else
        scatter(ax, ay, dot_size, 'o', 'MarkerEdgeColor', [0 1 0], 'LineWidth', 3.5);        
    end
end


box on
% xlabel('STA axis')
% ylabel('Principal Orthogonal axis')
% axis equal
x_lim = max(abs(xlim));
% y_lim = max(abs(ylim));
% lim = max(x_lim, y_lim);
xlim([-x_lim x_lim])
ylim([-x_lim x_lim])
yt_scat = yticks;
xt_scat = xticks;


if fam
    hold on
    dot_color_fam = zeros(size(fr_fam,1),3);
    dot_color_fam(:,1) = (fr_fam-min_fr)/(max_fr-min_fr);
    dot_color_fam(:,3) = 1- dot_color_fam(:,1);
    dot_size = 50;
    scatter( value_sta_prj_fam, pc1_fam, dot_size, dot_color_fam ,...
        'filled', 'o', 'MarkerEdgeColor', [1 1 0], 'LineWidth', 1.5);
end

if unfam
    hold on
    dot_color_unfam = zeros(size(fr_unfam,1),3);
    dot_color_unfam(:,1) = (fr_unfam-min_fr)/(max_fr-min_fr);
    dot_color_unfam(:,3) = 1- dot_color_unfam(:,1);
    dot_size = 50;
    scatter( value_sta_prj_unfam, pc1_unfam, dot_size, dot_color_unfam ,...
        'filled', 'o', 'MarkerEdgeColor', [0 1 0], 'LineWidth', 1.5);
end

%% firing rate along principal orthogonal dimension

h3 = subplot(3, 3, [4 7]);
nbin = 10;
if exist('n_fr')
    nonlin = compute_binned_average(pc1, n_fr, nbin, 10);
else
    nonlin = compute_binned_average(pc1, fr, nbin, 10);  
end
herrorbar(nonlin.y, nonlin.x, nonlin.e, 'k');
% xlabel('Principal Orthogonal axis')
% ylabel('mean firing rate')
% ylim([-lim lim])
yticks([yt_scat]);
% xlim([-yl_sta(2)*0.5 yl_sta(2)*0.5])
xlim([-yl_sta(2) yl_sta(2)])


if unfam
    hold on
    scatter(fr_unfam, pc1_unfam, 'filled', 'o', ...
        'LineWidth', 1.5, 'MarkerEdgeColor', [0 1 0], 'MarkerFaceColor', 'k')
end

% box off
% if ~fam && ~unfam
    linkaxes([h1, h2], 'x');
    linkaxes([h2, h3], 'y');
% end


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
for i=1:nbin
    if ns(i) < least_samples
        if i<nbin
            ns(i+1)=ns(i+1)+ns(i);
            edge_select(i+1) = false;
        elseif i==nbin
            ind = find(edge_select(1:end-1),1,'last');  % find last bin edge and combine the last bin to previous one
            edge_select(ind) = false;
        end
    end
end

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

