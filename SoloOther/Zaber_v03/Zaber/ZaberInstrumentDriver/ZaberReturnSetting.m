function [ret err] = ZaberReturnSetting(device, devNr, settingNumber)
% ReturnSetting - Returns the current value of the setting specified in the
% Command Data.
% 
% Valid command data values are the command numbers of any "Set..."
% instruction. The device will reply using the command number of the
% specified setting (as if a command to change the setting had just been
% issued) but the setting will not be changed.
% 
% For example, command #48 is the "Set Alias" instruction. Therefore if you
% wish to return the current value of the alias number, simply send the
% Return Setting instruction with data of 48. The device will reply with
% command #48 and data equal to the setting value.
% 
% Since firmware version 5.21, this command also accepts the command
% numbers of any "Return..." instruction, such as command #50 "Return
% Device Id".
%
% inputs:
% -------
% devNr         ... the daisy-chain device number
% settingNumber ... number of the corresponding "Set.." function
%
% outputs:
% --------
% ret	... array (m-by-2) of devId (column 1) and setting data (column 2)
%			devId <> 0: m is usually 1
%			devId == 0: m is usually >1
%			e.g. [1 64;3 8;2 64]
% err	... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:ReturnSetting:wrongArgument', ...
          'devNr must be numeric and inbetween [0...255]');
end
if ~(isnumeric(settingNumber) && all(settingNumber >= 0) && all(settingNumber <= 255) )
    error('ZABERInstrumentDriver:ReturnSetting:wrongArgument', ...
          'settingnumber must be numeric and inbetween [0...255]');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% send
command = 53;
ZaberSendCommand(device, devNr, command, settingNumber);

% receive reply
[ret err] = ZaberWaitForReturns(device, devNr, settingNumber, false);