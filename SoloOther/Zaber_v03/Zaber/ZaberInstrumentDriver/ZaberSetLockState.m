function [ret err] = ZaberSetLockState(device, devNr, lockMe)
% SetLockState - Locks or unlocks all non-volatile settings. 
% 
% Sometimes it is desirable to lock all non-volatile settings to prevent
% them from being changed inadvertently. After changing all settings as
% desired, settings can be locked by setting the Lock State to 1. Subsequent
% attempts to change any non-volatile setting (e.g., Set Target Speed,
% command 42) will result in an error response with an error code of 3600
% (settings locked). Note that the Set Lock State command does not apply
% to commands and settings that are specific to the joystick. Load Event
% Instruction and Set Axis Device Number for example, are unaffected by the
% Lock State.
% 
% How the Restore Settings instruction behaves when the settings are locked
% depends on the firmware version. In version 5.07 issuing a Restore
% Settings instruction while the settings are locked will result in an
% error response with an error code of 3600 (settings locked). This
% behavior was found to confuse many customers so in version 5.08 and up,
% the behavior was changed such that regardless of the current lock state,
% issuing a Restore Settings instruction will always return setting values
% to factory default values and leave settings in an unlocked state.
% 
% Settings can also be unlocked by setting the Lock State to 0. 
%
% inputs:
% -------
% devNr		... the daisy-chain device number
% lockMe	... boolean flag
% 
% returns:
% --------
% ret		... lock state
% err		... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:SetLockState:wrongArgument', ...
          'devNr must be numeric and inbetween [0...255]');
end
if ~all(islogical(lockMe))
    error('ZABERInstrumentDriver:SetLockState:wrongArgument', ...
          'lockMe must be boolean values');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% send
command = 49;
ZaberSendCommand(device, devNr, command, uint8(lockMe));

% read back the lock state
[ret err] = ZaberWaitForReturns(device, devNr, command, false);