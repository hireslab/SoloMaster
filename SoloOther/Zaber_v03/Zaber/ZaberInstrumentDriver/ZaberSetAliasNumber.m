function [ret err device] = ZaberSetAliasNumber(device, devNr, alias)
% SetAliasNumber - Sets an alternate device number for a device.
%
% This setting specifies an alternate device number for a device (in
% addition to its actual device number). By setting several devices to the
% same alias number, you can control a group of devices with a single
% instruction. When you send an instruction to an alias number, all devices
% with that alias number will execute the instruction and reply using their
% actual device numbers. To remove an alias, simply set the device's alias
% number to zero. Valid alias numbers are between 0 and 254. To avoid
% confusion, it is best to choose an alias greater than the number of
% devices connected.
% 
% This setting is stored in non-volatile memory and will persist after
% power-down or reset.
%
% inputs:
% -------
% devNr	... the daisy-chain device number
% alias ... alias number
%
% returns:
% --------
% ret       ... alias number
% err       ... errors
% device    ... a zaber device object
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:SetAliasNumber:wrongArgument', ...
          'devNr must be numeric and inbetween [0...255]');
end
if ~(isnumeric(alias) && all(alias >= 0) && all(alias <= 254))
    error('ZABERInstrumentDriver:SetAliasNumber:wrongArgument', ...
          'devNr must be numeric and inbetween [0...254]');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% Generate additional command byte 3
data = bitand(alias, 255);

% Send data
command = 48;
ZaberSendCommand(device, devNr, command, data);

% receive reply
[ret err] = ZaberWaitForReturns(device, devNr, command, false);

% update list of aliases
device = ZaberUpdateDeviceList(device);