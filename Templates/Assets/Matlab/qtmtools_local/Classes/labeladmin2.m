classdef labeladmin2
    %labeladmin2 Label object for naming and subreferencing subclass
    %   objects
    %   Use a superclass for objects to give them a label and be able to
    %   use it as a subreference for object arrays.
    
    properties
        Label string
    end
    
    methods
        function la = labeladmin2(lab)
            %labeladmin2 Construct an instance of this class
            %   Detailed explanation goes here
            
            if nargin < 1
                return; % return with default (empty) data
            end
            
            labstr = string(lab); % Convert to string
            
            % Input check (accepts all input, except input that converts to a string array)
            errid = 'labeladmin2:constructor';
            if numel(labstr) > 1
                error(errid,'Invalid input')
            end
            
            la.Label = labstr;
        end
        
        function idx = LabelIndex(obj,varargin)
            errid = 'labeladmin:LabelIndex';
            labels = parse_labels(errid, varargin{:});
            [present, idx] = ismember(labels, [obj.Label]);
            if sum(present) ~= length(labels)
                error(errid, 'One or several specified labels not present.')
            end
        end
        
        function present = LabelCheck(obj,varargin)
            errid = 'labeladmin:LabelCheck';
            labels = parse_labels(errid, varargin{:});
            present = ismember(labels, [obj.Label]);
        end

        function list = LabelList(obj)
            list = [obj.Label];
        end
        
    end % methods
    
    methods (Hidden)

        function n_out = numArgumentsFromSubscript(obj,s,~)
            % Overloading for calculating correct number of output
            % arguments for subsref
            
            errid = 'labeladmin:numArgumentsFromSubscript';
            n_out = numel(obj); % Default: total number of elements in array
            
            switch s(1).type
                case '.'
                    if strcmp(s(1).subs,'LabelList') % Make it work for LabelList method
                        n_out = 1;
                    end
                case '()'
                    s1val = s(1).subs{1}; % Use first index value for test
                    if ischar(s1val) || isstring(s1val) || iscell(s1val) && ~contains(':',s1val) % Check first index value
                        LabelList = [obj.Label];
                        labels = parse_labels(errid, s(1).subs{:});
                        [~, obj_idx] = ismember(labels, LabelList);
                        
                        n_out = length(obj_idx);
                    else
                        n_out = length([s(1).subs{:}]);
                    end
            end
            
        end
        
        function varargout = subsref(obj,s)
            % Overloading of subsref
            % Allow for using labels for subscripting of labeled objects
            
            % Adapted from example in doc "Code Patterns for subsref and subsasgn Methods"
            
            % To do (not urgent): fix subref types like "rb_array.Position(1)" (works for rb_array.Position, or rb_array(1).Position(1))
            
            errid = 'labeladmin:subsref';
            switch s(1).type
                case '.'
                        [varargout{1:nargout}] = builtin('subsref',obj,s);
                case '()'
                    s1val = s(1).subs{1}; % Use first index value for test
                    if ischar(s1val) || isstring(s1val) || iscell(s1val) && ~contains(':',s1val) % Check first index value
                        lablist = [obj.Label];
                        labs = parse_labels(errid, s(1).subs{:});
                        [present, obj_idx] = ismember(labs, lablist);
                        
                        if sum(present) ~= length(labs)
                            error(errid, 'One or several specified labels not present.')
                        else
                            s(1).subs = {obj_idx};
                        end
                    end
                    [varargout{1:nargout}] = builtin('subsref',obj,s);
                    
                otherwise
                    error(errid,'Not a valid indexing expression')
            end
        end % subsref
        
    end % hidden methods
end
