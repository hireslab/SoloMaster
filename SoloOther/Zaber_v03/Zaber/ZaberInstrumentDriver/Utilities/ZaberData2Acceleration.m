function ret = ZaberData2Acceleration(device, devNr, cmdData)
% Data2Acceleration - Calculates the acceleration from returned data.
%
% inputs:
% -------
% device	... a Zaber device object
% devNr		... device number
% cmdData	... acceleration command data, list of command data
%               or [devNr cmdData] pairs
% 
% returns:
% --------
% ret		... acceleration in m/s^2,
%				a matrix of device numbers and speeds
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer)
%--------------------------------------------------------------------------

% there may be more aliases than device numbers
if isscalar(devNr) && (devNr == 0)
    aliasNr = devNr;
else
    aliasNr = cell2mat(device.aliases(devNr));
end

% if there is only one speed
if (numel(cmdData) == 1)
    data = [aliasNr(:), repmat(cmdData,numel(aliasNr),1)];
    
% if there is a speed setting for every device
elseif (numel(aliasNr) == numel(cmdData))
    data = [aliasNr(:), cmdData(:)];
    
% if there are multiple devices and [devNr speed] pairs
elseif (numel(aliasNr) == size(cmdData,1)) && (size(cmdData,2) == 2)
    data = cmdData;

% devNr 0 corresponds to all devices, assume devNr contains [devNr data] pairs
elseif (size(cmdData,1) == device.nrOfDevices) && (size(cmdData,2) == 2)
    data = cmdData;
    
% otherwise it is unknown
else
    error('ZABERInstrumentDriver:ZaberData2Acceleration:unknownFormat', ...
      'unknow format of device number - data pairs');         
end

% get microstep sizes, assume that the first device in a set with the same
% alias has the same setting as the rest
% problem: alias(devNr([3 5])) may correspond to devNr([3 1 2])

% calculate acceleration
ret = data;
ret(:,2) = data(:,2) .* 11250 .* device.microStepSize(cellfun(@(x) x(1), device.aliases(data(:,1))))';
