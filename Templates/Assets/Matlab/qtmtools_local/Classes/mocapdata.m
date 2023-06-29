classdef mocapdata
    %mocapdata Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name string                         % Trial name
        Timestamp = datetime.empty()        % Computer time at start of trial
        StartFrame = []                     % First frame of trial, when cropped
        Frames = []                         % Number of frames
        FrameRate = []                      % Frame rate
        Events = []                         % Events (struct)
        Trajectories = trajectory.empty()   % Trajectories (type: trajectory)
        RigidBodies = rigidbody.empty()     % RigidBodies (type: rigid_body)
        Skeletons = skeleton.empty()        % Skeletons (type: skeleton)
    end
    
    properties (Dependent)
        Time double                         % Time array (seconds from start of trial)
    end
    
    methods
        function mc = mocapdata(varargin)
            %mocapdata Construct an instance of this class
            %   Detailed explanation goes here
            qtm_header_flds = {'File','Timestamp',...
                'StartFrame','Frames','FrameRate'};
            
            if nargin<1, return; end % Return with default (empty) data
            
            % Parse data from QTM mat file
            if ischar(varargin{1}) || isstring(varargin{1})
                qtm = qtmread(varargin{1});
            elseif isstruct(varargin{1}) && ...
                    sum(isfield(varargin{1},qtm_header_flds)) == length(qtm_header_flds)
                qtm = varargin{1};
            end
            
            % File info
            [~,mc.Name] = fileparts(qtm.File);
            if ~isempty(qtm.Timestamp)
                ts_sep = regexp(qtm.Timestamp, '\t');
                mc.Timestamp = datetime(qtm.Timestamp(1:ts_sep-1),...
                    'InputFormat','yyyy-MM-dd, HH:mm:ss.SSS',...
                    'Format','yyyy-MM-dd HH:mm:ss.SSS',...
                    'TimeZone','local');
            end
            mc.StartFrame = qtm.StartFrame;
            mc.Frames = qtm.Frames;
            mc.FrameRate = qtm.FrameRate;
            
            % Events structure array (fields: Label, Frame, Time)
            % Maybe to be turned into events class in the future (with label admin for easy selection)
            if isfield(qtm,'Events')
                mc.Events = qtm.Events;
            end
            
            % Frame selection (quick and dirty work around)
            % Preliminary implementation:
            % Frame range as second input parameter (as is)
            % Currently not implemented for skeleton data
            % To do: implement via parsing of property value pairs,
            % including validation
            frame_sel = 1:mc.Frames; % Default
            if nargin > 1
                frame_sel = varargin{2};
                mc.StartFrame = mc.StartFrame + frame_sel(1) - 1;
                mc.Frames = frame_sel(end) - frame_sel(1) + 1;
            end
                
            
            % Parse trajectories
            if isfield(qtm,'Trajectories') && ...
                    isfield(qtm.Trajectories,'Labeled')
                traj_array = parse_trajectories(qtm.Trajectories.Labeled, frame_sel);
                
                % mc.TrajAdmin = labeladmin({traj_array.Label});
                mc.Trajectories = traj_array;
            end
            
            % Parse rigid bodies
            if isfield(qtm,'RigidBodies')
                rb_array = parse_rigidbodies(qtm.RigidBodies, frame_sel);
                
                % mc.RBAdmin = labeladmin({rb_array.Label});
                mc.RigidBodies = rb_array;
            end
            
            % Parse skeletons
            if isfield(qtm,'Skeletons')
                skel_array = parse_skeletons(qtm.Skeletons, frame_sel);
                
                % mc.SkelAdmin = labeladmin({skel_array.Name});
                mc.Skeletons = skel_array;
            end
            
        end
        
        function t_array = get.Time(obj)
            t_array = ((obj.StartFrame:obj.Frames)'-1)./obj.FrameRate;
        end
    
    end
    
end


% Helper functions
% - Read QTM mat file
function qtm=qtmread(fn)
% Read QTM MAT file
if nargin==0
    [fname,pname] = uigetfile({'*.mat', '.mat files'}, 'Load QTM mat file');
    fn = [pname fname];
end

S=load(fn);

% Parse S
sflds=fieldnames(S);
if length(sflds)>1
    error('mocapdata:qtmread',...
        ['Wrong format of file: %s\n'...
        'Only one variable (QTM data structure) is expected in a .mat file exported by QTM.'], fname)
else
    qtm=S.(sflds{1});
    if ~isstruct(qtm)
        error('mocapdata:qtmread',...
            'No data structure found in file: %s', fname)
    end
end
end % qtmread


function traj_array = parse_trajectories(qtmstruct, frame_sel)
% Parse labeled trajectory data
% Input:
% - qtm data struct
% - qtm.Trajectories.Labeled struct

traj_flds = {'Count','Labels','Data','Type'}; % Required fields

if isfield(qtmstruct,'Trajectories') && ...
        isfield(qtmstruct.Trajectories,'Labeled')
    trs=qtmstruct.Trajectories.Labeled;
elseif sum(isfield(qtmstruct,traj_flds)) == length(traj_flds)
    trs = qtmstruct;
else
    error('mocapdata:parse_trajectories','Invalid input')
end

ntr = trs.Count;
for k=ntr:-1:1 % In reverse order for allocation
    lab = trs.Labels{k};
    pos = trs.Data(k,1:3,frame_sel);
    res = trs.Data(k,4,frame_sel);
    type = trs.Type(k,frame_sel);
    
    traj_array(k) = trajectory(pos,res,type,lab);
end
end % parse_trajectories


function rb_array = parse_rigidbodies(qtmstruct, frame_sel)
% Parse rigid body data
% Input:
% - qtm data struct
% - qtm.RigidBodies struct

rb_flds = {'Bodies','Name','Positions','Rotations','Residual'}; % Required fields
% "Filter" not used yet, "RPYs" not needed

if isfield(qtmstruct,'RigidBodies')
    rbs=qtmstruct.RigidBodies;
elseif sum(isfield(qtmstruct,rb_flds)) == length(rb_flds)
    rbs = qtmstruct;
else
    error('mocapdata:parse_rigidbodies','Invalid input')
end

nrb = rbs.Bodies;
for k=nrb:-1:1 % In reverse order for allocation
    lab = rbs.Name{k};
    pos = rbs.Positions(k,:,frame_sel);
    rot = rbs.Rotations(k,:,frame_sel);
    res = rbs.Residual(k,:,frame_sel);
    
    rb_array(k) = rigidbody(pos,rot,res,lab);
end
end % parse_rigidbodies


function skel_array = parse_skeletons(qtmstruct, frame_sel)
% Parse skeleton data
% Input:
% - qtm data struct
% - qtm.Skeletons struct array

skel_flds = {'SkeletonName','NrOfSegments','SegmentLabels','PositionData','RotationData'};

if isfield(qtmstruct,'Skeletons')
    skels=qtmstruct.Skeletons;
elseif sum(isfield(qtmstruct,skel_flds)) == length(skel_flds)
    skels = qtmstruct;
else
    error('mocapdata:parse_skeletons','Invalid input')
end

nsk = length(skels);
for k = nsk:-1:1
    skel_array(k) = skeleton(skels(k), frame_sel);
end
end % parse_skeletons
