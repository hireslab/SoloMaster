function ret = ZaberPosition2MicroSteps(device, devNr, position)
% Position2MicroSteps - Calculates the number of microsteps which
% represents the given position.
%
% inputs:
% -------
% device	... a Zaber device object
% devNr		... device number
% position	... position, list of positions or [devNr position] pairs
%               (in m)
% 
% returns:
% --------
% ret		... [devNr, position in microsteps]
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer)
%--------------------------------------------------------------------------

% if there is only one speed
if (numel(position) == 1)
    data = [devNr(:), repmat(position,numel(devNr),1)];
    
% if there is a speed setting for every device
elseif (numel(devNr) == numel(position))
    data = [devNr(:), position(:)];
    
% if there are multiple devices and [devNr speed] pairs
elseif (numel(devNr) == size(position,1)) && (size(position,2) == 2)
    data = position;
    
% otherwise it is unknown
else
    error('ZABERInstrumentDriver:ZaberPosition2MicroSteps:unknownFormat', ...
      'unknow format of device number - position pairs');         
end

% get microstep sizes, assume that the first device in a set with the same
% alias has the same setting as the rest
% problem: alias(devNr([3 5])) may correspond to devNr([3 1 2])

% calculate command data
ret = data;
if isscalar(devNr) && (devNr == 0)
    ret = round(data(:,2) ./ device.defaultMicroStepSize);
else
    ret = round(data(:,2) ./ device.microStepSize(cellfun(@(x) x(1), device.aliases(data(:,1))))');
end
ret(ret < 0) = ret(ret < 0) + 2^32;