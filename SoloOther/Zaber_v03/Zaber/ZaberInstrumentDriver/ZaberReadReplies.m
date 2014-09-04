function ret = ZaberReadReplies(device, interpret)
% readReplies - Read all data in the serial input buffer, interpret it and
% return a neat list of all found commands and errors.
%
%
% FUNCTION IS NOT TESTED!
%
%
% inputs:
% -------
% interpret ... boolean flag,
%               return a cell or matrix array with command and error names
%
% returns:
% --------
% commands/errors ... either [devNr1 commandNr1 data1; ... ]
%                     or {devNr1, commandNr1, commandName1, data1; ...}
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isscalar(interpret) && islogical(interpret))
    error('ZABERInstrumentDriver:ReadReplies:wrongArgument', ...
          'interpret must be scalar and a boolean value');
end

% get serial port
s = device.serialPort;

% Read available data over serial port
if s.BytesAvailable > 0
	r = fread(s, s.BytesAvailable, 'uint8');
    if (device.debugLevel)
        disp([num2str(toc(device.time)) ' <-- ' num2str(r') ' (receive)']);
    end
else
	if interpret 
        ret = {};
    else
        ret = [];
	end
    return;
end

% Convert all received commands
ret = zeros(length(r)/6,3);
k = 1;
while k < length(r)
	if k+4 < length(r)
		ret(k,:) = [r(k), r(k+1), r(k+2) + 256 * r(k+3) + 256^2 * r(k+4) + 256^3 * r(k+5)];
	end;
	k = k + 6;
end

% end here?
if ~interpret
    return;
end

% interpret commands and errors
r = ret;
ret = {};
for k = 1 : size(r,1)
    if r(k,2) == 255    % search for an error
        for m = 1 : size(device.errors,1)
            if r(k,3) == device.errors{m,1}
                ret = vertcat(ret, {r(k,1), r(k,2), ['ERROR - ', device.errors{m,2}], device.errors{m,3}, r(k,3)});
            end
        end
    else                % search for a command
        for m = 1 : size(device.commands,1)
            if r(k,2) == device.commands{m,2}
                ret = vertcat(ret, {r(k,1), r(k,2), device.commands{m,1}, device.commands{m,5}, r(k,3)});
            end
        end
    end
end