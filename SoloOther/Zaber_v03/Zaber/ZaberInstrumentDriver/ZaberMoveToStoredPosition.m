function [ret err] = ZaberMoveToStoredPosition(device, devNr, address, varargin)
% MoveToStoredPosition - Moves the device to the stored position specified
% by the Command Data.
% 
% Valid address values are 0 through 15, specifying one of 16 possible
% positions. This command is used in conjunction with the
% Store Current Position (#16) and Return Stored Position (#17) commands.
% This command does not send a response until the move has finished. All
% move commands are pre-emptive. If a new move command is issued before
% the previous move command is finished, the device will immediately move
% to the new position.
% 
% The target speed and acceleration during a move absolute instruction can
% be specified using Set Target Speed (Cmd 42) and Set Acceleration
% (Cmd 43) respectively.
% 
% This command may pre-empt, or be pre-empted by Move to Stored Position
% (Cmd 18), Move Absolute (Cmd 20), Move Relative (Cmd 21),
% Move at Constant Speed (Cmd 22) and Stop (Cmd 23). 
%
% inputs:
% -------
% devNr   ... the daisy-chain device number
% address ... address (0-15) to store the current position
% wait    ... (optional) wait for replies, boolean flag
% 
% returns:
% --------
% ret     ... final position in m
% err     ... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer)
%--------------------------------------------------------------------------

% parse inputs
p = inputParser;
addRequired(p, 'device', @(x) isa(x, 'struct'));
addRequired(p, 'devNr', @(x) isnumeric(x) && all(x >= 0) && all(x <= 255));
addRequired(p, 'address', @(x) isnumeric(x) && all(x >= 0) && all(x <= 15));
addOptional(p, 'wait', true, @islogical);
parse(p, device, devNr, address, varargin{:});

% flush serial port input buffer, flush input buffer if we are waiting
if (p.Results.wait)
	ZaberFlushBuffer(p.Results.device);
end

% Generate additional command byte 3
data = bitand(p.Results.address, 255);

% Send data
command = 18;
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
