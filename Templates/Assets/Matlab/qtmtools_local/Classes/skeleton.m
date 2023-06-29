classdef skeleton < labeladmin2
    %skeleton Skeleton representation and methods for working with Qualisys
    %   skeletons.
    
    %   Further expand help info
    
    properties
        Segments segment
    end
    
    methods
        % Create skeleton object from QTM skeleton structure
        function skel = skeleton(qsk, frame_sel)
            %skeleton Construct an instance of this class
            %   Detailed explanation goes here
            %   Input: QTM skeleton structure (single skeleton)
            if nargin < 1
                lab = "";
                N_segm = 0;
            else
                lab = qsk.SkeletonName;
                N_segm = qsk.NrOfSegments;
            end
            
            skel@labeladmin2(lab); % Does not work with the empty return statment above
            for k=N_segm:-1:1 % In reverse order for allocation
                lab = qsk.SegmentLabels{k};
                if nargin < 2
                    pos = qsk.PositionData(:,k,:);
                    qrot = qsk.RotationData(:,k,:);
                else
                    pos = qsk.PositionData(:,k,frame_sel);
                    qrot = qsk.RotationData(:,k,frame_sel);
                end
                
                % segment_index = k;
                skel.Segments(k) = segment(pos,qrot,lab);
            end
        end % constructor
        
    end % methods
    
    methods (Hidden)
        
        function n_out = numArgumentsFromSubscript(skel,s,~)
            % Overloading for calculating correct number of output
            % arguments for subsref, including nested reference structures
            
            errid = 'skeleton:numArgumentsFromSubscript';
            n_out = numel(skel); % Default: total number of elements in array
            m_out = 1;
            
            switch s(1).type
                case '.'
                    if numel(s) > 1 && strcmp('Segments',s(1).subs)
                        segm = skel(1).Segments;
                        m_out = numArgumentsFromSubscript(segm,s(2:end));
                    end
                case '()'
                    s1val = s(1).subs{1}; % Use first index value for test
                    if ischar(s1val) || isstring(s1val) || iscell(s1val) && ~contains(':',s1val) % Check first index value
                        LabelList = [skel.Label];
                        labels = parse_labels(errid, s(1).subs{:});
                        [~, skel_idx] = ismember(labels, LabelList);
                        
                        n_out = length(skel_idx);
                    else
                        n_out = length([s(1).subs{:}]);
                    end
                    if numel(s) > 2  && strcmp('Segments',s(2).subs)
                        segm = skel(1).Segments;
                        m_out = numArgumentsFromSubscript(segm,s(3:end));
                    end
            end
            n_out = n_out * m_out;
        end
        
        function varargout = subsref(skel,s)
            % Overloading of subsref for skeleton class to deal with
            % segments in skeletons
            
            % Some ideas
            % Define what is allowed and what not and deal with it in an
            % appropriate way. May be complicated to determine the number
            % of output arguments.
            % For example, only possible to return output of multiple
            % segments for a single skeleton or output of similar segment
            % for multiple skeletons. Question is how useful this is, so
            % maybe better to set clear limits.
            
            % errid = 'skeleton:subsref';
            switch s(1).type
                case '.'
                    if numel(s) > 1 && strcmp('Segments',s(1).subs) % Deal with segments in skeletons
                        i_out = 0;
                        for k = numel(skel):-1:1
                            segm = skel(k).Segments;
                            m_out = numArgumentsFromSubscript(segm,s(2:end));
                            
                            [varargout{(1:m_out)+i_out}] = subsref(segm,s(2:end));
                            i_out = i_out + m_out;
                        end
                    else
                        [varargout{1:nargout}] = subsref@labeladmin2(skel,s); % builtin('subsref',skel,s); %
                    end
                    
                case '()'
                    if numel(s) > 1  && strcmp('Segments',s(2).subs) % Deal with segments in skeletons
                        if numel(s) > 2
                            skel_sub=subsref@labeladmin2(skel,s(1));
                            i_out = 0;
                            for k = numel(skel_sub):-1:1
                                segm = skel_sub(k).Segments;
                                m_out = numArgumentsFromSubscript(segm,s(3:end));
                                
                                [varargout{(1:m_out)+i_out}] = subsref(segm,s(3:end));
                                i_out = i_out + m_out;
                            end
                        else
                            [varargout{1:nargout}] = subsref@labeladmin2(skel,s); % builtin('subsref',skel,s); %
                        end
                    else
                        [varargout{1:nargout}] = subsref@labeladmin2(skel,s); % builtin('subsref',skel,s); %
                    end
                    
                otherwise
                    [varargout{1:nargout}] = builtin('subsref',skel,s);
                    
            end
        end % subsref
        
    end % hidden methods
    
end
