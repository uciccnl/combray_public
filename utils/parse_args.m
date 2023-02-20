function varargout = parse_args(args, varargin)
% Usage: [val1 ... valN [rest]] = parse_args(varargin, 'opt1', [def1], ..., 'optN', [defN])
% Determines values for optional arguments, and returns the remaining unparsed arguments.
% Arguments may be specified as name, value pairs or just values in order if they are not strings.
% The val list and/or the opt list may be structures instead:
% Usage: [valstruct [rest]] = parse_args(varargin, optstruct)

% first parse our arguments
i = 1;
names = {};
vals = {};
while i < nargin
    name = varargin{i};
    i = i+1;
    if isstruct(name) && isscalar(name)
        names = [names fieldnames(name)'];
        vals = [vals struct2cell(name)'];
        continue;
    end
    assert(ischar(name));
    if i < nargin && ~ischar(varargin{i})
        def = varargin{i};
        i = i+1;
    else
        def = [];
    end
    names{end+1} = name;
    vals{end+1} = def;
end
set = false(size(names));

% then parse their arguments
v = 0;
i = 1;
while i <= length(args)
    a = args{i};
    if isstruct(a) && isscalar(a)
        f = fieldnames(a);
        if isempty(setdiff(f, names))
            i = i+1;
            [f fi vi] = intersect(f, names);
            fv = struct2cell(a);
            [vals{vi}] = fv{fi};
            set(vi) = 1;
            continue;
        end
    end
    if ~ischar(a)
        if v < length(names) && ~set(v+1)
            v = v+1;
            i = i+1;
            vals{v} = a;
            set(v) = 1;
            continue;
        end
        break;
    end
    v = strcmp(a, names);
    if ~any(v)
        break;
    end
    i = i+1;
    v = find(v);
    if ~all(set(v))
        v = v(~set(v));
    end
    v = v(1);
    if i <= length(args) && ~(ischar(args{i}) && any(strcmp(args{i}, names)))
        vals{v} = args{i};
        i = i+1;
    else
        vals{v} = true;
    end
    set(v) = 1;
end
args = {args{i:end}};

% and return
if nargout < [3 length(vals)]
    vals = {cell2struct(vals, names, 2)};
end
varargout = vals;
if nargout > length(vals)
    varargout{end+1} = args;
elseif ~isempty(args)
    caller = dbstack(1);
    if isempty(caller)
        caller = '<cmdline>';
    else
        caller = sprintf('%s [%s:%d]', caller(1).name, caller(1).file, caller(1).line);
    end
    warning('MATLAB:maxrhs', 'Unhandled arguments to %s:', caller);
    args{:}
end
