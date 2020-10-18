function reflections = calc_parametric_rir(roomDim, sourcePos, arrayPos, ...
    R, varargin)
% calc_parametric_rir returns a table containing a parametric
% representation of shoe box room impulse responde, using the image method.
% The source is assumed to be omni-directional.
%
% Inputs:
%   roomDim         Dimensions of the room, meters. [Lx, Ly, Lz].
%   sourcePos       The location of the source inside the room, meters.
%                   [x, y, z].
%   arraPos         The location of the array inside the room, meters.
%                   [x, y, z].
%   R               Walls reflection coeffecients. Either a scalar, or a
%                   6-vector so that each wall has a different coeffecient.
%                   [x=0, y=0, z=0, x=Lx, y=Ly, z=Lz]
% Name-Value pairs:
%   Tmax            The maximal delay.
%                   Default value is inf
%   AmpThresh       Any reflection whos amplitude is lower then the
%                   amplitude of the direct*AmpThresh, will be discarded.
%                   Default is 1e-4.
%   MaxReflectionOrder Reflections are calculated only up to this order.
%                   Can be either a scalar, or a 3 elements row vector
%                   (x,y,z).
%                   Default is 200 (this is very large usually).
%                   Too large value might lead to memmory issues.
%   EnergyThresh    If positive, than the late part of the response will be
%                   removed. The energy of that part is approximately
%                   EnergyThresh time the total energy.
%                   Default if 0 (so nothing is removed).
%   MaxWaves        The maximum number of waves in the response. If the
%                   number of waves is larger, then late reflections will
%                   be removed.
%                   Default is inf.
%   c               Speed of sound, in m/sec.
%                   Default is the output of the function soundspeed().
%   ZeroFirstDelay  Boolean. If true, the delays are shifted so that the
%                   first is 0.
%                   Default is false.
%
%   Output:
%       reflections A table, where each row represents a single point
%       source (reflection). The columns are:
%           delay           Delay, sec
%           amp             Amplitude (including radial decay)
%           relativePos     Relative position of point sorce, relative to the
%                           array, meters [x, y, z]
%           r               Distance of the point source from the array,
%                           meters.
%           omega           The direction of the point source, relative to
%                           the array, radians [theta, phi].
%           index           A 3-vector describing the "path" of the reflection.
%                           For example, [0 0 0] is the direct sound.
%                           [1 0 0] is the first reflection from x=Lx.
%                           [-1 0 0] is the first reflection from x=0.
%                           [2 0 0] is the relfection of [-1 0 0] from
%                           x=Lx.

%% input validation and defaults
zeroFirstDelay = false;
maxWaves = inf;
energyThresh = 0;
maxReflectionOrder = 200;
c = soundspeed();
Tmax = inf;
ampThresh = 1e-4;
angleDependence = true;
for i=1:2:length(varargin)
    name = varargin{i};
    val = varargin{i+1};
    switch lower(name)
        case 'tmax'
            Tmax = val;
        case {'energythresh','energythreshold'}
            energyThresh = val;
        case {'amplitudethresh', 'amplitudethreshold', 'ampthresh'}
            ampThresh = val;
        case 'zerofirstdelay'
            zeroFirstDelay = val;
        case 'maxwaves'
            maxWaves = val;
        case {"maxreflectionsorder","maxorder"}
            maxReflectionOrder = val;
        case 'c'
            c = val;
        case 'angledependence'
            angleDependence = val;
        otherwise
            error('unknown parameter %s', name);
    end
end
assert(isvector(sourcePos) && length(sourcePos)==3, 'sourcePos must be a 3-vector');
sourcePos = sourcePos(:)';
assert(isvector(arrayPos)  && length(arrayPos) ==3, 'arrayPos must be a 3-vector');
arrayPos = arrayPos(:)';
if isscalar(R)
    R = repmat(R,6,1);
elseif length(R)==3
    R = [R(:); R(:)];
end
if isscalar(maxReflectionOrder)
    maxReflectionOrder = repmat(maxReflectionOrder,1,3);
end
maxReflectionOrder_by_Tmax = ceil(Tmax*c./roomDim)+1;
maxReflectionOrder_by_ampThresh = inf(1,3);
if ~isempty(ampThresh)
    ampThresh = ampThresh / norm( sourcePos-arrayPos );
    L_diag = norm(roomDim);
    R_geomean = sqrt(R(1:3).*R(4:6));
    for i=1:3
        if R_geomean(i)==0
            maxReflectionOrder_by_ampThresh(i) = 1;
        else
            a = @(n) R_geomean(i).^n ./ (n.*roomDim(i) + L_diag) - ampThresh;
            int = [0 log(ampThresh)/log(R_geomean(i))];
            maxReflectionOrder_by_ampThresh(i) = ceil( fzero( a, int, struct("TolX", 0.5) )/2 )*2;
        end
    end
end

maxReflectionOrder = min([maxReflectionOrder; maxReflectionOrder_by_ampThresh; maxReflectionOrder_by_Tmax], [], 1);

%% calculate all parametric data except amplitudes
reflections = table();
[reflectionsPos, reflections.hits] = image_method.calc_reflections_info(roomDim, sourcePos, R, maxReflectionOrder);
reflections.relativePos = reflectionsPos - arrayPos;
reflections.r = vecnorm(reflections.relativePos,2,2);
reflections.delay = reflections.r/c;

%% filter by Tmax
I = reflections.delay<=Tmax;
reflections = reflections(I,:);

%% calculate amplitudes (comes after Tmax filtering for better performance)
reflections.amp = image_method.calc_reflection_amp(reflections.relativePos, reflections.hits, (R+1)./(1-R), angleDependence, reflections.r);

%% filter by ampThresh
I = abs(reflections.amp) >= ampThresh;
reflections = reflections(I,:);

%% sort by delay
reflections = sortrows(reflections, 'delay');

%% filter by energyThresh
if energyThresh>0
    accumulated_energy = cumsum(abssq(reflections.amp));
    k = find( accumulated_energy > (1-energyThresh)*accumulated_energy(end), 1 );
    if ~isempty(k)
        reflections(k+1:end,:) = [];
    end
end

%% filter by max waves
reflections(maxWaves+1:end,:) = [];

%% zero first delay
if zeroFirstDelay
    reflections.delay = reflections.delay - reflections.delay(1);
end

%% calculate omega
[reflections.omega(:,1), reflections.omega(:,2)] = c2s(reflections.relativePos);

end

