function [ret err] = ZaberMoveRelative(device, devNr, relativePosition, varargin)
% MoveRelative - Moves the device by the positive or negative number of
% microsteps specified in the Command Data.
% 
% The device moves to a position given by its current position plus the
% value specified in the command data. The relative move command data in
% microsteps can be positive or negative. The final position must be
% between 0 and Maximum Position (specified by Set Maximum Position
% (cmd 44)), or an error code will be returned. The device begins to move
% immediately, and sends a response when the move has finished.
% 
% The target speed and acceleration during a move absolute instruction can
% be specified using Set Target Speed (Cmd 42) and Set Acceleration
% (Cmd 43) respectively.
% 
% All move commands are pre-emptive. If a new move command is issued before
% the previous move command is finished, the device will immediately move
% to the new position. If a Move Relative command is issued while the
% device is currently moving due to a previous command, the device will
% immediately set a new target position equal to the current position
% (at the instant the command was received) plus the specified relative
% position.
% 
% This command may pre-empt, or be pre-empted by Move to Stored Position
% (Cmd 18), Move Absolute (Cmd 20), Move Relative (Cmd 21), Move at
% Constant Speed (Cmd 22) and Stop (Cmd 23). 
% 
% inputs:
% -------
% relativePosition ... relative distance in m
% wait             ... (optional) wait for replies, boolean flag
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
addRequired(p, 'relativePosition', @(x) isnumeric(x));
addOptional(p, 'wait', true, @islogical);
parse(p, device, devNr, relativePosition, varargin{:});

% flush serial port input buffer, flush input buffer if we are waiting
if (p.Results.wait)
	ZaberFlushBuffer(p.Results.device);
end

% generate command bytes 3 through 6
data = ZaberPosition2MicroSteps(p.Results.device, p.Results.devNr, p.Results.relativePosition);

% send
command = 21;
ZaberSendCommand(p.Results.device, p.Results.devNr, command, data);

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
