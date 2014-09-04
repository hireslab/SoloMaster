function ret = ZaberAcceleration2Data(device, devNr, acceleration)
% Acceleration2Data - Calculates command data bytes from acceleration.
%
% inputs:
% -------
% device		... a Zaber device object
% devNr			... device number, list of device numbers
% acceleration	... acceleration, list of accelerations
%                   or [devNr acceleration] pairs (in m/s^2)
% 
% returns:
% --------
% ret			... [devNr, acceleration command data]
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer)
%--------------------------------------------------------------------------

% if there is only one speed
if (numel(acceleration) == 1)
    data = [devNr(:), repmat(acceleration,numel(devNr),1)];
    
% if there is a speed setting for every device
elseif (numel(devNr) == numel(acceleration))
    data = [devNr(:), acceleration(:)];
    
% if there are multiple devices and [devNr speed] pairs
elseif (numel(devNr) == size(acceleration,1)) && (size(acceleration,2) == 2)
    data = acceleration;
    
% otherwise it is unknown
else
    error('ZABERInstrumentDriver:ZaberAcceleration2Data:unknownFormat', ...
      'unknow format of device number - acceleration pairs');         
end

% get microstep sizes, assume that the first device in a set with the same
% alias has the same setting as the rest
% problem: alias(devNr([3 5])) may correspond to devNr([3 1 2])

% calculate command data
ret = data;
if isscalar(devNr) && (devNr == 0)
    ret = round(data(:,2) ./ (11250 .* device.defaultMicroStepSize));
else
    ret = round(data(:,2) ./ (11250 .* device.microStepSize(cellfun(@(x) x(1), device.aliases(data(:,1))))'));
end
