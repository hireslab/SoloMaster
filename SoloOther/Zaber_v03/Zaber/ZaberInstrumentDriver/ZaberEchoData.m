function [ret err] = ZaberEchoData(device, devNr, outdata)
% EchoData - Echoes back the same Command Data that was sent.
% 
% This command is useful for testing communication, similar to a network
% "ping". 
%
% input:
% ------
% devNr ... the daisy-chain device number
% outdata ... the data to be read back
%
% returns:
% --------
% ret ... the returned data
% err ... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && (devNr >= 0) && (devNr <= 255))
    error('ZABERInstrumentDriver:EchoData:wrongArgument', ...
          'devNr must be numeric and inbetween [0...255]');
end
if ~(isscalar(outdata) && isnumeric(outdata))
    error('ZABERInstrumentDriver:EchoData:wrongArgument', ...
          'outdata must be scalar and numeric');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% send
command = 55;
ZaberSendCommand(device, devNr, command, outdata);

% receive and return reply
[ret err] = ZaberWaitForReturns(device, devNr, command, false);