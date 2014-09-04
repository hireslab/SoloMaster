function [ret err] = ZaberSetCurrentPosition(device, devNr, newposition)
% SetCurrentPosition - Sets the device internal position counter.
% 
% This command override the internal position counter with a new position
% value specified by the user.
% 
% The position data is volatile and will not persist after power-down or
% reset.
% 
% The phase of the stepper motor is controlled by the least significant
% byte of the position, thus the device may move by +/- 2 full steps unless
% the new position corresponds to the true current position of the device.
% This command is useful if you want to turn off the system without losing
% position. Simply save the position in the controlling computer and turn
% off the hold current (Command 39) before powering down. After powering up,
% set the position back to the saved value and turn on the hold current.
% In this way you can continue without having to home the device. You have
% to turn off the hold current because when the power first comes on the
% position will default to the maximum range, and that may be out of phase
% with the motor's current position. If the hold current is on, it will
% force the motor into phase with the default position before you've had a
% chance to restore the current position.
% 
% In Firmware 5.21 and 5.22, the new Current Position must be equal or less
% than Maximum Position. See Set Maximum Position (Cmd 44) for more details
% on range settings and behaviour. 
%
% inputs:
% -------
% devNr       ... the daisy-chain device number
% newposition ... the new position in mm
%
% returns:
% --------
% ret	... newposition in m
% err	... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:SetCurrentPosition:wrongArgument', ...
          'devNr must be numeric and inbetween [1...255]');
end
if ~(isnumeric(newposition))
    error('ZABERInstrumentDriver:SetCurrentPosition:wrongArgument', ...
          'newposition must be numeric');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% generate command bytes 3 through 6
data = ZaberPosition2MicroSteps(device, devNr, newposition);

% send
command = 45;
ZaberSendCommand(device, devNr, command, data);

% receive reply
[data err] = ZaberWaitForReturns(device, devNr, command, false);

% convert microsteps to position in meters
ret = ZaberMicroSteps2Position(device, devNr, data);