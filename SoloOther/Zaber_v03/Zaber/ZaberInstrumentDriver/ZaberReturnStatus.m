function [ret err] = ZaberReturnStatus(device, devNr)
% ReturnStatus - Returns the current status of the device.
% 
% Possible status codes are as follows:
%     0 - idle, not currently executing any instructions
%     1 - executing a home instruction
%     10 - executing a manual move (i.e. the manual control knob is turned)
%     20 - executing a move absolute instruction
%     21 - executing a move relative instruction
%     22 - executing a move at constant speed instruction
%     23 - executing a stop instruction (i.e. decelerating) 
%
% inputs:
% -------
% devNr ... the daisy-chain device number
%
% outputs:
% --------
% ret	... array (m-by-2) of devId (column 1) and status (column 2)
%			devId <> 0: m is usually 1
%			devId == 0: m is usually >1
%			e.g. [1 0;3 20;2 22]
% err	... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Error checking, debug flags
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:ReturnStatus:wrongArgument', ...
          'devNr must be numeric and inbetween [0...255]');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% send
command = 54;
ZaberSendCommand(device, devNr, command, 0);

% receive reply
[ret err] = ZaberWaitForReturns(device, devNr, command, false);