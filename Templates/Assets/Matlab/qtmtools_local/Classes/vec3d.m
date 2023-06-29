classdef vec3d
    %vec3d 3D vector representation and methods.
    %   All you need for your 3D mocap data
    %   
    %   Partly adapted from (and dependent on):
    %     Mark Tincknell (2020). quaternion
    %     (https://www.mathworks.com/matlabcentral/fileexchange/33341-quaternion),
    %     MATLAB Central File Exchange. Retrieved May 27, 2020.
    
    properties  (SetAccess = protected, Hidden = true)
        e = zeros(3,1);
    end
    
    properties (Dependent = true)
        x
        y
        z
    end
    
    methods
        function p = vec3d(varargin)
            %function p = vec3d(vec)
            %  Construct an instance of this class
            perm = [];
            sqz  = false;
            switch nargin
                
                case 0  % nargin == 0
                    p.e = zeros(3,1);
                    return;
                    
                case 1  % nargin == 1
                    siz = size( varargin{1} );
                    nel = prod( siz );
                    if nel == 0
                        p	= vec3d.empty();
                        return;
                    elseif isa( varargin{1}, 'vec3d' )
                        p   = varargin{1};
                        return;
                    end
                    [arg3, dim3, perm3] = finddim( varargin{1}, 3 );
                    if dim3 > 0
                        siz(dim3)   = 1;
                        nel         = prod( siz );
                        if dim3 > 1
                            perm    = perm3;
                        else
                            sqz     = true;
                        end
                        for iel = nel : -1 : 1
                            p(iel).e = chop( arg3(:,iel) );
                        end
                    else
                        error( 'vec3d:constructor:nargin1', ...
                            'Invalid input' );
                    end
                    
                otherwise
                    error( 'vec3d:constructor:input', ...
                        'Invalid input' );
            end
            
            if nel == 0
                p   = vec3d.empty;
            end
            p   = reshape( p, siz );
            if ~isempty( perm )
                p   = ipermute( p, perm );
            end
            if sqz
                % p   = squeeze( p );
                p = shiftdim(p,1);
            end
        end %vec3d
        
        function x = get.x(p)
            x = p.e(1);
        end
        
        function y = get.y(p)
            y = p.e(2);
        end
        
        function z = get.z(p)
            z = p.e(3);
        end
        
        % Overload standard methods
        function n = abs( p )
            n   = p.norm;
        end % abs
        
        function pd = cdiff( p , dim, h )
            %function pd = cdiff( p, dim, h )
            %  vec3d array difference using central difference algorithm
            %  extrapolation of edges so that same number of elements is
            %  returned
            %  dim defaults to first dimension of length > 1
            %  h is step size (usually 1/sample frequency)
            if isempty( p )
                pd  = p;
                return;
            end
            if (nargin < 2) || isempty( dim )
                [p, dim, perm]  = finddim( p, -2 );
            elseif dim > 1
                ndm  = ndims( p );
                perm = [ dim : ndm, 1 : dim-1 ];
                p    = permute( p, perm );
            end
            if nargin < 3, h = 1; end
            siz = size( p );
            if siz(1) <= 1
                pd  = vec3d.empty;
                return;
            end
            pd  = vec3d.zeros( siz );
            for is = 2 : siz(1)-1
                pd(is,:) = (p(is+1,:) - p(is-1,:))./(2*h);
            end
            pd(1,:) = 3/2.*pd(2,:) - 1/2.*pd(4,:); % 3-point extrapolation of edges
            pd(end,:) = 3/2.*pd(end-1,:) - 1/2.*pd(end-3,:);
            if dim > 1
                pd  = ipermute( pd, perm );
            end
        end % cdiff
        
        function pd = cdiff2( p , dim, h )
            %function pd = cdiff2( p, dim, h )
            %  vec3d array second order difference using central difference algorithm
            %  extrapolation of edges so that same number of elements is
            %  returned
            %  dim defaults to first dimension of length > 1
            if isempty( p )
                pd  = p;
                return;
            end
            if (nargin < 2) || isempty( dim )
                [p, dim, perm]  = finddim( p, -2 );
            elseif dim > 1
                ndm  = ndims( p );
                perm = [ dim : ndm, 1 : dim-1 ];
                p    = permute( p, perm );
            end
            if nargin < 3, h = 1; end
            siz = size( p );
            if siz(1) <= 1
                pd  = vec3d.empty;
                return;
            end
            pd  = vec3d.zeros( siz );
            for is = 2 : siz(1)-1
                pd(is,:) = (p(is+1,:) + p(is-1,:) - 2.*p(is,:))./h^2;
            end
            pd(1,:) = 3/2.*pd(2,:) - 1/2.*pd(4,:); % 3-point extrapolation of edges
            pd(end,:) = 3/2.*pd(end-1,:) - 1/2.*pd(end-3,:);
            if dim > 1
                pd  = ipermute( pd, perm );
            end
        end % cdiff2
        
        function p3 = cross( p1, p2 )
            %function p3 = cross( p1, p2)
            %  Compute cross product of vec3d objects.
            %  One of the inputs can be numerical.
            %  Uses binary singleton expansion.
            [arg1, arg2, siz] = parse_args(p1, p2);
            if siz == 0
                p3  = vec3d.empty();
                return;
            end
            p3 = vec3d(bsxfun( @cross, arg1, arg2));
            p3 = reshape( p3, siz);
        end % cross
        
        function pd = diff( p, ord, dim )
            %function pd = diff( p, ord, dim )
            %  vec3d array difference, ord is the order of difference (default = 1)
            %  dim defaults to first dimension of length > 1
            if isempty( p )
                pd  = p;
                return;
            end
            if (nargin < 2) || isempty( ord )
                ord = 1;
            end
            if ord <= 0
                pd  = p;
                return;
            end
            if (nargin < 3) || isempty( dim )
                [p, dim, perm]  = finddim( p, -2 );
            elseif dim > 1
                ndm  = ndims( p );
                perm = [ dim : ndm, 1 : dim-1 ];
                p    = permute( p, perm );
            end
            siz = size( p );
            if siz(1) <= 1
                pd  = vec3d.empty;
                return;
            end
            pd  = vec3d.zeros( [(siz(1)-1), siz(2:end)] );
            for is = 1 : siz(1)-1
                pd(is,:) = p(is+1,:) - p(is,:);
            end
            ord = ord - 1;
            if ord > 0
                pd  = diff( pd, ord, 1 );
            end
            if dim > 1
                pd  = ipermute( pd, perm );
            end
        end % diff
        
        function d = distance( p1, p2 )
            %function d = distance( p1, p2 )
            %   Calculate distance between p1 and p2.
            %   When p1 and p2 are not the same size calculation uses
            %   binary singleton expansion (for example
            %   distance between array p1 to fixed point p2).
            d = norm( p1 - p2 );
        end
        
        function d = dot( p1, p2 )
            % function d = dot( p1, p2 )
            % vec3d element dot product: d = dot( p1.e, p2.e ), using binary
            % singleton expansion of vec3d arrays
            % dn = dot( p1, p2 )/( norm(p1) * norm(p2) ) is the cosine of the angle in
            % 3D space between 3D vectors p1.e and p2.e
            
            % d   = squeeze( sum( bsxfun( @times, double( p1 ), double( p2 )), 1 ));
            
            % New version (allow for correct formatted numeric input)
            [arg1, arg2, siz] = parse_args(p1, p2);
            if siz == 0
                d  = [];
                return;
            end
            d   = squeeze( sum( bsxfun( @times, arg1, arg2), 1 ));
            d = reshape( d, siz);
        end % dot
        
        function d = double( p )
            siz = size( p );
            d   = reshape( [p.e], [3 siz] );
            d   = chop( d );
        end % double
        
        function l = isnan( p )
            % function l = isnan( p ), l = any( isnan( p.e ))
            d   = [p.e];
            l   = reshape( any( isnan( d ), 1 ), size( p ));
        end % isnan
        
        function pm = mean( p, varargin )
            % function pm = mean( p, dim )
            % vec3d array mean over dimension dim
            % dim defaults to first dimension of length > 1
            % Allows same input arguments as Matlab built-in mean function.
            if isempty( p )
                pm  = p;
                return;
            end
            ndm = ndims(p);
            arg1 = 1; % Index to first input of varargin
            dim = 2; % Default dimension for mean calculation (first dimension of vec3d object)
            if nargin > 1
                if isnumeric(varargin{1})
                    dim = varargin{1} + 1; % Recalculated dim argument
                    arg1 = 2;
                elseif string(varargin{1}) == "all"
                    dim = 2:ndm+1;
                    arg1 = 2;
                end
            end
            pm = vec3d(mean(double(p),dim,varargin{arg1:end}));
            
        end % mean
        
        function p3 = minus( p1, p2 )
            [arg1, arg2, siz] = parse_args(p1, p2);
            if siz == 0
                p3  = vec3d.empty;
                return;
            end
            % d3 = bsxfun( @minus, arg1, arg2 );
            d3 = arg1 - arg2;
            p3 = vec3d(d3);
            p3 = reshape( p3, siz );
        end % minus
        
        function n = norm(p)
            n   = shiftdim( sqrt( sum( double( p ).^2, 1 )), 1 );
        end % norm
        
        function [p, n] = normalize( p )
            % function [p, n] = normalize( p )
            % p = vectors with norm == 1 (unless p == 0), n = former norms
            siz = size( p );
            nel = prod( siz );
            if nel == 0
                if nargout > 1
                    n   = zeros( siz );
                end
                return;
            end
            d   = double( p );
            n   = sqrt( sum( d.^2, 1 ));
            if all( n(:) == 1 )
                if nargout > 1
                    n   = shiftdim( n, 1 );
                end
                return;
            end
            n3  = repmat( n, [3, ones(1,ndims(n)-1)] );
            ne0 = (n3 ~= 0) & (n3 ~= 1);
            d(ne0)  = d(ne0) ./ n3(ne0);
            p   = reshape( vec3d( d ), siz );
            if nargout > 1
                n   = shiftdim( n, 1 );
            end
        end % normalize
        
        function plot( p, varargin )
            %function plot( p, ... )
            %   Plot XYZ data of vec3d array
            plot([p.xData, p.yData, p.zData], varargin{:});
        end
        
        function p3 = plus( p1, p2 )
            [arg1, arg2, siz] = parse_args(p1, p2);
            if siz == 0
                p3  = vec3d.empty;
                return;
            end
            % d3 = bsxfun( @plus, arg1, arg2 );
            d3 = arg1 + arg2;
            p3 = vec3d(d3);
            p3 = reshape( p3, siz );
        end % plus
        
        function pq = power( p, q )
            %function pq = power( p, q )
            %  vec3d power: pq = p.^q
            sip = size( p );
            siq = size( q );
            nep = prod( sip );
            neq = prod( siq );
            if (nep == 0) || (neq == 0)
                pq  = vec3d.empty;
                return;
            elseif ~isequal( sip, siq ) && (nep ~= 1) && (neq ~= 1)
                error( 'vec3d:power:baddims', ...
                    'Matrix dimensions must agree' );
            end
            dq = double(p).^q;
            pq = vec3d(dq);
            pq = reshape( pq, sip );
        end % power
        
        function p3 = rdivide( p1, p2 )
            [arg1, arg2, siz] = parse_args(p1, p2);
            if siz == 0
                p3  = vec3d.empty;
                return;
            end
            d3 = bsxfun( @rdivide, arg1, arg2 );
            p3 = vec3d(d3);
            p3 = reshape( p3, siz );
        end
        
        function pr = rotate_vec3d(p,q)
            %function pr = rotate_vec3d(p,q)
            %   Rotates vector using quaternion.RotateVector
            %   When p and q are not the same size calculation uses binary
            %   singleton expansion (for example rotation of array p
            %   relative to fixed reference).
            
            % Calculate size and expand arrays (no full support for bsx in
            % quaternion.RotateVector)
            [sx, rxp, rxq] = bsx_size(size(p), size(q));
            p = repmat(p, rxp);
            q = repmat(q, rxq);
            
            pr = vec3d(q.RotateVector(double(p))); % Use quaternion.RotateVector
            pr = reshape(pr,sx);
        end
        
        function ps = sign( p )
            % function ps = sign( p )
            % Returns vec3d with sign values (-1, 0, 1) of vec3d elements.
            sp = size(p);
            ps = vec3d(sign(double(p)));
            ps = reshape(ps,sp);
        end % sign
        
        function ps = sum( p, dim )
            % function ps = sum( p, dim )
            % vec3d array sum over dimension dim
            % dim defaults to first dimension of length > 1
            if isempty( p )
                ps  = p;
                return;
            end
            if (nargin < 2) || isempty( dim )
                [p, dim, perm]  = finddim( p, -2 );
            elseif dim > 1
                ndm  = ndims( p );
                perm = [ dim : ndm, 1 : dim-1 ];
                p    = permute( p, perm );
            end
            siz = size( p );
            ps  = reshape( p(1,:), [1 siz(2:end)] );
            for is = 2 : siz(1)
                ps(1,:) = ps(1,:) + p(is,:);
            end
            if dim > 1
                ps  = ipermute( ps, perm );
            end
        end % sum
        
        function pr = sqrt( p )
            pr  = p.^0.5;
        end % sqrt
        
        function p3 = times( p1, p2 )
            [arg1, arg2, siz] = parse_args(p1, p2);
            if siz == 0
                p3  = vec3d.empty;
                return;
            end
            d3 = bsxfun( @times, arg1, arg2 );
            p3 = vec3d(d3);
            p3 = reshape( p3, siz );
        end
        
        function xdata = xData( p, index )
            %function xdata = xData ( p )
            %  Extract X component from array
            if nargin < 2
                xdata = dot(p, vec3d([1 0 0]));
            else
                xdata = dot(p(index), vec3d([1 0 0]));
            end
        end
        
        function ydata = yData( p, index )
            %function ydata = xData ( p )
            %  Extract Y component from array
            if nargin < 2
                ydata = dot(p, vec3d([0 1 0]));
            else
                ydata = dot(p(index), vec3d([0 1 0]));
            end
        end
        
        function zdata = zData( p, index )
            %function zdata = xData ( p )
            %  Extract Z component from array
            if nargin < 2
                zdata = dot(p, vec3d([0 0 1]));
            else
                zdata = dot(p(index), vec3d([0 0 1]));
            end
        end
        
    end %methods
    
    methods(Static)
        
        function p = zeros( varargin )
            % function q = vec3d.zeros( siz )
            if isempty( varargin )
                siz = [1 1];
            elseif numel( varargin ) > 1
                siz = [varargin{:}];
            elseif isempty( varargin{1} )
                siz = [0 0];
            elseif numel( varargin{1} ) > 1
                siz = varargin{1};
            else
                siz = [varargin{1} varargin{1}];
            end
            if prod( siz ) == 0
                p = reshape( vec3d.empty, siz );
            else
                p = vec3d(zeros([3 siz]));
                p = reshape(p,siz);
            end
        end % vec3d.zeros
        
        function p = ones( varargin )
            % function q = vec3d.ones( siz )
            if isempty( varargin )
                siz = [1 1];
            elseif numel( varargin ) > 1
                siz = [varargin{:}];
            elseif isempty( varargin{1} )
                siz = [0 0];
            elseif numel( varargin{1} ) > 1
                siz = varargin{1};
            else
                siz = [varargin{1} varargin{1}];
            end
            if prod( siz ) == 0
                p = reshape( vec3d.empty, siz );
            else
                p = vec3d(ones([3 siz]));
                p = reshape(p,siz);
            end
        end % vec3d.ones
        
        function p = nan( varargin )
            % function q = vec3d.nan( siz )
            if isempty( varargin )
                siz = [1 1];
            elseif numel( varargin ) > 1
                siz = [varargin{:}];
            elseif isempty( varargin{1} )
                siz = [0 0];
            elseif numel( varargin{1} ) > 1
                siz = varargin{1};
            else
                siz = [varargin{1} varargin{1}];
            end
            if prod( siz ) == 0
                p = reshape( vec3d.empty, siz );
            else
                p = vec3d(nan([3 siz]));
                p = reshape(p,siz);
            end
        end % vec3d.nan
        
    end % methods(Static)
end % class def vec3d

% Helper functions
function out = chop( in, tol )
%function out = chop( in, tol )
% Replace values that differ from an integer by <= tol by the integer
% Inputs:
%  in       input array
%  tol      tolerance, default = eps(16)
% Output:
%  out      input array with integer replacements, if any
if (nargin < 2) || isempty( tol )
    tol = eps(16);
end
out = double( in );
rin = round( in );
lx  = abs( rin - in ) <= tol;
out(lx) = rin(lx);
end % chop

function [aout, dim, perm] = finddim( ain, len )
%function [aout, dim, perm] = finddim( ain, len )
% Find first dimension in ain of length len, permute ain to make it first
% Inputs:
%  ain(s1,s2,...)   data array, size = [s1, s2, ...]
%  len              length sought, e.g. s2 == len
%                   if len < 0, then find first dimension >= |len|
% Outputs:
%  aout(s2,...,s1)  data array, permuted so first dimension is length len
%  dim              dimension number of length len, 0 if ain has none
%  perm             permutation order (for permute and ipermute) of aout,
%                   e.g. [2, ..., 1]
% Notes: if no dimension has length len, aout = ain, dim = 0, perm = 1:ndm
%        ain = ipermute( aout, perm )
siz  = size( ain );
ndm  = length( siz );
if len < 0
    dim  = find( siz >= -len, 1, 'first' );
else
    dim  = find( siz == len, 1, 'first' );
end
if isempty( dim )
    dim  = 0;
end
if dim < 2
    aout = ain;
    perm = 1 : ndm;
else
% Permute so that dim becomes the first dimension
    perm = [ dim : ndm, 1 : dim-1 ];
    aout = permute( ain, perm );
end
end % finddim

function [arg1,arg2,siz]=parse_args(p1,p2)
% Parse arguments for plus, minus and other functions that take two inputs.
% One of the inputs can be numeric. In that case the format can be:
% - a scalar
% - a single column or row with 3 elements (3d vector)
% - a multidimensional array with size [3, size of the vec3d input]
% Calling function should use bsxfun for binary singleton expansion.
% 
% Note: Not tested for numeric arrays with more than 2 dimensions.

% Development note: redo logic making better use of bsx_size
% Define use cases / limitations for operations
% Meaningful use of numeric input, e.g. scalars for
% multiplication/division, vectors for addition/subtraction
% This may require separate parse functions

si1 = size( p1 );
si2 = size( p2 );
ne1 = prod( si1 );
ne2 = prod( si2 );
if (ne1 == 0) || (ne2 == 0)
    arg1 = []; arg2 = []; siz = 0;
    return
elseif ne1 == 1
    siz = si2;
elseif ne2 == 1
    siz = si1;
elseif isequal( si1, si2 )
    siz = si1;
elseif isa(p1,'vec3d') && isa(p2,'vec3d') && ismember(1,[si1, si2]) % To allow for binary singleton expansion of vec3d input
    % bsx_size could be used in a smarter way, since it could also cover
    % some of the previous conditions.
    siz = bsx_size(si1, si2);
elseif isnumeric(p1) % Allow for numeric vector input p2 (e.g. [x y z])
    % p1 as numeric scalar already covered with previous conditions
    if ne1 == 3 % single vector
        siz = si2;
        if si1(1) ~= 3
            p1 = p1.';
        end
    elseif ne1 == 3*ne2 && si1(1) == 3 % si1: [3, si2]
        siz = si2;
    else
        error( 'vec3d:parse_args:baddims', ...
        'Invalid numeric input' )
    end
elseif isnumeric(p2) % Allow for numeric vector input p2 (e.g. [x y z])
    % p2 as numeric scalar already covered with previous conditions
    if ne2 == 3 % single vector
        siz = si1;
        if si2(1) ~= 3
            p2 = p2.';
        end
    elseif ne2 == 3*ne1 && si2(1) == 3 % si2: [3, si1]
        siz = si1;
    else
        error( 'vec3d:parse_args:baddims', ...
        'Invalid numeric input' )
    end
else
    error( 'vec3d:parse_args:baddims', ...
        'Matrix dimensions must agree' );
end
if isa(p1,'vec3d')
    % arg1 = [p1.e];
    arg1 = double(p1);
elseif isnumeric(p1)
    arg1 = p1;
end
if isa(p2,'vec3d')
    % arg2 = [p2.e];
    arg2 = double(p2);
elseif isnumeric(p2)
    arg2 = p2;
end
end
