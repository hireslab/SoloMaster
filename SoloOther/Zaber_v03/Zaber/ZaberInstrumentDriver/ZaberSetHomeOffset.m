function [ret err] = ZaberSetHomeOffset(device, devNr, offset)
% SetHomeOffset - Sets the the new "Home" position which can then be used
% when the Home command is issued.
% 
% When the home command is issued, the device will retract until the home
% sensor is triggered, then move forward until the home sensor is no longer
% triggered, then move forward by the Home Offset value (in microsteps)
% and call this position 0.
% 
% Note that the home offset command also changes the range settings of
% the device. For example, if the initial Home Offset is 0 and the Maximum
% Position is 500,000, and the user changes the Home Offset to 70,000, then
% the Maximum Position is automatically adjusted to be 430,000. However,
% changing the range does not affect the home offset.
% 
% When a new Home Offset is specified, Maximum Position is adjusted to
% provide the same maximum location. However, the device will not be able
% to travel below 0 position unless it is homing.
% 
% This setting is stored in non-volatile memory and will persist after
% power-down or reset. 
%
% inputs:
% -------
% devNr  ... the daisy-chain device number
% offset ... homing offset in m
%
% returns:
% --------
% ret	... homing offset in m
% err	... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:SetHomeOffset:wrongArgument', ...
          'devNr must be numeric and inbetween [1...255]');
end
if ~(isnumeric(offset))
    error('ZABERInstrumentDriver:SetHomeOffset:wrongArgument', ...
          'newposition must be numeric');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% generate command bytes 3 through 6
data = ZaberPosition2MicroSteps(device, devNr, offset);

% send
command = 47;
ZaberSendCommand(device, devNr, command, data);

% receive reply
[data err] = ZaberWaitForReturns(device, devNr, command, false);

% convert microsteps to position in meters
ret = ZaberMicroSteps2Position(device, devNr, data);