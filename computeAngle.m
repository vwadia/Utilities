function [angleInDegrees] = computeAngle(u, v)
% little utility function to compute angle
% taken from a matthworks question about the same
% vwadia jan2023

CosTheta = max(min(dot(u,v)/(norm(u)*norm(v)),1),-1);
angleInDegrees = real(acosd(CosTheta));