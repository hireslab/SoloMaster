function [ret err] = ZaberReturnDeviceId(device, devNr)
% ReturnDeviceId - Returns the id number for the type of device connected.
%
% See the Zaber support web site for a table of device ids for all
% Zaber products. 
%
% inputs:
% -------
% devNr ... the daisy-chain device number
%
% outputs:
% --------
% ret	... [devNr, device id]
% err	... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:ReturnDeviceId:wrongArgument', ...
          'devNr must be numeric and inbetween [0...255]');
end

% get and flush serial port
ZaberFlushBuffer(device);

% Send data
command = 50;
ZaberSendCommand(device, devNr, command, 0);

% and receive
[ret err] = ZaberWaitForReturns(device, devNr, command, false);