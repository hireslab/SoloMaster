function ret = ZaberSpeed2Data(device, devNr, speed)
% Speed2Data - Calculate command data representing the given speed.
%
% inputs:
% -------
% device	... a Zaber device object
% devNr		... device number
% speed		... speed, list of speeds or [devNr speed] pairs
%               (in m/s)
%
% returns:
% --------
% ret		... [devNr, speed command data]
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer)
%--------------------------------------------------------------------------
    
% if there is only one speed
if (numel(speed) == 1)
    data = [devNr(:), repmat(speed,numel(devNr),1)];
    
% if there is a speed setting for every device
elseif (numel(devNr) == numel(speed))
    data = [devNr(:), speed(:)];
    
% if there are multiple devices and [devNr speed] pairs
elseif (numel(devNr) == size(speed,1)) && (size(speed,2) == 2)
    data = speed;
    
% otherwise it is unknown
else
    error('ZABERInstrumentDriver:ZaberSpeed2Data:unknownFormat', ...
      'unknow format of device number - speed pairs');         
end

% get microstep sizes, assume that the first device in a set with the same
% alias has the same setting as the rest
% problem: alias(devNr([3 5])) may correspond to devNr([3 1 2])

% calculate command data
ret = data;
if isscalar(devNr) && (devNr == 0)
    ret = round(data(:,2) ./ (9.375 .* device.defaultMicroStepSize));
else
    ret = round(data(:,2) ./ (9.375 .* device.microStepSize(cellfun(@(x) x(1), device.aliases(data(:,1))))'));
end