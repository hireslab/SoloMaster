function [ret err] = ZaberRestoreSettings(device, devNr, id)
% RestoreSettings - Restores the device settings to the factory defaults. 
% 
% This command should be issued with a Peripheral Id of 0 to return the
% device to factory default settings. This instruction is very useful for
% troubleshooting. If the device does not appear to function properly, it
% may be because some of the settings have been changed. This instruction
% will restore the settings to default values. For a table of default
% settings, see Appendix A. All settings affected by this instruction are
% stored in non-volatile memory and will persist after power-down or reset. 
% 
% inputs:
% -------
% devNr ... the daisy-chain device number
% id    ... the peripheral id, so far only 0 seems appropriate
% 
% returns:
% --------
% ret   ... the peripheral id, so far only 0 seems appropriate
% err   ... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:RestoreSettings:wrongArgument', ...
          'devNr must be scalar, numeric and inbetween [0...255]');
end
if ~(isnumeric(devNr) && all(id == 0))
    error('ZABERInstrumentDriver:RestoreSettings:wrongArgument', ...
          'id must be scalar, numeric and zero');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% send
command = 36;
ZaberSendCommand(device, devNr, command, id);

% and receive
[ret err] = ZaberWaitForReturns(device, devNr, command, false);