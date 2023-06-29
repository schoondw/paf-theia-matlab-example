function [sx, rx1, rx2] = bsx_size(s1, s2, errid_caller)
% function [sx, rx1, rx2] = bsx_size(s1, s2)
% 
% Calculate size of output array for binary singleton expansion
% Input: array sizes respective arrays (from size function)
% Ouput: expanded array size
% Optional output: rx1, rx2 are arrays that can be used as input to repmat
% to expand the respective arrays to the extended size in case binary array
% expansion is not supported.
% 
% More info: Matlab documentation, Compatible Array Sizes for Basic Operations

if nargin < 3
    errid = 'QTMTools:bsx_size';
else
    errid = fprintf('%s:bsx_size', errid_caller);
end

le1 = numel(s1);
le2 = numel(s2);

% Initialize
m = min(le1, le2);
n = max(le1, le2);

sx = ones(1,n);
rx1 = ones(1,n);
rx2 = ones(1,n);
if le1 > le2
    sx(m+1:n) = s1(m+1:n);
    rx2(m+1:n) = s1(m+1:n);
elseif le2 > le1
    sx(m+1:n) = s2(m+1:n);
    rx1(m+1:n) = s2(m+1:n);
end

for k=1:m
    if isequal(s1(k), s2(k))
        sx(k) = s1(k);
    elseif s1(k) == 1
        sx(k) = s2(k);
        rx1(k) = s2(k);
    elseif s2(k) == 1
        sx(k) = s1(k);
        rx2(k) = s1(k);
    else
        error(errid,'Incompatible arrays sizes.')
    end
end