function [ret err] = ZaberReturnPowerSupplyVoltage(device, devNr)
% ReturnPowerSupplyVoltage - Returns the voltage level of the device's power supply. 
%
% A decimal is assumed before the last digit. For example, a value of 127
% indicates 12.7 V. Note that the internal voltage measurement is not very
% accurate. Don't be alarmed if the indicated voltage is slightly different
% from your measurements. 
%
% inputs:
% -------
% devNr ... the daisy-chain device number
%
% outputs:
% --------
% ret	... supply voltage
% err	... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:ReturnPowerSupplyVoltage:wrongArgument', ...
          'devNr must be numeric and inbetween [0...255]');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% send
command = 52;
ZaberSendCommand(device, devNr, command, 0);

% receive reply
[data err] = ZaberWaitForReturns(device, devNr, command, false);

% convert to voltage
ret = data;
ret(:,2) = double(data(:,2)) / 10;