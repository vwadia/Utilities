%
% for recallevents structure
%
% vwadia May2019
%

function descr = translateCategory(index)
switch index
    case 1
        descr = 'Face';
    case 2
        descr = 'Food';
    case 3 
        descr = 'cars';
    case 4
        descr = 'scene';
    case 5
        descr = 'animal';
    case 6
        descr = 'flower';
    case 7
        descr = 'gadget';
        
    otherwise 
        descr = 'N/A'
end
end