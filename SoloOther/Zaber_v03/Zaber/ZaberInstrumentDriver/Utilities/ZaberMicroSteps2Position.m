function ret = ZaberMicroSteps2Position(device, devNr, cmdData)
% MicroSteps2Position - Convert a number of microsteps to a corresponding
% distance in meters.
% 
%
% inputs:
% -------
% device	... Zaber device object
% devNr		... single device number or a list of numbers
% cmdData	... position in microsteps, a list of positions or a
%				list of [devNr, position in microsteps; ...] pairs
%				
% 
% returns:
% --------
% ret		... [devNr, position in m]
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
    
% if there are multiple devices and [devNr data] pairs
elseif (numel(aliasNr) == size(cmdData,1)) && (size(cmdData,2) == 2)
    data = cmdData;

% devNr 0 corresponds to all devices, assume devNr contains [devNr data] pairs
elseif (size(cmdData,1) == device.nrOfDevices) && (size(cmdData,2) == 2)
    data = cmdData;
    
% otherwise it is unknown
else
    error('ZABERInstrumentDriver:ZaberMicroSteps2Position:unknownFormat', ...
      'unknow format of device number - data pairs');         
end

% get microstep sizes, assume that the first device in a set with the same
% alias has the same setting as the rest
% problem: alias(devNr([3 5])) may correspond to devNr([3 1 2])

% calculate position
ret = data;
ret(:,2) = double(data(:,2)) .* device.microStepSize(cellfun(@(x) x(1), device.aliases(data(:,1))))';