function ZaberReset(device, devNr)
% Reset - Sets the device to its power-up condition. 
%
% This has the same effect as unplugging and restarting the device.
% Special Note: The position stored in the device prior to this command 
% will be lost, so you must save it and reload it if it is important. All 
% non-volatile settings (i.e. Device Number, Target Velocity, etc.) are
% saved and are not affected by reset or power-down.
% 
% inputs:
% -------
% devNr ... the daisy-chain device number
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && (devNr >= 0) && (devNr <= 255))
    error('ZABERInstrumentDriver:Reset:wrongArgument', ...
          'devNr must be numeric and inbetween [0...255]');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% Send data
command = 0;
ZaberSendCommand(device, devNr, command, 0);