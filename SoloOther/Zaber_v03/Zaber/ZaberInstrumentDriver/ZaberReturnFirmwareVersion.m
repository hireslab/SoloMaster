function [ret err] = ZaberReturnFirmwareVersion(device, devNr)
% ReturnFirmwareVersion - Returns the firmware version installed on the
% device. 
% 
% A decimal is assumed before the last two digits. For example, 502
% indicates firmware version 5.02 (taken care of by the instrument driver).
%
% inputs:
% -------
% devNr ... the daisy-chain device number
%
% outputs:
% --------
% ret	... array (m-by-2) of devId (column 1) and firmware version (column 2)
%			devId <> 0: m is usually 1
%			devId == 0: m is usually >1
%			e.g. [1 5.23;3 5.12;2 3.12]
% err	... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:ReturnFirmwareVersion:wrongArgument', ...
          'devNr must be numeric and inbetween [1...255]');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% send
command = 51;
ZaberSendCommand(device, devNr, command, 0);

% read back the reply
[data err] = ZaberWaitForReturns(device, devNr, command, false);

% convert value to string
ret = data;
ret(:,2) = double(data(:,2)) / 100;