function [ret err] = ZaberWaitTillIdle(device, devNr)
% ZaberWaitTillIdle - Query devices for status information and wait till
% all devices are idle. Return their final positions.
%
%
% FUNCTION NOT TESTED (and somewhat sloppy)
%
%
% inputs:
% -------
% device	... a Zaber device object
% devNr		... device number, or vector of device numbers
% 
% returns:
% --------
% ret		... device numbers and final positions
% err		... errors
%
%-file history-------------------------------------------------------------
% 22.04.2012: initial creation (D.Hofer)
%--------------------------------------------------------------------------

% get serial port
s = device.serialPort;

% prepare status information
if numel(find(devNr)) < numel(devNr)	% devNr contains devNr 0
	status(device.isTranslationStage) = zeros(1,device.nrOfDevices);
else
	status = zeros(1,device.nrOfDevices);
	status(devNr) = 1;
end

while (sum(status(:)) > 0)
	% send status requests
	for k = 1:length(status)
		if (status(k) > 0)
			fwrite(s, [devNr(k) 54 0 0 0 0], 'uint8');        
			if device.debugLevel > 0
				disp(['--> ' num2str([devNr(k) 54 0 0 0 0]) ' (send status)']);
			end
		end
	end
	
	% receive replies
	while s.BytesAvailable > 0
		r = fread(s, 6, 'uint8');
		if device.debugLevel > 0
            disp(['<-- ' num2str(r') ' (receive command)']);
		end
		
		% if the first byte is 0, flush the buffer
		if r(1) == 0
			ZaberFlushBuffer(device);
		end
		
		if r(2) == 54
			status(r(1)) = r(3);
		end
	end
end

% get final position
ret = [];
err = {};
for k=1:numel(devNr)
	if devNr(k) > 0
		[pos posErr] = ZaberReturnCurrentPosition(device, devNr(k))
		ret = [ret, k pos];
		err = vertcat(err, {k, posErr});
	end
end