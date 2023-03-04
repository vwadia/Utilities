%% read the coordinates from IT and MTL and generate color structure too
% Edit from what Mar sent me 
% vwadia Nov2022

setDiskPaths

% add toolbox path
fTripPath = [diskPath filesep 'Code' filesep 'fieldtrip-20221126'];
addpath(genpath(fTripPath))

%%  read from the excel file - will need to change this to add more regions

% her file - to see how it's done
% xlsFile = [boxPath filesep 'for_Advisors_VarunThesis' filesep 'IT_ImaginationPaper' filesep 'Bubbles_MNI_Mar.xlsx'];

% my own file - for production
xlsFile = [boxPath filesep 'for_Advisors_VarunThesis' filesep 'IT_ImaginationPaper' filesep 'VW_ObjectScreening_MNICoordinates.xlsx'];
[num,txt,raw] = xlsread(xlsFile, 1, '','basic'); 

meshAlpha = 0.5;
roiAlpha = 0;

saveFigs = 0;

%%

% Mar
% columns LA B 2, RA C3, LH D4, RH E5, LPH F6, RPH G7, LPHG H8, RPHG I9.

% Mine
% columns LIT L/12, RIT M/13

load([fTripPath filesep 'template' filesep 'anatomy' filesep 'surface_pial_both.mat']) % have to use this for cortex

 
% load([fTripPath filesep 'template' filesep 'anatomy' filesep 'surface_inflated_both.mat'])
 
% load([fTripPath filesep 'template' filesep 'anatomy' filesep 'surface_white_both.mat'])

% load([fTripPath filesep 'template' filesep 'anatomy' filesep 'surface_inflated_both_caret.mat'])

% figure;
% ft_plot_mesh(mesh_left, 'facecolor', ([255,224,189])./255, 'edgecolor', 'none','facealpha',0.2);
% ft_plot_mesh(mesh, 'facecolor', ([255,224,189]-100)./255, 'edgecolor', 'none','facealpha',0.2);


f = figure;
% ft_plot_mesh(mesh, 'facecolor', ([255,224,189]-100)./255, 'edgecolor', 'none','facealpha',0.1);
% ft_plot_mesh(mesh, 'facecolor', ([192,192,192])./255, 'edgecolor', ([192,192,192])./255, 'facealpha',0.1, 'edgealpha', 0.1);
% ft_plot_mesh(mesh, 'facecolor', ([192,192,192])./255, 'edgecolor', 'none', 'facealpha',0.1);
ft_plot_mesh(mesh, 'facecolor', ([192,192,192])./255, 'edgecolor', 'none', 'facealpha',meshAlpha);


hold on;

% view(90,0);%for occi

% view(130,-3);%for occi

% view(0, 0);%for occi_backview

%%parietal elecs) % view(0, 55)

light;
% lightangle(-25, 25);
% 
%  lightangle(0,0);%for occi
% lightangle(0, 0);%for occi_backview

view(-180, -90)
camlight('HEADLIGHT');
lighting phong;


% colors=[0 0 1; 1 0 1; 0 1 1; 0 1 0; 1 0 0; 0 0 0];





% plot the atlas

%% read the relevant atlas - is this the right one for me?

atlas = ft_read_atlas([fTripPath filesep 'template' filesep 'atlas' filesep 'brainnetome' filesep 'BNA_MPM_thr25_1.25mm.nii']);

%% LIT
% correct view for IT is view(0,  90) (bottom)

% Steps: Read in coordinates from excel file, choose color, setup cfg structure and then plot mesh, plot dipoles 
coordinatesLIT = [];
LIT_col = raw(2:end, 12);

colorIT = [0.4940 0.1840 0.5560];

color_IT = []; % this will be a p x 3 array with the color repeated for the number of coordinates                                      

for eleci = 1:length(LIT_col)
    
    
    
    if(isnan(( LIT_col{ eleci})) )
        continue;
    end
    
    if  isnan(str2num( LIT_col{ eleci}))
        continue;
    end
    
    coordinatesLIT = [coordinatesLIT;  str2num( LIT_col{ eleci})];
    color_IT = [color_IT; colorIT];

end

%% RIT

% Steps: Read in coordinates from excel file, choose color, setup cfg structure and then plot mesh, plot dipoles 
coordinatesRIT = [];
RIT_col = raw(2:end, 13);

colorIT = [0.4940 0.1840 0.5560];

color_IT = []; % this will be a p x 3 array with the color repeated for the number of coordinates                                      

for eleci = 1:length(RIT_col)
    
    
    
    if(isnan(( RIT_col{ eleci})) )
        continue;
    end
    
    if  isnan(str2num( RIT_col{ eleci}))
        continue;
    end
    
    coordinatesRIT = [coordinatesRIT;  str2num( RIT_col{ eleci})];
    color_IT = [color_IT; colorIT];

end


%% Set up cfg struct - left

cfg            = [];
atlas.coordsys = 'mni';
cfg.inputcoord = 'mni';
cfg.atlas      = atlas;
% cfg.roi = {atlas.tissuelabel{103:2:108}}; % RFuG 
cfg.roi = {atlas.tissuelabel{104:2:108}}; % LFuG 
% cfg.roi = {atlas.tissuelabel{89:2:102}}; % LITG 90:2:102 is RITG

mask_rha = ft_volumelookup(cfg, atlas);

seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'}); 
seg.brain = mask_rha;
cfg             = [];
cfg.method      = 'iso2mesh';
cfg.radbound    = 2;
cfg.maxsurf     = 0;
cfg.tissue      = 'brain';
cfg.numvertices = 1000;
cfg.smooth      = 3;
mesh_rha = ft_prepare_mesh(cfg, seg);

hold on

ft_plot_mesh(mesh_rha, 'facecolor', colorIT, 'edgecolor', 'none','facealpha',roiAlpha);
% ft_plot_mesh(mesh_rha, 'facecolor', colorIT, 'edgecolor', [0 0 0],'facealpha',roiAlpha, 'edgealpha', 0.1); % the outline mesh is 3D so really not helpful - obscures electrode points

% view(130,-3);%for occi
% lighting gouraud; 
% camlight;

% view(0, 90)

%% plot dipoles - left

for n=1:size(coordinatesLIT,1) 
    
    hold on 
    
    ft_plot_dipole(round(coordinatesLIT(n,:)),[1 1 1], 'color', color_IT(n,:),'diameter',3)
%     ft_plot_dipole(round(coordinatesLIT(n,:)),[1 1 1], 'color', [0 0 0],'diameter',3)
    
end 

%% Set up cfg struct - right

cfg            = [];
atlas.coordsys = 'mni';
cfg.inputcoord = 'mni';
cfg.atlas      = atlas;
cfg.roi = {atlas.tissuelabel{103:2:108}}; % RFuG 
% cfg.roi = {atlas.tissuelabel{104:2:108}}; % LFuG 
% cfg.roi = {atlas.tissuelabel{89:2:102}}; % LITG 90:2:102 is RITG

mask_rha = ft_volumelookup(cfg, atlas);

seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'}); 
seg.brain = mask_rha;
cfg             = [];
cfg.method      = 'iso2mesh';
cfg.radbound    = 2;
cfg.maxsurf     = 0;
cfg.tissue      = 'brain';
cfg.numvertices = 1000;
cfg.smooth      = 3;
mesh_rha = ft_prepare_mesh(cfg, seg);

hold on

ft_plot_mesh(mesh_rha, 'facecolor', colorIT, 'edgecolor', 'none','facealpha',roiAlpha);
% ft_plot_mesh(mesh_rha, 'facecolor', colorIT, 'edgecolor', colorIT,'facealpha',roiAlpha, 'edgealpha', 0.1);  % the outline mesh is 3D so really not helpful - obscures electrode points

% view(130,-3);%for occi
% lighting gouraud; 
% camlight;

%% plot dipoles - right

for n=1:size(coordinatesRIT,1) 
    
    hold on 
    
    ft_plot_dipole(round(coordinatesRIT(n,:)),[1 1 1], 'color', color_IT(n,:),'diameter',3)
%     ft_plot_dipole(round(coordinatesRIT(n,:)),[1 1 1], 'color', [0 0 0],'diameter',3)
    
end 

%% save figs from different views
if saveFigs
    for fignum = 1:3
        
        switch fignum
            case 1
                view(-180, -90)
                clite.Position = [-0.7625    0.8623   -1.3059]*1e3;
            case 2
                view(120, 30)
                clite.Position = [0.2283    0.9940    1.4386]*1e3;
            case 3
                view(240, 30)
                clite.Position = [-0.9906   -0.3272    1.4386]*1e3;
                
        end
        print(f, [boxPath filesep 'for_Advisors_VarunThesis' filesep 'IT_ImaginationPaper' filesep 'AnatomicalMap' filesep 'GlassBrainView_' num2str(fignum)], '-dpng', '-r0')
        
    end
end
%% LH


% coordinatesLH = [];
% hipp_col = raw(2:end,4);
% 
% colorHipp = [0 0 1];
% 
% color_hipp = [];
% for eleci = 1:length(hipp_col)
%     
%     
%     
%     if(isnan(( hipp_col{ eleci})) )
%         continue;
%     end
%     
%     if  isnan(str2num( hipp_col{ eleci}))
%         continue;
%     end
%     
%     coordinatesLH = [coordinatesLH;  str2num( hipp_col{ eleci})];
%     color_hipp = [color_hipp; colorHipp];
% 
% end
% 
% 
% %% hippocampus left
% %brainnetome
% cfg            = [];
% atlas.coordsys = 'mni';
% cfg.inputcoord = 'mni';
% cfg.atlas      = atlas;
% % cfg.roi        = {'Hipp, Left Hippocampus rHipp, rostral hippocampus',  'Hipp, Left Hippocampus cHipp, caudal hippocampus' };%, 'Hippocampus_R'} %{'Left-Hippocampus'};
% 
% % atlas.tissuelabel{109:120} parahippocampus
% % atlas.tissuelabel{211:214} amygdala
% % atlas.tissuelabel{215:218} hippocampus
% 
% cfg.roi = {atlas.tissuelabel{216:2:218}}; % right hippocampus
% 
% 
% % %     'Hipp, Right Hippocampus rHipp, rostral hippocampus'
% % % 
% % % 
% % %     'Hipp, Left Hippocampus rHipp, rostral hippocampus'
% % % 
% % % 
% % %     'Hipp, Right Hippocampus cHipp, caudal hippocampus'
% % % 
% % % 
% % %     'Hipp, Left Hippocampus cHipp, caudal hippocampus'
%     
%     
% mask_rha = ft_volumelookup(cfg, atlas);
% 
% seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'}); 
% seg.brain = mask_rha;
% cfg             = [];
% cfg.method      = 'iso2mesh';
% cfg.radbound    = 2;
% cfg.maxsurf     = 0;
% cfg.tissue      = 'brain';
% cfg.numvertices = 1000;
% cfg.smooth      = 3;
% mesh_rha = ft_prepare_mesh(cfg, seg);
% 
% % load('F:\Bonn\plotContacts\surface_white_left.mat');
% 
% 
% 
% % 
% % figure;
% % % ft_plot_mesh(mesh_left, 'facecolor', ([255,224,189])./255, 'edgecolor', 'none','facealpha',0.2);
% % ft_plot_mesh(mesh, 'facecolor', ([255,224,189]-100)./255, 'edgecolor', 'none','facealpha',0.2);
% 
% 
% % figure;
% hold on
% % ft_plot_mesh(mesh_rha, 'facecolor', ([255,224,189]-100)./255, 'edgecolor', 'none','facealpha',0.2);
% 
% ft_plot_mesh(mesh_rha, 'facecolor', 'b', 'edgecolor', 'none','facealpha',0.2);
% 
% view(130,-3);%for occi
% lighting gouraud; 
% camlight;
% 
% %% LH
% 
% 
% for n=1:size(coordinatesLH,1) 
%     hold on 
%     ft_plot_dipole(round(coordinatesLH(n,:)),[1 1 1], 'color', color_hipp(n,:),'diameter',3)
% %     n
% %     coordinatesAll(n,:)
% %     pause
% end 
% 
% %%
% % view(115,-33);%for occi
% view(84,-25);%for occi
% 
% 
% %% RH
% 
% coordinatesRH = [];
% hipp_col = raw(2:end,5);
% 
% colorHipp = [0 0 1];
% 
% color_hippR = [];
% for eleci = 1:length(hipp_col)
%     
%     
%     
%     if(isnan(( hipp_col{ eleci})) )
%         continue;
%     end
%     
%     if  isnan(str2num( hipp_col{ eleci}))
%         continue;
%     end
%     
%     coordinatesRH = [coordinatesRH;  str2num( hipp_col{ eleci})];
%     color_hippR = [color_hippR; colorHipp];
% 
% end
% %% RH
% %% hippocampus right
% %brainnetome
% cfg            = [];
% atlas.coordsys = 'mni';
% cfg.inputcoord = 'mni';
% cfg.atlas      = atlas;
% % cfg.roi        = {'Hipp, Left Hippocampus rHipp, rostral hippocampus',  'Hipp, Left Hippocampus cHipp, caudal hippocampus' };%, 'Hippocampus_R'} %{'Left-Hippocampus'};
% 
% % atlas.tissuelabel{109:120} parahippocampus
% % atlas.tissuelabel{211:214} amygdala
% % atlas.tissuelabel{215:218} hippocampus
% 
% cfg.roi = {atlas.tissuelabel{215:2:218}}; % right hippocampus
% 
% 
% % %     'Hipp, Right Hippocampus rHipp, rostral hippocampus'
% % % 
% % % 
% % %     'Hipp, Left Hippocampus rHipp, rostral hippocampus'
% % % 
% % % 
% % %     'Hipp, Right Hippocampus cHipp, caudal hippocampus'
% % % 
% % % 
% % %     'Hipp, Left Hippocampus cHipp, caudal hippocampus'
%     
%     
% mask_rha = ft_volumelookup(cfg, atlas);
% 
% seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'}); 
% seg.brain = mask_rha;
% cfg             = [];
% cfg.method      = 'iso2mesh';
% cfg.radbound    = 2;
% cfg.maxsurf     = 0;
% cfg.tissue      = 'brain';
% cfg.numvertices = 1000;
% cfg.smooth      = 3;
% mesh_rha = ft_prepare_mesh(cfg, seg);
% 
% % load('F:\Bonn\plotContacts\surface_white_left.mat');
% 
% 
% 
% % 
% % figure;
% % % ft_plot_mesh(mesh_left, 'facecolor', ([255,224,189])./255, 'edgecolor', 'none','facealpha',0.2);
% % ft_plot_mesh(mesh, 'facecolor', ([255,224,189]-100)./255, 'edgecolor', 'none','facealpha',0.2);
% 
% 
% % figure;
% hold on
% % ft_plot_mesh(mesh_rha, 'facecolor', ([255,224,189]-100)./255, 'edgecolor', 'none','facealpha',0.2);
% 
% ft_plot_mesh(mesh_rha, 'facecolor', 'b', 'edgecolor', 'none','facealpha',0.2);
% 
% view(130,-3);%for occi
% lighting gouraud; 
% camlight;
% 
% %%
% 
% 
% for n=1:size(coordinatesRH,1) 
%     hold on 
%     ft_plot_dipole(round(coordinatesRH(n,:)),[1 1 1], 'color', color_hippR(n,:),'diameter',3)
% %     n
% %     coordinatesAll(n,:)
% %     pause
% end 


%% Posterior hipp left
% 
% coordinatesLPH = [];
% hipp_col = raw(2:end,6);
% 
% colorHipp = [0 0 1];
% 
% color_hippLP = [];
% for eleci = 1:length(hipp_col)
%     
%     
%     
%     if(isnan(( hipp_col{ eleci})) )
%         continue;
%     end
%     
%     if  isnan(str2num( hipp_col{ eleci}))
%         continue;
%     end
%     
%     coordinatesLPH = [coordinatesLPH;  str2num( hipp_col{ eleci})];
%     color_hippLP = [color_hippLP; colorHipp];
% 
% end
% 
% %% LPH
% 
% for n=1:size(coordinatesLPH,1) 
%     hold on 
%     ft_plot_dipole(round(coordinatesLPH(n,:)),[1 1 1], 'color', color_hippLP(n,:),'diameter',3)
% %     n
% %     coordinatesAll(n,:)
% %     pause
% end 
% 
% %% posterior hipp right
% 
% 
% coordinatesRPH = [];
% hipp_col = raw(2:end,7);
% 
% colorHipp = [0 0 1];
% 
% color_hippRP = [];
% for eleci = 1:length(hipp_col)
%     
%     
%     
%     if(isnan(( hipp_col{ eleci})) )
%         continue;
%     end
%     
%     if  isnan(str2num( hipp_col{ eleci}))
%         continue;
%     end
%     
%     coordinatesRPH = [coordinatesRPH;  str2num( hipp_col{ eleci})];
%     color_hippRP = [color_hippRP; colorHipp];
% 
% end
% 
% %%
% for n=1:size(coordinatesRPH,1) 
%     hold on     
%     ft_plot_dipole(round(coordinatesRPH(n,:)),[1 1 1], 'color', color_hippRP(n,:),'diameter',3)
% %     n
% %     coordinatesAll(n,:)
% %     pause
% end 
% 
% %% RA
% 
% % colorAmy = [0 1 1];
% 
% colorAmy = [0.3010 0.7450 0.9330]-0.2;
% 
% coordinatesRA = [];
% amy_col = raw(2:end,3);
% 
% color_AmyR = [];
% for eleci = 1:length(amy_col)
%     
%     
%     
%     if(isnan(( amy_col{ eleci})) )
%         continue;
%     end
%     
%     if  isnan(str2num( amy_col{ eleci}))
%         continue;
%     end
%     
%     coordinatesRA = [coordinatesRA;  str2num( amy_col{ eleci})];
%     color_AmyR = [color_AmyR; colorAmy];
% 
% end
% 
% %% RA
% 
% %% amygdala right
% %brainnetome
% cfg            = [];
% atlas.coordsys = 'mni';
% cfg.inputcoord = 'mni';
% cfg.atlas      = atlas;
% % cfg.roi        = {'Hipp, Left Hippocampus rHipp, rostral hippocampus',  'Hipp, Left Hippocampus cHipp, caudal hippocampus' };%, 'Hippocampus_R'} %{'Left-Hippocampus'};
% 
% % atlas.tissuelabel{109:120} parahippocampus
% % atlas.tissuelabel{211:214} amygdala
% % atlas.tissuelabel{215:218} hippocampus
% 
% cfg.roi = {atlas.tissuelabel{211:2:214}};
% 
% 
% % %     'Hipp, Right Hippocampus rHipp, rostral hippocampus'
% % % 
% % % 
% % %     'Hipp, Left Hippocampus rHipp, rostral hippocampus'
% % % 
% % % 
% % %     'Hipp, Right Hippocampus cHipp, caudal hippocampus'
% % % 
% % % 
% % %     'Hipp, Left Hippocampus cHipp, caudal hippocampus'
%     
%     
% mask_rha = ft_volumelookup(cfg, atlas);
% 
% seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'}); 
% seg.brain = mask_rha;
% cfg             = [];
% cfg.method      = 'iso2mesh';
% cfg.radbound    = 2;
% cfg.maxsurf     = 0;
% cfg.tissue      = 'brain';
% cfg.numvertices = 1000;
% cfg.smooth      = 3;
% mesh_rha = ft_prepare_mesh(cfg, seg);
% 
% % load('F:\Bonn\plotContacts\surface_white_left.mat');
% 
% 
% 
% % 
% % figure;
% % % ft_plot_mesh(mesh_left, 'facecolor', ([255,224,189])./255, 'edgecolor', 'none','facealpha',0.2);
% % ft_plot_mesh(mesh, 'facecolor', ([255,224,189]-100)./255, 'edgecolor', 'none','facealpha',0.2);
% 
% 
% % figure;
% hold on
% % ft_plot_mesh(mesh_rha, 'facecolor', ([255,224,189]-100)./255, 'edgecolor', 'none','facealpha',0.2);
% 
% ft_plot_mesh(mesh_rha, 'facecolor', 'c', 'edgecolor', 'none','facealpha',0.2);
% 
% view(130,-3);%for occi
% lighting gouraud; 
% camlight;
% 
% %% RA
% 
% for n=1:size(coordinatesRA,1) 
%     hold on 
%     ft_plot_dipole(round(coordinatesRA(n,:)),[1 1 1], 'color', color_AmyR(n,:),'diameter',3)
% %     n
% %     coordinatesAll(n,:)
% %     pause
% end 
% 
% %% LA
% 
% % colorAmy = [0 1 1];
% colorAmy = [0.3010 0.7450 0.9330]-0.2;
% 
% % figure, plot(1:10, ones(1,10), 'color', colorAmy , 'LineWidth', 10)
% 
% 
% coordinatesLA = [];
% amy_col = raw(2:end,2);
% 
% 
% color_AmyL = [];
% for eleci = 1:length(amy_col)
%     
%     
%     
%     if(isnan(( amy_col{ eleci})) )
%         continue;
%     end
%     
%     if  isnan(str2num( amy_col{ eleci}))
%         continue;
%     end
%     
%     coordinatesLA = [coordinatesLA;  str2num( amy_col{ eleci})];
%     color_AmyL = [color_AmyL; colorAmy];
% 
% end
% 
% 
% %% amygdala left
% %brainnetome
% cfg            = [];
% atlas.coordsys = 'mni';
% cfg.inputcoord = 'mni';
% cfg.atlas      = atlas;
% % cfg.roi        = {'Hipp, Left Hippocampus rHipp, rostral hippocampus',  'Hipp, Left Hippocampus cHipp, caudal hippocampus' };%, 'Hippocampus_R'} %{'Left-Hippocampus'};
% 
% % atlas.tissuelabel{109:120} parahippocampus
% % atlas.tissuelabel{211:214} amygdala
% % atlas.tissuelabel{215:218} hippocampus
% 
% cfg.roi = {atlas.tissuelabel{212:2:214}};
% 
% 
% % %     'Hipp, Right Hippocampus rHipp, rostral hippocampus'
% % % 
% % % 
% % %     'Hipp, Left Hippocampus rHipp, rostral hippocampus'
% % % 
% % % 
% % %     'Hipp, Right Hippocampus cHipp, caudal hippocampus'
% % % 
% % % 
% % %     'Hipp, Left Hippocampus cHipp, caudal hippocampus'
%     
%     
% mask_rha = ft_volumelookup(cfg, atlas);
% 
% seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'}); 
% seg.brain = mask_rha;
% cfg             = [];
% cfg.method      = 'iso2mesh';
% cfg.radbound    = 2;
% cfg.maxsurf     = 0;
% cfg.tissue      = 'brain';
% cfg.numvertices = 1000;
% cfg.smooth      = 3;
% mesh_rha = ft_prepare_mesh(cfg, seg);
% 
% % load('F:\Bonn\plotContacts\surface_white_left.mat');
% 
% 
% 
% % 
% % figure;
% % % ft_plot_mesh(mesh_left, 'facecolor', ([255,224,189])./255, 'edgecolor', 'none','facealpha',0.2);
% % ft_plot_mesh(mesh, 'facecolor', ([255,224,189]-100)./255, 'edgecolor', 'none','facealpha',0.2);
% 
% 
% % figure;
% hold on
% % ft_plot_mesh(mesh_rha, 'facecolor', ([255,224,189]-100)./255, 'edgecolor', 'none','facealpha',0.2);
% 
% ft_plot_mesh(mesh_rha, 'facecolor', 'c', 'edgecolor', 'none','facealpha',0.2);
% 
% view(130,-3);%for occi
% lighting gouraud; 
% camlight;
% 
% %% LA
% for n=1:size(coordinatesLA,1) 
%     hold on 
%     ft_plot_dipole(round(coordinatesLA(n,:)),[1 1 1], 'color', color_AmyL(n,:),'diameter',3)
% %     n
% %     coordinatesAll(n,:)
% %     pause
% end 
% %% color parahipp  RPHG
% 
% 
% colorPara = [1 0 1];
% 
% 
% coordinatesRPHG = [];
% para_col = raw(2:end,9);
% 
% 
% color_RPHG = [];
% for eleci = 1:length(para_col)
%     
%     
%     
%     if(isnan(( para_col{ eleci})) )
%         continue;
%     end
%     
%     if  isnan(str2num( para_col{ eleci}))
%         continue;
%     end
%     
%     coordinatesRPHG = [coordinatesRPHG;  str2num( para_col{ eleci})];
%     color_RPHG = [color_RPHG; colorPara];
% 
% end
% 
% %% parahippocampal gyrus right
% %brainnetome
% cfg            = [];
% atlas.coordsys = 'mni';
% cfg.inputcoord = 'mni';
% cfg.atlas      = atlas;
% % cfg.roi        = {'Hipp, Left Hippocampus rHipp, rostral hippocampus',  'Hipp, Left Hippocampus cHipp, caudal hippocampus' };%, 'Hippocampus_R'} %{'Left-Hippocampus'};
% 
% % atlas.tissuelabel{109:120} parahippocampus
% % atlas.tissuelabel{211:214} amygdala
% % atlas.tissuelabel{215:218} hippocampus
% 
% cfg.roi = {atlas.tissuelabel{109:2:120}}; % right parahippocampal gyrus
% % cfg.roi = {atlas.tissuelabel{110:2:120}}; % left parahippocampal gyrus
% 
% % %     'Hipp, Right Hippocampus rHipp, rostral hippocampus'
% % % 
% % % 
% % %     'Hipp, Left Hippocampus rHipp, rostral hippocampus'
% % % 
% % % 
% % %     'Hipp, Right Hippocampus cHipp, caudal hippocampus'
% % % 
% % % 
% % %     'Hipp, Left Hippocampus cHipp, caudal hippocampus'
%     
%     
% mask_rha = ft_volumelookup(cfg, atlas);
% 
% seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'}); 
% seg.brain = mask_rha;
% cfg             = [];
% cfg.method      = 'iso2mesh';
% cfg.radbound    = 2;
% cfg.maxsurf     = 0;
% cfg.tissue      = 'brain';
% cfg.numvertices = 1000;
% cfg.smooth      = 3;
% mesh_rha = ft_prepare_mesh(cfg, seg);
% 
% % load('F:\Bonn\plotContacts\surface_white_left.mat');
% 
% 
% 
% % 
% % figure;
% % % ft_plot_mesh(mesh_left, 'facecolor', ([255,224,189])./255, 'edgecolor', 'none','facealpha',0.2);
% % ft_plot_mesh(mesh, 'facecolor', ([255,224,189]-100)./255, 'edgecolor', 'none','facealpha',0.2);
% 
% 
% % figure;
% hold on
% % ft_plot_mesh(mesh_rha, 'facecolor', ([255,224,189]-100)./255, 'edgecolor', 'none','facealpha',0.2);
% 
% ft_plot_mesh(mesh_rha, 'facecolor', 'm', 'edgecolor', 'none','facealpha',0.2);
% 
% % view([120 40]); 
% lighting gouraud; 
% camlight;
% 
% 
% 
% 
% %% RPHG
% 
% for n=1:size(coordinatesRPHG,1) 
%     hold on 
%     ft_plot_dipole(round(coordinatesRPHG(n,:)),[1 1 1], 'color', color_RPHG(n,:),'diameter',3)
% %     n
% %     coordinatesAll(n,:)
% %     pause
% end 
% 
% %% color parahipp  LPHG
% 
% 
% colorPara = [1 0 1];
% 
% coordinatesLPHG = [];
% para_col = raw(2:end,8);
% 
% 
% color_LPHG = [];
% for eleci = 1:length(para_col)
%     
%     
%     
%     if(isnan(( para_col{ eleci})) )
%         continue;
%     end
%     
%     if  isnan(str2num( para_col{ eleci}))
%         continue;
%     end
%     
%     coordinatesLPHG = [coordinatesLPHG;  str2num( para_col{ eleci})];
%     color_LPHG = [color_LPHG; colorPara];
% 
% end
% 
% %% parahippocampal gyrus left
% %brainnetome
% cfg            = [];
% atlas.coordsys = 'mni';
% cfg.inputcoord = 'mni';
% cfg.atlas      = atlas;
% % cfg.roi        = {'Hipp, Left Hippocampus rHipp, rostral hippocampus',  'Hipp, Left Hippocampus cHipp, caudal hippocampus' };%, 'Hippocampus_R'} %{'Left-Hippocampus'};
% 
% % atlas.tissuelabel{109:120} parahippocampus
% % atlas.tissuelabel{211:214} amygdala
% % atlas.tissuelabel{215:218} hippocampus
% 
% % cfg.roi = {atlas.tissuelabel{109:2:120}}; % right parahippocampal gyrus
% cfg.roi = {atlas.tissuelabel{110:2:120}}; % left parahippocampal gyrus
% 
% % %     'Hipp, Right Hippocampus rHipp, rostral hippocampus'
% % % 
% % % 
% % %     'Hipp, Left Hippocampus rHipp, rostral hippocampus'
% % % 
% % % 
% % %     'Hipp, Right Hippocampus cHipp, caudal hippocampus'
% % % 
% % % 
% % %     'Hipp, Left Hippocampus cHipp, caudal hippocampus'
%     
%     
% mask_rha = ft_volumelookup(cfg, atlas);
% 
% seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'}); 
% seg.brain = mask_rha;
% cfg             = [];
% cfg.method      = 'iso2mesh';
% cfg.radbound    = 2;
% cfg.maxsurf     = 0;
% cfg.tissue      = 'brain';
% cfg.numvertices = 1000;
% cfg.smooth      = 3;
% mesh_rha = ft_prepare_mesh(cfg, seg);
% 
% % load('F:\Bonn\plotContacts\surface_white_left.mat');
% 
% 
% 
% % 
% % figure;
% % % ft_plot_mesh(mesh_left, 'facecolor', ([255,224,189])./255, 'edgecolor', 'none','facealpha',0.2);
% % ft_plot_mesh(mesh, 'facecolor', ([255,224,189]-100)./255, 'edgecolor', 'none','facealpha',0.2);
% 
% 
% % figure;
% hold on
% % ft_plot_mesh(mesh_rha, 'facecolor', ([255,224,189]-100)./255, 'edgecolor', 'none','facealpha',0.2);
% 
% ft_plot_mesh(mesh_rha, 'facecolor', 'm', 'edgecolor', 'none','facealpha',0.2);
% 
% % view([120 40]); 
% lighting gouraud; 
% camlight;
% 
% 
% 
% %% LPHG
% 
% for n=1:size(coordinatesLPHG,1) 
%     hold on 
%     ft_plot_dipole(round(coordinatesLPHG(n,:)),[1 1 1], 'color', color_LPHG(n,:),'diameter',3)
% %     n
% %     coordinatesAll(n,:)
% %     pause
% end 
% 
% %%
% % concatenate all
% 
% coordinatesAll = [coordinatesLH; coordinatesRH; coordinatesLPH; coordinatesRPH; coordinatesRA; coordinatesLA; coordinatesRPHG; coordinatesLPHG ];
% 
% colores = [color_hipp; color_hippR; color_hippLP; color_hippRP; color_AmyR; color_AmyL; color_RPHG; color_LPHG];
% 
% 
% 
% 
% 
% %%  
% 
% % % 
% % % 
% % % %% plot all the contacts
% % % view(136,27);%for occi
% % % coordinatesAll(157,:) = [];
% % % coordinatesAll(158,:) = [];
% % % coordinatesAll(159,:) = [];
% % % 
% 
% 
% 
% for n=1:size(coordinatesAll,1) 
%     hold on 
%     ft_plot_dipole(round(coordinatesAll(n,:)),[1 1 1], 'color', colores(n,:),'diameter',3)
% %     n
% %     coordinatesAll(n,:)
% %     pause
% end 
% 
% %%
% % view(115,-33);%for occi
% view(120,26);%for occi

% cd S:\Mar\Code\PlotCoordinates
% print('-dpng','-r500','CoordinatesMarPoster3.png')




