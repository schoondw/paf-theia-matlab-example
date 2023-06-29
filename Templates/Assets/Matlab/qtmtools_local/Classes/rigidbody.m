classdef rigidbody < pose6d & labeladmin2
    %rigidbody Rigid body representation and methods for working with
    %   Qualisys rigid bodies.
    
    %   Further expand help info
    
    properties
        Parent string     % Parent system (some type of pose6d) [string]
        Residual double  % Rigid body residual
    end
    
    methods
        function rb = rigidbody(pos,qrot,res,lab,par)
            if nargin < 1, pos=vec3d(); end
            if nargin < 2, qrot=quaternion(); end
            if nargin < 3, res=[]; end
            if nargin < 4, lab=""; end
            if nargin < 5, par=""; end
            rb@labeladmin2(lab);
            rb@pose6d(pos,qrot);
            rb.Residual = squeeze(res);
            %rb.Label = lab;
            rb.Parent = par;
        end
        
        function rbloc = global2local(rb,ref)
            %function rbloc = global2local(rb,ref)
            %   Transform segment data to reference segment coordinates.
            %   When the Position and Rotation properties of rb and ref
            %   are not the same size, calculation uses binary singleton
            %   expansion (for example tranform rb relative to fixed
            %   reference).
            rbloc = global2local@pose6d(rb,ref);
            if ismember('Label',properties(ref))
                rbloc.Parent = ref.Label;
            end
        end
        
%         function lst = getlabels(rb) % Obsolete, use labeladmin2 methods instead
%             % Get labels of rigid bodies (array)
%             lst = [rb.Label];
%         end
        
    end %  methods
    
end % classdef rigidbody
