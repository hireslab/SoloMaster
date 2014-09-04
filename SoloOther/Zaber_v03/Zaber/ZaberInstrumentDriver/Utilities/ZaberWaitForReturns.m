function [ret err] = ZaberWaitForReturns(device, devNr, cmd, queryStatus)
% WaitForReturns - Read incoming command data and errors. Query the devices
% while moving until all expected data is received.
%
% inputs:
% -------
% device		... a Zaber device object
% devNr			... one or more device numbers
% cmd			... a command number to wait for
% queryStatus	... boolean flag, set to true to send status queries while
%					moving
% 
% returns:
% --------
% ret	... device numbers and return values
% err	... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer)
% 15.01.2013: bugfix (line 129)
%--------------------------------------------------------------------------

% get serial port
s = device.serialPort;

% prepare return value, set returns of expected devices to Infs
% check alias cell array
ret = zeros(1,device.nrOfDevices);
status = zeros(1,device.nrOfDevices);
if isscalar(devNr) && (devNr == 0)					% ask all devices
    ret(device.isTranslationStage) = Inf;
	status(device.isTranslationStage) = uint8(queryStatus);
elseif device.isInitialized							% ask some devices
	% for all device numbers
	for k = 1 : numel(devNr)
		% for all aliases of this device number
		if devNr(k) <= length(device.aliases) && ~isempty(device.aliases{devNr(k)})
            aliases = device.aliases{devNr(k)};
			for j = 1 : numel(aliases)
				ret(aliases(j)) = Inf;
				status(aliases(j)) = uint8(queryStatus);
			end
		end
	end
else									% ask some devices, but no aliases
	ret(devNr) = Inf;
	status(devNr) = uint8(queryStatus);
end

% find interesting devices, save for the shortening the return statement
lines2Return = find(isinf(ret));
err = [];

% wait till status == 0 and return statements are given
while sum(isinf(ret)) > 0 || sum(status) ~= 0
    r = [];

    % ask if still in motion
	for k = 1 : length(devNr)
		if isscalar(devNr) && devNr == 0				% all device
			fwrite(s, [devNr 54 0 0 0 0], 'uint8');        
			if device.debugLevel > 0
				disp([num2str(toc(device.time)) ' --> ' num2str([devNr 54 0 0 0 0]) ' (send status)']);
			end			
		elseif device.isInitialized						% all devices, including aliases
			if status(device.devNumbers(device.aliases{devNr(k)})) ~= 0
                if device.isTranslationStage(device.aliases{devNr(k)})
                    fwrite(s, [devNr(k) 54 0 0 0 0], 'uint8');        
                    if device.debugLevel > 0
                        disp([num2str(toc(device.time)) ' --> ' num2str([devNr(k) 54 0 0 0 0]) ' (send status)']);
                    end
                end
			end			
		else											% devices, without aliases
			if status(devNr(k)) ~= 0
                if device.isTranslationStage(devNr(k))
                    fwrite(s, [devNr(k) 54 0 0 0 0], 'uint8');        
                    if device.debugLevel > 0
                        disp([num2str(toc(device.time)) ' --> ' num2str([devNr(k) 54 0 0 0 0]) ' (send status)']);
                    end
                end
			end
		end
	end
	
	% wait some time
	t = cputime;
	while(cputime - t < 0.1) end;
	
    % read messages
    while s.BytesAvailable > 5 || isempty(r)
		r = fread(s, 6, 'uint8');
		
        if device.debugLevel > 0
            disp([num2str(toc(device.time)) ' <-- ' num2str(r') ' (receive command)']);
		end
        
		% check if read operation was successful
		if length(r) < 6
			error('ZABERInstrumentDriver:WaitForReturns:Timeout', ...
          'no data returned in time');
		end
		
		% check if data possibly missaligned
        if r(1) == 0
			% if the first byte is 0, flush the buffer
            ZaberFlushBuffer(device);
		else
			% if the second byte equals the initial command, its the return
			% value, else it might be a status or error information
			if r(2) == cmd
				ret(r(1)) = ZaberBytes2Cmd(r(3:6));
			else
				switch r(2)
					case 54                     % return status
						status(r(1)) = r(3);
						% if device is idle and yet returned no data don't
						% expect to get some
						if (status(r(1)) == 0) && isnan(ret(r(1)))
							ret(r(1)) = NaN;
						end
					case 255                    % error
						err(r(1)) = ZaberBytes2Cmd(r(3:6));
						ZaberDispatchError(device, err(r(1)));
						ret(r(1)) = 255;
						status(r(1)) = 0;
				end
			end
		end
	end	
end

% concatenate devNr for each device
ret = [device.devNumbers(:,1), ret.'];

% return only interesting lines, keep devNr in first column because it
% could come in handy for later processing
ret = ret(lines2Return,:);