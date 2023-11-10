
function [hfig, p, options] = sample_Ims_Along_STA(resp, params, options)
% This function is a modified version of STA_figure_original.
% The point being to compute the axes (STA and orthogonal) then sample 3 
% stimulus images that fall along the STA and orthogonal axes
%
% Inputs:
%     1. Responses 
%     2. Params (image features)
%     3. Options struct (delineate type of screening for normalization, and path to stimuli)
%     
% Outputs:
%     1. STA_Figure with the chosen images highlighted and plotted
%     2. The imageIDs chosen
% vwadia Aug2022


hfig = figure('position', [286 50 600 550], 'Visible','off');
% hfig = figure('position', [286 50 600*2 550*2], 'Visible','off');

fr_raw = resp(options.ind_train);
fr = fr_raw - mean(fr_raw);
% n_fr = fr./std(fr); % normalized fr - added by Varun. to pass to compute-binned average

nstim = length(fr);

% if options.unfam
%     unfam_ind = randperm(1000,8);
%     fr_unfam = fr(unfam_ind);
% end

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
h1 = subplot(4, 4, [2 3]);
errorbar(nonlin.x, nonlin.y, nonlin.e, 'k');
% xlim([-x_lim x_lim])
yl_sta = ylim;
% xlabel('STA axis')
% ylabel('mean firing rate')

%% sta projection significance

subplot(4, 4, 1)
h = histogram(cc_rand,0:0.01:1);
h.FaceColor = [1 1 1 ];
hold on;
plot([cc cc],[0 50], 'LineWidth', 2, 'Color', 'r');
text(.5, 100, num2str(p,'p = %.3f'))

%% scatter plot STA vs max orth STA
para_sub_sta = zeros(size(para));
for k=1:size(para,1);
    param_sta_prj = sta*(para(k,:)*sta')/(sta*sta'); % vector of params pojected onto STA 
    para_sub_sta(k,:) = para(k,:) - param_sta_prj; % subtract STA component from param
end

% PCA
COEFF = pca(para_sub_sta);

% principal orthogonal axis
pc1 = para_sub_sta * COEFF(:,1);

max_fr = max(fr);
min_fr = min(fr);
% fprintf('max_firing_rate %f\n', max_fr);

dot_color = zeros(size(fr,1),3); 
dot_color(:,1) = ((fr-min_fr)/(max_fr-min_fr));
dot_color(:,3) = 1- dot_color(:,1);

h2 = subplot(4, 4, [6 7 10 11]);

[sorted_fr, reorder_ind] = sort(fr);
x = value_sta_prj(reorder_ind); % why this?
y = single(pc1(reorder_ind));
c = dot_color(reorder_ind,:);
dot_size = 20;

x_sorted = sort(x);
y_sorted = sort(y);

% define range
mid_pt = floor(length(x)/2);
mid_range = [mid_pt-floor(0.05*length(x)):mid_pt + floor(0.05*length(x))];

% grab the middle x and y values (choose from sorted x and y)
mid_y = y_sorted(mid_range);
mid_x = x_sorted(mid_range);

% define target x and y values (sorting here because of how chosen_pos_*
% are sampled)
target_x = sort(x(ismember(y, mid_y)));
target_y = sort(y(ismember(x, mid_x))); 

l_targ = length(target_x);

% % choose coords
% chosen_pos_STA = [target_x(1);...
%     randsample(target_x(floor(l_targ/2-(0.25*l_targ)):floor(l_targ/2)), 1)';...
%     randsample(target_x(floor(l_targ/2):floor(l_targ/2+(0.2*l_targ))), 1)';...    
%     target_x(end)]; 

% choose coords
chosen_pos_STA = [target_x(1);...
    target_x(floor(l_targ/2-(0.1*l_targ)));...% 40%
    target_x(floor(l_targ/2+(0.3*l_targ)));... % 70%   
    target_x(end)]; 


chosen_pos_STA = sort(chosen_pos_STA);

% using 'find(ismember(x, chosen_pos_*) == 1)' sorts the result which is
% wrong
for i = 1:length(chosen_pos_STA)
    cP_STA(i) = find(x == chosen_pos_STA(i));
end

chosen_ims_STA = reorder_ind(cP_STA); % image IDs
ims_STA_coords = [x(cP_STA)' y(cP_STA)]; % x&y coordinates of those images

assert(sum(double(ismember(chosen_pos_STA, ims_STA_coords(:, 1)))) == length(chosen_pos_STA))

chosen_pos_ortho = [randsample(target_y(1:floor(0.1*l_targ)), 1);...
    randsample(target_y(floor(l_targ/2-(0.1*l_targ)):floor(l_targ/2+(0.1*l_targ))), 1);...
    randsample(target_y(end-floor(0.1*l_targ):end), 1)];

for j = 1:length(chosen_pos_ortho)
    cP_ortho(j) = find(y == chosen_pos_ortho(j));
end

chosen_ims_ortho = reorder_ind(cP_ortho); % image IDs
ims_ortho_coords = [x(cP_ortho)' y(cP_ortho)]; % coordinates of those images

chosen_ims_ortho = flipud(chosen_ims_ortho);
ims_ortho_coords = flipud(ims_ortho_coords);

% assert(isequal(chosen_pos_ortho, ims_ortho_coords(:, 2)))
assert(sum(double(ismember(chosen_pos_ortho, ims_ortho_coords(:, 2)))) == length(chosen_pos_ortho))


scatter( x, y, dot_size, c , 'filled');

% highlight the chosen stimuli along STA
hold on
scatter(ims_STA_coords(:, 1), ims_STA_coords(:, 2), dot_size, 'o', 'MarkerEdgeColor', [0 1 0], 'LineWidth', 3.5);

% highlight chosen stimuli along orthogonal axis
scatter(ims_ortho_coords(:, 1), ims_ortho_coords(:, 2), dot_size, 'o', 'MarkerEdgeColor', [1 0.65 0], 'LineWidth', 3.5);

box on

yt_scat = yticks;
xt_scat = xticks;


%% firing rate along principal orthogonal dimension

h3 = subplot(4, 4, [5 9]);
nbin = 10;
if exist('n_fr')
    nonlin = compute_binned_average(pc1, n_fr, nbin, 10);
else
    nonlin = compute_binned_average(pc1, fr, nbin, 10);  
end
errorbar(nonlin.y, nonlin.x, nonlin.e, 'horizontal', 'k');
% xlabel('Principal Orthogonal axis')
% ylabel('mean firing rate')
% ylim([-lim lim])
yticks([yt_scat]);
% xlim([-yl_sta(2)*0.5 yl_sta(2)*0.5])
xlim([-yl_sta(2) yl_sta(2)])

% box off
linkaxes([h1, h2], 'x');
linkaxes([h2, h3], 'y');

% load in images
pathStimuli = options.pathStimuli;

imDir = dir(fullfile(pathStimuli));

imDir = imDir(~ismember({imDir.name}, {'.', '..', '.DS_Store', 'Thumbs.db'}));
% gets rid of all the weird copies windows makes
stimNames = struct2cell(imDir);
stimNames = stimNames(1,:)';
goodStim = ~startsWith(stimNames, '._', 'IgnoreCase', true);
imDir = imDir(goodStim);
[~, natIdx] = natsortfiles({imDir.name});


cI_STA = natIdx(chosen_ims_STA);
cI_ortho = natIdx(chosen_ims_ortho);

%% show images along STA

for im = 1:length(cI_STA)
    subplot(4, 4, 12+im) % subplots 13, 14, 15, 16
    imshow([imDir(cI_STA(im)).folder filesep imDir(cI_STA(im)).name]) 
end

% found by trial and error
annotation('rectangle', [0.125, 0.1, 0.785, 0.18], 'Color', [0 1 0], 'LineWidth', 3)
%% show images along ortho
for im = 1:length(cI_ortho)
    subplot(4, 4, 4*im) % subplots 4, 8, 12
    imshow([imDir(cI_ortho(im)).folder filesep imDir(cI_ortho(im)).name]) 
end

% found by trial and error
annotation('rectangle', [0.735, 0.312, 0.18, 0.625], 'Color', [1 0.65 0], 'LineWidth', 3)


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

