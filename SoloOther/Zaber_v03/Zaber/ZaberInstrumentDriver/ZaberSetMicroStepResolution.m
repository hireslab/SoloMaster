function [ret err device] = ZaberSetMicroStepResolution(device, devNr, resolution)
% SetMicroStepResolution - Changes the number of microsteps per step. 
% 
% This command sets the microstep resolution of a device.
% 
% This setting is stored in non-volatile memory and will persist after
% power-down or reset. Use Restore Settings (Cmd 36) to restore all
% non-volatile settings to factory default.
% 
% The default on most devices is 64. Available microstep resolutions are:
%     1, 2, 4, 8, 16, 32, 64, 128 
% 
% All position data sent to or received from T-Series products is in units
% of microsteps. Note that when you change the microstep resolution, other
% position related settings are scaled automatically from current values to
% adjust for the new microstep size. The table below gives an example
% showing how other settings are affected when the microstep resolution is
% changed from 128 to 64: 
% 
% Setting						Before 	After
% -----------------------------------------------
% Target Speed *				2922 	1461
% Maximum Travel Range *		280000 	140000
% Current Position				10501 ** 	5250 **
% Maximum Relative Move *		20000 	10000
% Home Offset *					1000 	500
% Acceleration *				100 	50
% 
% * The settings for these commands are saved in non-volatile memory. 
% ** Note that if a number is divided by two, it is rounded down to the
% nearest whole number. The only exception to this is if acceleration
% would become 0 (because 0 for acceleration indicates infinite
% acceleration). If acceleration would become 0, it will instead be set to
% 1 which is the lowest acceleration possible. 
%
% inputs:
% -------
% devNr      ... the daisy-chain device number
% resolution ... microstepping reolution
% 
% returns:
% --------
% ret		... microstepping reolution
% err		... errors
% device	... device information
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:SetMicrostepResolution:wrongArgument', ...
          'devNr must be numeric and inbetween [1...255]');
end
if ~isnumeric(resolution)
    error('ZABERInstrumentDriver:SetMicrostepResolution:wrongArgument', ...
          'resolution must be scalar and a boolean value');
end
if ~all(ismember(resolution, [1,2,4,8,16,32,64,128]))
   error('ZABERInstrumentDriver:SetMicrostepResolution:wrongArgument', ...
         'Microstepping resolution unavailable (must be 1, 2, 4, 8, 16, 32, 64, 128).');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% Generate additional command byte 3
data = bitand(resolution, 255);

% send
command = 37;
ZaberSendCommand(device, devNr, command, data);

% receive reply
[ret err] = ZaberWaitForReturns(device, devNr, command, false);

% update device list
device = ZaberUpdateDeviceList(device);