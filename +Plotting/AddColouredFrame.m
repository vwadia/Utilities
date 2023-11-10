function framed_img = AddColouredFrame(img, bColor, brderSize)
% MATLAB CODE Add Coloured Frame to the RGB image.
% adapted from geeksforgeeks example
% vwadiaJune2023

if nargin == 2, brderSize = 10; end
% This function takes colour image only.
[x,y,~]=size(img);
framed_img(1:x+(2*brderSize),1:y+(2*brderSize),1)=bColor(1)*255;
framed_img(1:x+(2*brderSize),1:y+(2*brderSize),2)=bColor(2)*255;
framed_img(1:x+(2*brderSize),1:y+(2*brderSize),3)=bColor(3)*255;

framed_img=uint8(framed_img);

framed_img(brderSize+1:x+brderSize,brderSize+1:y+brderSize,:)=img(:,:,:);
  
end

