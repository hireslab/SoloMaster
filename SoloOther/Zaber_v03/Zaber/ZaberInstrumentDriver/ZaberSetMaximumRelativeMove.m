function [ret err] = ZaberSetMaximumRelativeMove(device, devNr, range)
% SetMaximumRelativeMove - Sets a limit on the number of microsteps the
% device can make for a Relative Move command.
% 
% Use this command to limit the maximum range of travel for a relative move
% command. For example, if maximum relative move is set to 1000, and the
% user requests a relative move (#21) of 800, then the device will move
% 800 microsteps. However, if the user requests a relative move of 1200,
% then the device will reply with an error code. Most applications can 
% leave this unchanged from the default.
% 
% This setting is stored in non-volatile memory and will persist after 
% power-down or reset.
%
% inputs:
% -------
% devNr ... the daisy-chain device number
% range ... maximum relative move in m
% 	
% returns:
% --------
% ret	... maximum relative move in m
% err	... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:SetMaximumRelativeMove:wrongArgument', ...
          'devNr must be numeric and inbetween [1...255]');
end
if ~isnumeric(range)
    error('ZABERInstrumentDriver:SetMaximumRelativeMove:wrongArgument', ...
          'range must be scalar and numeric');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% generate command bytes 3 through 6
data = ZaberPosition2MicroSteps(device, devNr, range);

% send
command = 46;
ZaberSendCommand(device, devNr, command, data);

% receive reply
[data err] = ZaberWaitForReturns(device, devNr, command, false);

% convert microsteps to position in meters
ret = ZaberMicroSteps2Position(device, devNr, data);