function [ret err] = ZaberHome(device, devNr, varargin)
% Home - Moves to the home position and resets the device's internal
% position to 0. 
%
% Upon receiving this instruction, the device will retract until its
% internal home sensor is triggered. It will then move forward several
% steps to avoid accidentally re-triggering the home sensor during use.
% Its internal position is then set to 0. If a home offset has been
% specified with the Set Home Offset (cmd 47) instruction, the device will
% move forward for the specific offset, then set the new position to 0.
% 
% Prior to Firmware 5.21, the device will attempt to home for an extended
% amount of time. For Firmware 5.21 and up, the home command aborts with
% an error if the device has traveled twice the Maximum Position setting
% without triggering the home sensor. This indicates that the device could
% possibly be stalling or slipping. 
%
% inputs:
% -------
% devNr ... the daisy-chain device number
% wait  ... wait for replies, boolean flag
%
% returns:
% --------
% ret   ... final position in m
% err   ... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer)
%--------------------------------------------------------------------------

% parse inputs
p = inputParser;
addRequired(p, 'device', @(x) isa(x, 'struct'));
addRequired(p, 'devNr', @(x) isnumeric(x) && all(x >= 0) && all(x <= 255));
addOptional(p, 'wait', true, @islogical);
parse(p, device, devNr, varargin{:});

% flush serial port input buffer, flush input buffer if we are waiting
if (p.Results.wait)
	ZaberFlushBuffer(p.Results.device);
end

% send data
command = 1;
ZaberSendCommand(p.Results.device, p.Results.devNr, command, 0);

% end command if we do not wait for any replies
if ~p.Results.wait
    ret = [];
	err = [];
    return;
end

% wait while moving
[data err] = ZaberWaitForReturns(p.Results.device, p.Results.devNr, command, true);

% convert microsteps to position in meters
ret = ZaberMicroSteps2Position(p.Results.device, p.Results.devNr, data);