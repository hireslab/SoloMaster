function [ret err] = ZaberSetMaximumPosition(device, devNr, range)
% SetMaximumPosition - Sets the maximum position the device is allowed to
% travel to. 
% 
% Use this command to limit the range of travel to a value other than the
% default. Exercise caution when using this command, since it is possible
% to set the range to a value greater than the physical limits of the
% device.
% 
% A device within range of travel is not allowed to move above its Maximum
% Position. Valid values can be any number from 0 to 16777215.
% 
% The behaviour of this command depends on the firmware version:
% 5.01 - 5.20:
% Device movement behaviour when out of range is not well-defined.
% 
% 5.21 - 5.22:
% The new Maximum Position cannot be less than the current position.
% 
% 5.23 and up
% If the device Current Position is out of range and above Maximum Position,
% the device is not allowed to move in the positive direction.
% 
% This setting is stored in non-volatile memory and will persist after
% power-down or reset.
% 
% NOTE: This command was previously named Set Maximum Range. 
%
% inputs:
% -------
% devNr ... the daisy-chain device number
% range ... maximum range in m
% 	
% returns:
% --------
% ret	... maximum range in m
% err	... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:SetMaximumPosition:wrongArgument', ...
          'devNr must be numeric and inbetween [1...255]');
end
if ~isnumeric(range)
    error('ZABERInstrumentDriver:SetMaximumPosition:wrongArgument', ...
          'range must be numeric');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% generate command bytes 3 through 6
data = ZaberPosition2MicroSteps(device, devNr, range);
if ~(all(data >= 0) && all(data <= 16777215))
    error('ZABERInstrumentDriver:SetMaximumPosition:RangeExeeded', ...
          'range is not inbetween [0..16777215], maybe your range (in mm) is too large');
end

% send
command = 44;
ZaberSendCommand(device, devNr, command, data);

% receive reply
[data err] = ZaberWaitForReturns(device, devNr, command, false);

% convert microsteps to position in meters
ret = ZaberMicroSteps2Position(device, devNr, data);