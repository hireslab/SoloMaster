function [ret err] = ZaberRenumber(device, devNr, newnumber)
% Renumber - Assigns new numbers to all the devices in the order in which
% they are connected.
%
% This command is usually sent to device number 0. When it is, the command
% data is ignored and all devices will renumber. The device closest to the
% computer becomes device number 1. The next device becomes number 2 and
% so on.
% 
% If sent to a device number other than 0, then that device will reassign
% itself the device number in the command data.
% 
% Note: Renumbering takes about 1/2 a second during which time the computer
% must not send any further data. The device number is stored in
% non-volatile memory so you can renumber once and not worry about issuing
% the renumber instruction again after each power-up. 
%
% inputs:
% -------
% devNr		... the daisy-chain device number
% newnumber ... the new ID number
%
% returns:
% --------
% ret   ... array of actual device ID's
%           first column devNr, second column devID
%           e.g. [1] [6310]
%                [3] [6210]
% err ... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && (devNr >= 0) && (devNr <= 255))
    error('ZABERInstrumentDriver:Renumber:wrongArgument', ...
          'devNr must be numeric and inbetween [0...255]');
end
if ~(isscalar(newnumber) && (newnumber >= 0) && (newnumber <= 255))
    error('ZABERInstrumentDriver:Renumber:wrongArgument', ...
          'newnumber must be scalar and inbetween [0...255]');
end

% get and flush serial port
ZaberFlushBuffer(device);
s = device.serialPort;

% Adjust Timeout for 0.5 second renumbering process
timeoutsave = s.Timeout;        % save old value
s.Timeout = 2;                  % set new value

% send data
command = 2;
ZaberSendCommand(device, devNr, command, newnumber);

% receive reply
[ret err] = ZaberWaitForReturns(device, devNr, command, false);

% Restore previous timeout value
s.Timeout = timeoutsave;