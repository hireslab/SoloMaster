function ret = ZaberFlushBuffer(device)
% FlushBuffer - Flush the buffer in packets of 6 bytes. If less bytes cause
% a timeout, wait at least 0.1 seconds, so that the stage discards any open
% command and reset the input buffer.
%
% inputs:
% -------
% device	... a Zaber device object
%
% returns:
% --------
% ret		... flushed bytes of input command data
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% check device listing 
if device.nrOfDevices < 1
    error('ZABERInstrumentDriver:FlushBuffer:EmptyDeviceList', ...
          'no device found - are you missing a ZaberUpdateDeviceList command?');
end

% get serial port
s = device.serialPort;

% discard old data, command-wise
ret = [];
while (s.Bytesavailable > 0)
	try
		data = fread(s, 6, 'uint8');		    
		ret = [ret; data'];

		if device.debugLevel > 0
			disp([num2str(toc(device.time)) ' <-- ' num2str(data') ' (FLUSH buffer)']);
		end
    catch
        warning(1,'I am about to flush an incomplete command');
        t = cputime;
        while cputime < t + device.flushTimeOut
		end
		
		data = fread(s, s.BytesAvailable, 'uint8');
		
		if device.debugLevel > 0
			disp([num2str(toc(device.time)) ' <-- ' num2str(data') ' (FLUSH buffer, incomplete command)']);
		end
	end
end