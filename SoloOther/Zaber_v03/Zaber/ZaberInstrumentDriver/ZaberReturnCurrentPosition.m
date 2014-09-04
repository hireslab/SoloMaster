function [ret err] = ZaberReturnCurrentPosition(device, devNr)
% ReturnCurrentPosition - Returns the current absolute position of the
% device in microsteps.
% 
% This is equivalent to issuing a Return Setting (#53) command with a
% command data value of 45 (Set Current Position).
% 
% input:
% ------
% devNr ... the daisy-chain device number
% 
% returns:
% --------
% ret	... array (m-by-2) of devId (column 1) and position in mm (column 2)
%			devId <> 0: m is usually 1
%			devId == 0: m is usually >1
%			e.g. [1 12.345;3 0.000;2 45.0032]
% err	... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:ReturnCurrentPosition:wrongArgument', ...
          'devNr must be numeric and inbetween [0...255]');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% Send data
command = 60;
ZaberSendCommand(device, devNr, command, 0);

% and receive
[data err] = ZaberWaitForReturns(device, devNr, command, false);

% Convert position from microsteps to m
ret = ZaberMicroSteps2Position(device, devNr, data);