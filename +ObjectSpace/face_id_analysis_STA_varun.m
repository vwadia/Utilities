
function hfig = face_id_analysis_STA_varun(resp, options)
% steven's AAM model. STA

row_subplot = 3;
col_subplot = 3;


fam = false;
fam2 = false;

% stim_name = 'steven_2000_faces';
stim_name = 'Param_1593_objects';

% parameter_file = 'Z:\LabUsers\vwadia\SUAnalysis\ObjectSpace\parameters_2k_synthetic_faces.mat';
parameter_file = 'Z:\LabUsers\vwadia\SUAnalysis\ObjectSpace\parameters_1593_objects.mat';

NIMAGE = 1593;
ndim1 = 25;
        

window_after = [100 300];
window_before = [-20 50];

hfig = figure('position', [286 50 600 550]);


%% prepocessing
options.response_window = window_after;

fr_raw = resp(1:NIMAGE);
fr = fr_raw - mean(fr_raw);

if fam
    fr_fam = resp(fam_stim_ind) - mean(fr_raw);
    fr_pfam = resp(pfam_stim_ind)  - mean(fr_raw);

end

% if options.unfam
%     %rng(now*1000)
%     unfam_ind = randperm(1000,8);
% %     unfam_ind = [ 90:93 76 64 63 56 39 96 100];
%     fr_unfam = fr(unfam_ind);
% end

nstim = length(fr);


% check stim type
fam_cond_sc = 1;
unseen_cond_sc = 3;
options.unseen_sc = false;




%% STA
% load parameters
load(parameter_file)
% para = params(1:NIMAGE,:);
para = score(1:NIMAGE,:);

ndim = size(para, 2);

amp_dim = sqrt(sum(para.^2));
para = param_normalize(para, amp_dim, ndim1);

sta=fr'*para;

value_sta_prj = sta/norm(sta)*para';

if fam
    para_fam = params(fam_para_ind,:);
    para_pfam = params(pfam_para_ind,:);
    para_fam = param_normalize(para_fam, amp_dim, ndim1);
    para_pfam = param_normalize(para_pfam, amp_dim, ndim1);
    value_sta_prj_fam = sta/norm(sta)*para_fam';
    value_sta_prj_pfam = sta/norm(sta)*para_pfam';
end

% if is_screening_data && options.unseen_sc
%     para_unseen = param_normalize(para_unseen, amp_dim, ndim1);
%     value_sta_prj_unseen = sta/norm(sta)*para_unseen';
% end

%% shuffled control for sta
n_repeats = 1000;
cc_rand = zeros(n_repeats,1);
sta_shuffle = zeros(n_repeats,ndim);
for i=1:n_repeats
    
    para_shuffle = para(randsample(nstim, nstim),:);
    sta_shuffle(i,:) = fr'*para_shuffle;
    
    value_sta_shuffle=sta_shuffle(i,:)*para_shuffle';
    cc_rand(i) = corr(value_sta_shuffle',fr);
    %mag=max(abs(gen2));
end

cc = corr(value_sta_prj',fr);
p = sum(cc_rand > cc)/length(cc_rand);

ave_sta_shuffle = mean(sta_shuffle);
std_sta_shuffle = std(sta_shuffle);


%% figure STA

% subplot(row_subplot, col_subplot,1)
% error_area(1:ndim, ave_sta_shuffle, std_sta_shuffle*2, [.8 .8 .8]);
% hold on
% plot(sta, 'ko-');
% set(gca,'XTick', [ndim1/2 ndim1 ndim1+(ndim-ndim1)/2], 'XTickLabel', {'Shape', '','Appearance'})
% ylabel('STA value');

%% firing rate along STA

% x_lim = options.x_lim;
% y_lim = options.y_lim;
% fring_rate_range = options.fring_rate_range;
% dot_size = options.dot_size;
fam = options.fam;
unfam = options.unfam;

% mag = max(abs(value_sta_prj));
nbin = 10;
nonlin = compute_binned_average(value_sta_prj, fr, nbin, 10);

subplot(3, 3, [2 3])
errorbar(nonlin.x, nonlin.y, nonlin.e, 'k');
% xlim([-x_lim x_lim])
% ylim(fring_rate_range)
% xlabel('STA axis')
% ylabel('mean firing rate')

if unfam
    hold on
    scatter(value_sta_prj(unfam_ind), fr_unfam, 'filled', 'o', ...
        'LineWidth', 1.5, 'MarkerEdgeColor', [0 1 0], 'MarkerFaceColor', 'k')
end

if fam
    hold on
    scatter(value_sta_prj_fam, fr_fam, 'filled', 'o', ...
        'LineWidth', 1.5, 'MarkerEdgeColor', [1 1 0], 'MarkerFaceColor', 'k') % [0.9 0.7 0]
end



% box off
% if is_screening_data
%     hold on
%     if options.fam_sc
%         scatter(value_sta_prj_fam, fr_fam_sc, dot_size, 'filled', 'o', ...
%             'LineWidth', 1.5, 'MarkerEdgeColor', [1 1 0], 'MarkerFaceColor', 'k')
%     end
%     if options.unseen_sc
%         scatter(value_sta_prj_unseen, fr_unseen_sc, dot_size, 'filled', 'o', ...
%             'LineWidth', 1.5, 'MarkerEdgeColor', [0 1 0], 'MarkerFaceColor', 'k')
%     end
% end

%% sta projection significance

subplot(row_subplot, col_subplot, 1)
h = histogram(cc_rand,0:0.01:1);
h.FaceColor = [1 1 1 ];
hold on;
plot([cc cc],[0 50], 'LineWidth', 2, 'Color', 'r');
text(.5, 100, num2str(p,'p = %.3f'))

%% scatter plot STA vs max orth STA

for k=1:NIMAGE
    param_sta_prj = sta*(para(k,:)*sta')/(sta*sta'); % vector of params pojected onto STA 
    para_sub_sta(k,:) = para(k,:) - param_sta_prj; % subtract STA component from param
end

% PCA
[COEFF, SCORE] = pca(para_sub_sta);

pc1 = para_sub_sta * COEFF(:,1);

if fam
    pc1_fam = para_fam * COEFF(:,1);
    pc1_pfam = para_pfam * COEFF(:,1);
end

% if is_screening_data 
%     if options.fam_sc
%         pc1_fam = para_fam * COEFF(:,1);
%     end
%     if options.unseen_sc
%         pc1_unseen = para_unseen * COEFF(:,1);
%     end
% end

if fam
    fr_all = [fr; fr_fam; fr_pfam];
    %fr_all = fr;
    max_fr = max(fr_all);
    min_fr = min(fr_all);
else
    max_fr = max(fr);
    min_fr = min(fr);
end
fprintf('max_firing_rate %f\n', max_fr);

dot_color = zeros(size(fr,1),3); 
dot_color(:,1) = ((fr-min_fr)/(max_fr-min_fr));
dot_color(:,3) = 1- dot_color(:,1);


subplot(3, 3, [5 6 8 9])

[~, reorder_ind] = sort(fr);
x = value_sta_prj(reorder_ind);
y = pc1(reorder_ind);
c = dot_color(reorder_ind,:);
dot_size = 20;

scatter( x, y, dot_size, c , 'filled');
box on
% xlabel('STA axis')
% ylabel('Principal Orthogonal axis')
% axis equal
% xlim([-x_lim x_lim])
% ylim([-y_lim y_lim])

if fam
    hold on
    dot_color_fam = zeros(size(fr_fam,1),3);
    dot_color_fam(:,1) = (fr_fam-min_fr)/(max_fr-min_fr);
    dot_color_fam(:,3) = 1- dot_color_fam(:,1);
    dot_size = 50;
    scatter( value_sta_prj_fam, pc1_fam, dot_size, dot_color_fam ,...
        'filled', 'o', 'MarkerEdgeColor', [1 1 0], 'LineWidth', 1.5);
    
    dot_color_pfam = zeros(size(fr_pfam,1),3);
    dot_color_pfam(:,1) = (fr_pfam-min_fr)/(max_fr-min_fr);
    dot_color_pfam(:,3) = 1- dot_color_pfam(:,1);
    %scatter( value_sta_prj_pfam, pc1_pfam, dot_size, dot_color_pfam ,...
    %   'filled', 's', 'MarkerEdgeColor', [1 1 0], 'LineWidth', 1.5);
    
%     legend('2000 faces', 'familiar', 'unfamiliar')
%     legend('2000 faces', 'familiar faces', 'pictorially familiar')
    
end

if unfam
    hold on
    dot_color_fam = zeros(size(fr_unfam,1),3);
    dot_color_fam(:,1) = (fr_unfam-min_fr)/(max_fr-min_fr);
    dot_color_fam(:,3) = 1- dot_color_fam(:,1);
    dot_size = 50;
    scatter( value_sta_prj(unfam_ind), pc1(unfam_ind), dot_size, dot_color_fam ,...
        'filled', 'o', 'MarkerEdgeColor', [0 1 0], 'LineWidth', 1.5);
end


% figure_add_title(strctUnit,  options)


%% firing rate along principal orthogonal dimension

subplot(3, 3, [4 7])
nbin = 10;
nonlin = compute_binned_average(pc1, fr, nbin, 10);
herrorbar(nonlin.y, nonlin.x, nonlin.e, 'k');
% xlabel('Principal Orthogonal axis')
% ylabel('mean firing rate')
% ylim([-y_lim y_lim])
% xlim([-2 2])
% box off


function param = param_normalize(param, amp_dim, ndim1)
%%

ndim = size(param, 2);
% para = para./repmat(amp_dim, [NIMAGE 1]);

param(:,1:ndim1)=param(:,1:ndim1) / sqrt(sum(amp_dim(1:ndim1).^2)) / sqrt(2);
param(:, ndim1+1:ndim)=param(:, ndim1+1:ndim) / sqrt(sum(amp_dim(ndim1+1:ndim).^2)) / sqrt(2);

% function param = param_normalize_per_dim(param, amp_dim)
% 
% %%
% param = param./repmat(amp_dim, [NIMAGE 1]);

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
edge=mi:(ma-mi)/nbin:ma; % min of proj to max of proj in steps 

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
    ind=rlin>edge(i) & rlin<=edge(i+1);
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