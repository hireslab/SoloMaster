function [ret err] = ZaberSetHomeSpeed(device, devNr, speed)
% SetHomeSpeed - Sets the speed at which the device moves when using the
% "Home" command.
% 
% When a home instruction is issued, the device will accelerate at a rate
% determined by the acceleration setting up to the speed determined by this
% command. The home speed can be set independently of target speed
% (command 42) so that for stages that move very fast, issuing the home
% command would use a slower home speed and prevent the stage from crashing
% into the home position.
% 
% For a spreadsheet that can be used to calculate speed setting values for
% any product see http://www.zaber.com/documents/ZaberSpeedSetting.xls.
% Alternatively you may use the formulas below.
% 
% Actual Speed
%     = Data * 9.375 * M mm/s or deg/s 
%     = Data * 9.375 microsteps/s 
%     = Data * 9.375 / R steps/s 
%     = Data * 9.375 / (R x S) * 60 revolutions/min Motor rpm 
%     = Data * 9.375 * L / (R x S) mm/s Linear devices only 
% 
% where:
%     Data is the value of the command data
%     R (microsteps/step) is the microstep resolution (command 37)
%     S (steps/revolution) is the number of steps per motor revolution
%     M (mm or deg) is the microstep size
%     L (mm or deg) is the distance of linear motion per motor revolution 
% 
% Maximum data value is 512*R-1. Note that the maximum speed possible is
% independent of the resolution. In Firmware 5.21 and 5.22, a value of 0 is
% not allowed. In all other versions, target speed of 0 will cause Move
% Absolute/Relative and Move to Stored Position commands to return an error.
% 
% Refer to product specifications for the distance corresponding to a
% single microstep or revolution.
% 
% For example, if a motor has 48 steps per revolution (S = 48), used with
% default resolution (R = 64), and Data is 2922, then the motor will move
% at a speed of approximately 535 revolutions per minute. 
%
% inputs:
% -------
% devNr ... the daisy-chain device number
% speed ... speed in m/s
%
% returns:
% --------
% ret	... speed in m/s
% err   ... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:SetHomeSpeed:wrongArgument', ...
          'devNr must be numeric and inbetween [1...255]');
end
if ~(isnumeric(speed) && all(speed > 0))
    error('ZABERInstrumentDriver:SetHomeSpeed:wrongArgument', ...
          'speed must be numeric');
end
if any(speed > device.maxSpeed(cell2mat(device.aliases(devNr))))
    error('ZABERInstrumentDriver:SetHomeSpeed:exceedSpeedLimit', ...
          'value exeeds maximum speed, refer to the datasheet');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% calculate the data to be sent
data = ZaberSpeed2Data(device, devNr, speed);

% send
command = 41;
ZaberSendCommand(device, devNr, command, data);

% read back the speed
[data err] = ZaberWaitForReturns(device, devNr, command, false);

% calculate the speed in m/s
ret = ZaberData2Speed(device, devNr, data);