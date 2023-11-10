%
% convert numerical brain area code to string
% this convention is used in brainArea.mat to assign each channel/cell to a brain area
%
%
function descr = inverseTranslateArea(areaCode)
descr=[];

if length(areaCode)==1
    if iscell(areaCode)
        descr = inverseTranslateOneArea(areaCode{1});
    else
        descr = inverseTranslateOneArea(areaCode);
    end
else
    for i=1:length(areaCode)
        if iscell(areaCode(i))
            descr{i}= inverseTranslateOneArea(areaCode{i});
        else
            descr{i}= inverseTranslateOneArea(areaCode(i));
        end
    end
end


%-- internal functions
%1=RH, 2=LH, 3=RA, 4=LA, 5=RAC, 6=LAC
%....
function descr = inverseTranslateOneArea(areaCode)
switch (areaCode)
    case 'RH'
        descr=1;
    case 'LH'
        descr=2;
    case 'RA'
        descr=3;
    case 'LA'
        descr=4;
    case 'RAC'
        descr=5;
    case 'LAC'
        descr=6;
    case 'RSMA'
        descr=7;
    case 'LSMA'
        descr=8;
    case 'ROF'
        descr=9; %orbitofrontal right
    case 'LOF'
        descr=10; %orbitofrontal left
    case 'RPHG'
        descr=11;
    case 'LPHG'
        descr=12;
    case 'RFFA'
        descr=13; %fusiform face area right
    case 'LFFA'
        descr=14; %fusiform face area left
    case 'REC'
        descr=15; %entorhinal cortex right
    case 'LEC'
        descr=16; %entorhinal cortex left
    case 'RPH'
        descr=17; %posterior hippocampus
    case 'LPH'
        descr=18; %posterior hippocampus
    case 'RAINS'
        descr=19; %anterior insula
    case 'LAINS'
        descr=20; %anterior insula  
    case 'RCMT'
        descr=21; %central medial thalamus
    case 'LCMT'
        descr=22; %central medial thalamus
    case 'RPUL'
        descr=23; %pulvinar 
    case 'LPUL'
        descr=24; %pulvinar 
        
    otherwise
        descr=0;
end