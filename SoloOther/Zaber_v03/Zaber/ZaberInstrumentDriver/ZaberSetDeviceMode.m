function [ret err] = ZaberSetDeviceMode(device, devNr, mode)
% SetDeviceMode - Sets the Mode for the given device.
% 
% This command allows setting several options. Each option is controlled by
% a single bit within the command data. Most software you will encounter,
% including most of our demo software, represents all 4 data bytes as a
% single decimal value rather than specifying each bit individually. To
% determine what decimal value to use requires a basic understanding of how
% the data is represented in binary. The command data may be considered as
% a single 32-bit binary value. The least significant bit is bit_0, the
% next is bit_1, the next is bit_2, and so on up to the most significant
% bit_31. Each bit may have a value of either 1 or 0.
% 
% The corresponding decimal representation of this 32-bit data is given by:
%     Decimal value = (bit_0 * 1) + (bit_1 * 2) + … + (bit_31 * 2^31) 
% 
% Each bit controls a single mode option as described in the table below.
% To determine the data value to use with the Set Device Mode command,
% simply determine the desired value of each bit (1 or 0), and calculate
% the decimal value using the above formula. Note that not all 32 bits 
% are currently used. Any unused or reserved bits should be left as 0.
% 
% For example, suppose you want all mode bits to be 0 except for bit_3 
% (disable potentiometer), bit_14 (disable power LED), and bit_15 
% (disable serial LED). The Set Device Mode instruction should be sent 
% with data calculated as follows:
% 
%     Command Data
%         = 2^3 + 2^14 + 2^15 
%         = 8 + 16384 + 32768 
%         = 49160 
% 
% Note that each instance of the Set Device Mode command overwrites ALL
% previous mode bits. Repeated commands do not have a cumulative effect.
% For example, suppose you send a Set Device Mode command with data of 8 
% to disable the potentiometer. If you then send another Set Device Mode 
% command with data of 16384 to disable the power LED, you will re-enable 
% the potentiometer since bit_3 in the 2nd instruction is 0.
% 
% Most devices have a default mode setting of 0 (all bits are 0), however, 
% there are some exceptions. See Appendix A of the user manual for a table 
% of default settings. 
%
% inputs:
% -------
% devNr ... the daisy-chain device number
% mode  ... a cell array of settings
% 	
% returns:
% --------
% ret	... mode, a cell array of setting
% err	... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && (devNr >= 0) && (devNr <= 255))
    error('ZABERInstrumentDriver:SetDeviceMode:wrongArgument', ...
          'devNr must be numeric and inbetween [1...255]');
end
if ~(iscell(mode))
    error('ZABERInstrumentDriver:SetDeviceMode:wrongArgument', ...
          'mode must be a cell array of settings');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% Analyze settings cell array
% convert it to a single value
data = 0;
for k = 1 : size(mode,1)
	data = data + mode{k,2};
end

% send
command = 40;
ZaberSendCommand(device, devNr, command, data);

% receive reply
[retmode err] = ZaberWaitForReturns(device, devNr, command, false);

% build up return cell array
ret = [];
for k = 1:size(retmode,1)
    bitmode = bitget(uint16(retmode(k,2)),1:16);
    mode = {};
    for k = 1:16
        if bitmode(k)
            mode = vertcat(mode, device.settings{k,:});
        end
    end
    ret = [ret; ret(k,1) mode];
end