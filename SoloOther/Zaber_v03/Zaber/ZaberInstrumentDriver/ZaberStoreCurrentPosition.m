function [ret err] = ZaberStoreCurrentPosition(device, devNr, address)
% StoreCurrentPosition - Saves the current absolute position of the device.
% 
% Valid Address values are 0 through 15 specifying one of 16 possible
% registers in which to store the position. This command can only be
% executed when the device has been homed. This command is used in
% conjunction with the Return Stored Position (Command #17) and
% Move To Stored Position (Command #18) instructions. The positions stored
% in the position registers are non-volatile and will persist after
% power-down or reset. All position registers are cleared by the Restore
% Settings (Command #36) instruction. 
% 
% inputs:
% -------
% devNr   ... the daisy-chain device number
% address ... address (0-15) to store the current position
%
% returns:
% --------
% ret	... array (m-by-2): first column = devID,
%			second column = stored address
%			e.g. [1 7; 3 7; ...]
% err	... errors
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
command = 16;
ZaberSendCommand(device, devNr, command, data);

% wait while moving
[ret err] = ZaberWaitForReturns(device, devNr, command, false);