function ZaberSendCommand(device, devNr, command, data)
% SendCommand - Send a command and its data bytes to one or more devices.
%
% inputs:
% -------
% device	... Zaber device object
% devNr		... single device number or a list of numbers
% commmand	... command number to send
% data		... command data to be sent
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer)
% 10.07.2013: do not send in-motion queries to T-JOY in single device mode
%--------------------------------------------------------------------------

% get command bytes 3 to 6
bytes = ZaberCmd2Bytes(data);

% copy bytes to numel(devNr) lines if necessary
if (numel(devNr) > 1) && (size(bytes,1) ~= numel(devNr))
    if size(bytes,1) > 1
        error('ZABERInstrumentDriver:ZaberSendCommand:toLessData', ...
          'more than one, but less than numel(devNr) command data values found');
    end
    bytes = repmat(bytes(1,:),numel(devNr),1);
end

% send command
for k = 1 : numel(devNr)
	fwrite(device.serialPort, [devNr(k) command bytes(k,:)], 'uint8');

	% display the sent message
	if device.debugLevel > 0
		disp([num2str(toc(device.time)) ' --> ' num2str([devNr(k) command bytes(k,:)]) ' (send command ' ...
			num2str(command) ')']);
    end
    
    % wait some time
	t = cputime;
	while(cputime - t < 0.1) end;
end