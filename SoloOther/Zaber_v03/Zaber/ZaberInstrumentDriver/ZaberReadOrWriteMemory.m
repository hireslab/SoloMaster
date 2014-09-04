function [ret err] = ZaberReadOrWriteMemory(device, devNr, iswrite, address, outbyte)
% ReadOrWriteMemory - Reads or writes a byte of non-volatile memory. 
% 
% 128 bytes of memory are available for user data. For example, the user
% may want to save some custom data such as a serial number, a name string,
% or data that uniquely identifies a particular device. Data written is
% not cleared by power down or reset. The most significant bit of byte 3
% specifies whether the instruction is a read (0) or a write (1). The least
% significant 7 bits of byte 3 specify the address to read/write (0 to 127).
% Byte 4 specifies the value to be written. Bytes 5 and 6 are ignored.
% 
% These settings are stored in non-volatile memory and will persist after
% power-down or reset. 
%
% inputs:
% ------
% devNr   ... the daisy-chain device number
% iswrite ... boolean flag true/false to write/read a byte of data
% address ... an address (0-127) to write to or read from
% outbyte ... the byte to be written
% 
% returns:
% --------
% ret ... inbyte, the returned byte of data
% err ... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:ReadOrWriteMemory:wrongArgument', ...
          'devNr must be numeric and inbetween [0...255]');
end
if ~(isscalar(iswrite) && islogical(iswrite))
    error('ZABERInstrumentDriver:ReadOrWriteMemory:wrongArgument', ...
          'iswrite must be scalar and a boolean value');
end
if ~(isscalar(address) && isnumeric(address) && (address > -1) && (address < 128))
    error('ZABERInstrumentDriver:ReadOrWriteMemory:wrongArgument', ...
          'address must be scalar, numeric and inbetween [0..127]');
end
if ~(isscalar(outbyte) && isnumeric(outbyte))
    error('ZABERInstrumentDriver:ReadOrWriteMemory:wrongArgument', ...
          'outbyte must be scalar and numeric');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% Generate additional command byte 3
if (iswrite)
    b0 = address + 128;
else
    b0 = address;
end;

% Send data
command = 35;
for k = 1 : numel(devNr)
    fwrite(device.serialPort, [devNr(k) command b0 outbyte 0 0], 'uint8');

    % display the sent message
    if device.debugLevel > 0
        disp([num2str(toc(device.time)) ' --> ' ...
            num2str([devNr(k) command b0 outbyte 0 0]) ...
            ' (send command ' num2str(command) ')']);
    end
end

% read back the reply
[data err] = ZaberWaitForReturns(device, devNr, command, false);

% reply is placed in byte 4, so shift it down
ret = data ./ 256;