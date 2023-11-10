function patchImg = patchShow(images1, images2, rows, cols)
% Function to take two sets of images and produce a patchwork image, such that 
% (i, j) is from set 1 and (i, j+1) is the counterpart in set 2
% 
% INPUTS:
%     1. Image set 1 as a hxwximgs matrix
%     2. Image set 2 
%     3. Number of rows you want
%     4. Number of columns you want
%     
% OUTPUTS:
%     1. A patchwork image
%     
% vwadia/August2022
% Have not completed because postItPlot might make this redundant

assert(isequal(size(images1, 3), size(images2, 3)), 'Need to have equal number of images in each set')

if nargin == 3
    cols = 2*size(images1, 3)/rows;
    assert(mod(cols, 2) == 0, 'Need an even number of columns')
end

bigMat = [];
bMRow = cell(rows, 1);
patchImg = figure;
set(gcf,'Position',get(0,'Screensize')) % display fullsize on other screen

for row = 1:rows
    
    for col = 1:cols/2
        
        bMRow{row, 1} = [bMRow{row, 1} images1(:, :, ((row-1)*cols/2)+col) images2(:, :, ((row-1)*cols/2)+col)];
        
    end
    
    bigMat = [bigMat; bMRow{row, 1}];
end

imshow(bigMat);
