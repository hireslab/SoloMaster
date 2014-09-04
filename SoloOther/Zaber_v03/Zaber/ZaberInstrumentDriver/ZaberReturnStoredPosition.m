function [ret err] = ZaberReturnStoredPosition(device, devNr, address)
% ReturnStoredPosition - Returns the position stored in one of the 16 position registers for the
% position registers for the device.
% 
% Valid command data values are 0 through 15, specifying one of 16 possible
% registers from which to retrieve the position. This command is used in
% conjunction with the Store Current Position (#16) and
% Move To Stored Position (#18) commands. Positions stored in the position
% registers are non-volatile and will persist after power-down or reset.
% All position registers are cleared by the Restore Settings (#36) command.
% 
% inputs:
% -------
% devNr		... the daisy-chain device number
% address	... address (0-15) to store the current position
% 
% returns:
% --------
% ret		... stored position in m
% err		... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:ReturnStoredPosition:wrongArgument', ...
          'devNr must be numeric and inbetween [0...255]');
end
if ~(isnumeric(address) && all(address >= 0) && all(address <= 15))
    error('ZABERInstrumentDriver:ReturnStoredPosition:wrongArgument', ...
          'address must be numeric and inbetween [0..15]');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% Generate additional command byte 3
data = bitand(address, 255);

% Send data
command = 17;
ZaberSendCommand(device, devNr, command, data);

% wait while moving
[data err] = ZaberWaitForReturns(device, devNr, command, false);

% convert microsteps to position in meters
ret = ZaberMicroSteps2Position(device, devNr, data);