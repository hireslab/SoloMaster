function [ret err] = ZaberMoveAbsolute(device, devNr, absolutePosition, varargin)
% MoveAbsolute - Moves the device to the position specified in the Command
% Data in microsteps.
% 
% The device begins to move immediately, and sends a response when the move
% has finished. The position must be between 0 and Maximum Position
% (specified by Set Maximum Position (cmd 44)), or an error code will be
% returned.
% 
% The target speed and acceleration during a move absolute instruction can
% be specified using Set Target Speed (Cmd 42) and Set Acceleration (Cmd 43)
% respectively.
% 
% All move commands are pre-emptive. If a new move command is issued before
% the previous move command is finished, the device will immediately move
% to the new position. This command may pre-empt, or be pre-empted by Move
% to Stored Position (Cmd 18), Move Absolute (Cmd 20), Move Relative
% (Cmd 21), Move at Constant Speed (Cmd 22) and Stop (Cmd 23). 
% 
% inputs:
% -------
% absolutePosition ... the absolute position in m
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
addRequired(p, 'absolutePosition', @(x) isnumeric(x) && all(x >= 0));
addOptional(p, 'wait', true, @islogical);
parse(p, device, devNr, absolutePosition, varargin{:});

% flush serial port input buffer, flush input buffer if we are waiting
if (p.Results.wait)
	ZaberFlushBuffer(p.Results.device);
end

% generate command bytes 3 through 6
data = ZaberPosition2MicroSteps(p.Results.device, p.Results.devNr, p.Results.absolutePosition);

% send
command = 20;
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
