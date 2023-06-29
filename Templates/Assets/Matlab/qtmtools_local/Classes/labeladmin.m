classdef labeladmin
    % --- OBSOLETE ---
    %labeladmin Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Dependent)
        LabelCount
    end
    
    properties %(Access = private)
        Labels string
    end
    
    methods
        function la = labeladmin(varargin)
            %labeladmin Construct an instance of this class
            %   Detailed explanation goes here
            la.Labels = parse_input('labeladmin:constructor',varargin{:});
        end
        
        function la = AppendLabels(la,varargin)
            %AppendLabels Summary of this method goes here
            %   Detailed explanation goes here
            errid = 'labeladmin:AppendLabels';
            new_labels = parse_input(errid, varargin{:});
            if sum(ismember(new_labels, la.Labels)) > 0
                error([errid, ':check'],'Duplicate labels not allowed.')
            end
            la.Labels = horzcat(la.Labels, new_labels);
        end
        
        function count = get.LabelCount(la)
            count = length(la.Labels); % Calculate dependent property
        end
        
        function idx = LabelIndex(la,varargin)
            errid = 'labeladmin:LabelIndex';
            labels = parse_input(errid, varargin{:});
            [present, idx] = ismember(labels, la.Labels);
            if sum(present) ~= length(labels)
                error(errid, 'One or several specified labels not present.')
            end
        end
        
        function present = LabelCheck(la,varargin)
            errid = 'labeladmin:LabelCheck';
            labels = parse_input(errid, varargin{:});
            present = ismember(labels, la.Labels);
        end
        
    end
end

% Helper functions

function labels = parse_input(errid,varargin)
switch length(varargin)
    case 0
        labels = string([]);
        
    case 1
        siz = size(varargin{1});
        nel = prod(siz);
        
        if length(siz) > 2 || siz(1)~=1 && siz(2)~=1
            % Input should be single column or row
            error([errid, ':parse_input:nargin1'],...
                'Invalid input')
        end
        if isa(varargin{1},'cell')
            nchar = sum(cellfun(@ischar,varargin{1}));
            if nchar ~= nel
                error([errid, ':parse_input:nargin1'],...
                    'Invalid input')
            end
            labels = string(varargin{1}(:)'); % String array (row)
            
        elseif isa(varargin{1},'string')
            labels = varargin{1}(:)';
            
        elseif isa(varargin{1},'char')
            if siz(1) > 1
                error([errid, ':parse_input:nargin1'],...
                    'Invalid input')
            end
            labels = string(varargin{1});
            
        else
            error([errid, ':parse_input:nargin1'],...
                'Invalid input')
        end
        
    otherwise
        % comma separated char or string input
        if isa(varargin{1},'char') && ...
                sum(cellfun(@ischar,varargin))
            labels = string(varargin(:)');
            
        elseif isa(varargin{1},'string') && ...
                sum(cellfun(@isstring,varargin))
            labels = [varargin{:}];
            
        else
            error([errid, ':parse_input:nargin2'],...
                'Invalid input')
        end
end % switch

% Check for duplicates
if length(unique(labels)) < length(labels)
    error([errid, ':parse_input:check'],...
        'Duplicate labels not allowed.')
end

end % parse_input

