classdef trajectory < labeladmin2
    %trajectory Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Label = ''
%         Position = vec3d.empty()
%         Residual = []
%         Type = []
        Position vec3d
        Residual double
        Type double
    end
    
    methods
        function traj = trajectory(pos,res,type,lab)
            %trajectory Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 1, pos = vec3d(); end
            if nargin < 2, res = []; end
            if nargin < 3, type = []; end
            if nargin < 4, lab = ""; end
            
            if ~isa(pos,'vec3d')
                pos = vec3d(squeeze(pos));
            end
            
            % Check sizes of input
            szp = size(pos);
            if szp(2) > szp(1)
                pos = pos.'; % Convert to column
                szp = szp([2 1]);
            end
            
            if szp(2)~=1 % Only accept single row/column of position data
                error('trajectory:constructor','Invalid input') 
            end
            
            nfr = szp(1);
            
            if isempty(res)
                res = NaN(szp);
            else
                res = res(:);
            end
            
            if length(res) ~= nfr
                error('trajectory:constructor','Invalid input')
            end
            
            if isempty(type)
                type = NaN(szp);
            else
                type = type(:);
            end
            
            if length(type) ~= nfr
                error('trajectory:constructor','Invalid input')
            end
            
            traj.Label = lab;
            traj.Position = pos;
            traj.Residual = res;
            traj.Type = type;
        end
        
        function d = distance(tr1,tr2)
            %function d = distance(tr1,tr2)
            %  Calculate distance between trajectories
            %  tr1, tr2: trajectory arrays (support for binary singleton expansion)
            %  Output d: double
            d = distance([tr1.Position],[tr2.Position]);
        end
        
        function p_loc = global2local(trajs,ref)
            %function p_loc = global2local(tr,ref)
            %   Transform trajectory to reference coordinates.
            %   ref can be a pos6d, rigidbody or segment class
            %   Output is a vec3d array
            %   When the Position and Rotation properties of tr and ref
            %   are not the same size, calculation uses binary singleton
            %   expansion (for example tranform trajectory relative to
            %   fixed reference).
            p_loc = rotate_vec3d([trajs.Position]-ref.Position,...
                ref.Rotation.inverse()); % position relative to reference
        end
        
        function p = mean(trjs,varargin)
            %function v = mean(trjs)
            %  Calculate mean of trajectories
            %  Output v: vec3d array
            p = mean([trjs.Position], varargin{:});
        end
        
        function p = minus(tr1,tr2)
            %function v = minus(tr1,tr2)
            %  Calculate difference between trajectories
            %  tr1, tr2: trajectory arrays (support for binary singleton expansion)
            %  Output v: vec3d object
            p = minus([tr1.Position], [tr2.Position]);
        end
        
        function p = plus(tr1,tr2)
            %function v = plus(tr1,tr2)
            %  Calculate difference between trajectories
            %  tr1, tr2: trajectory arrays (support for binary singleton expansion)
            %  Output v: vec3d object
            p = plus([tr1.Position], [tr2.Position]);
        end
        
        function p = rdivide(arg1,arg2)
            %function v = rdivide(arg1,arg2)
            %  Calculate difference between trajectories
            %  Output v: vec3d object
            if isa(arg1,'trajectory')
                arg1 = arg1.Position;
            end
            if isa(arg2,'trajectory')
                arg2 = arg2.Position;
            end
            p = rdivide(arg1,arg2);
        end
        
        function p = times(arg1,arg2)
            %function v = times(arg1,arg2)
            %  Calculate difference between trajectories
            %  Output v: vec3d object
            if isa(arg1,'trajectory')
                arg1 = arg1.Position;
            end
            if isa(arg2,'trajectory')
                arg2 = arg2.Position;
            end
            p = times(arg1,arg2);
        end
        
        function xdata = x(trajs,sel)
            %function xdata = x(trajs,sel)
            %  Get x data from trajectories
            %  Use sel to select the frames
            data = arrayfun(@(t)(double(t.Position).'),trajs,...
                'UniformOutput',false);
            xyzdata = cat(3,data{:});
            if nargin < 2
                xdata = squeeze(xyzdata(:,1,:));
            else
                xdata = squeeze(xyzdata(sel,1,:));
            end
        end
        
        function ydata = y(trajs,sel)
            %function ydata = y(trajs,sel)
            %  Get y data from trajectories
            %  Use sel to select the frames
            data = arrayfun(@(t)(double(t.Position).'),trajs,...
                'UniformOutput',false);
            xyzdata = cat(3,data{:});
            if nargin < 2
                ydata = squeeze(xyzdata(:,2,:));
            else
                ydata = squeeze(xyzdata(sel,2,:));
            end
        end
        
        function zdata = z(trajs,sel)
            %function zdata = z(trajs,sel)
            %  Get z data from trajectories
            %  Use sel to select the frames
            data = arrayfun(@(t)(double(t.Position).'),trajs,...
                'UniformOutput',false);
            xyzdata = cat(3,data{:});
            if nargin < 2
                zdata = squeeze(xyzdata(:,3,:));
            else
                zdata = squeeze(xyzdata(sel,3,:));
            end
        end
        
        function xyzdata = xyz(trajs,sel)
            %function zdata = z(trajs,sel)
            %  Get z data from trajectories
            %  Use sel to select the frames
            data = arrayfun(@(t)(double(t.Position).'),trajs,...
                'UniformOutput',false);
            xyzdata = cat(3,data{:});
            if nargin > 1
                xyzdata = xyzdata(sel,:,:);
            end
        end
        
    end
end

