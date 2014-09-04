function [ret err] = ZaberStop(device, devNr)
% Stop - Stops the device from moving by preempting any move instruction.
% 
% This instruction can be used to pre-empt any move instruction. The device
% will decelerate to a stop. The reply data is the absolute position after
% stopping.
% 
% The device will decelerate at a rate specified by Set Acceleration
% (Cmd 43).
% 
% This command may pre-empt, or be pre-empted by Move to Stored Position
% (Cmd 18), Move Absolute (Cmd 20), Move Relative (Cmd 21), Move at
% Constant Speed (Cmd 22) and Stop (Cmd 23). 
% 
% inputs:
% -------
% devNr ... the daisy-chain device number, or vector of numbers
% 
% returns:
% --------
% ret	... array (m-by-2): first column devID, second column actual
%			position in m
%			e.g. [1 34.3452; 3 0.00; ...]
% err	... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:SetMicrostepResolution:wrongArgument', ...
          'devNr must be numeric and inbetween [0...255]');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% send
command = 23;
ZaberSendCommand(device, devNr, command, 0);

% wait for replies
[data err] = ZaberWaitForReturns(device, devNr, command, false);

% convert microsteps to position in meters
ret = ZaberMicroSteps2Position(device, devNr, data);