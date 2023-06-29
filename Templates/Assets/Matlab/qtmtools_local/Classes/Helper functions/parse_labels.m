function labels = parse_labels(errid,varargin)
% Function for parsing label input (several formats)
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

end % parse_labels

