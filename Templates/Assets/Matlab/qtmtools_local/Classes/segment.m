classdef segment < pose6d & labeladmin2
    %segment Segment representation and methods for working with Qualisys
    %   skeleton segments.
    
    %   Further expand help info
    
    properties
        Parent = ''  % Parent system (some type of pose6d) [char]
    end
    
    methods
        function s = segment(pos,qrot,lab,par)
            if nargin < 1, pos=vec3d(); end
            if nargin < 2, qrot=quaternion(); end
            if nargin < 3, lab=""; end
            if nargin < 4, par=""; end
            s@labeladmin2(lab);
            s@pose6d(pos,qrot);
            s.Parent = par;
        end
        
        function sloc = global2local(s,ref)
            %function sloc = global2local(s,ref)
            %   Transform segment data to reference segment coordinates.
            %   When the Position and Rotation properties of s and sref
            %   are not the same size, calculation uses binary singleton
            %   expansion (for example tranform s relative to fixed
            %   reference). 
            sloc = global2local@pose6d(s,ref);
            if ismember('Label',properties(ref))
                sloc.Parent = ref.Label;
            end
        end
        
    end %  methods
    
end % classdef segment

