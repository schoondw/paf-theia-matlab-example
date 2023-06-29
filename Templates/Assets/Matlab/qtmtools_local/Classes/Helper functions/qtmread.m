function qtm=qtmread(fn)
%
%
%

if nargin==0
    [fname,pname] = uigetfile({'*.mat', '.mat files'}, 'Load QTM mat file');
    fn = [pname fname];
end

S=load(fn);

% Parse S
sflds=fieldnames(S);
if length(sflds)>1
    error('Only one variable (struct) is expected in a .mat file exported by QTM.')
else
    qtm=S.(sflds{1});
end
