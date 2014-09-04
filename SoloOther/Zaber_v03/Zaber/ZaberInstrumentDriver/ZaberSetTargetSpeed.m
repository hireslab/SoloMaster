function [ret err] = ZaberSetTargetSpeed(device, devNr, speed)
% SetTargetSpeed - Sets the speed at which the device moves when using the
% "Move Absolute" or "Move Relative" commands. 
% 
% When a move absolute or move relative instruction is issued, the device
% will accelerate at a rate determined by the acceleration setting up to
% the speed determined by this command.
% 
% The target velocity may be changed on-the-fly even when the device is in
% the middle of a move. The device will automatically adjust the velocity,
% but still target the final position specified in the original move.
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
% devNr ... the daisy-chain device number, or vector of numbers
% speed ... speed, or a vector of speeds in m/s
%
% returns:
% --------
% speed ... speed in m/s
% err   ... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:SetTargetSpeed:wrongArgument', ...
          'devNr must be numeric and inbetween [1...255]');
end
if ~(isnumeric(speed) && all(speed > 0))
    error('ZABERInstrumentDriver:SetTargetSpeed:wrongArgument', ...
          'speed must be numeric, positive and not zero');
end
if any(speed > device.maxSpeed(cell2mat(device.aliases(devNr))))
    error('ZABERInstrumentDriver:SetTargetSpeed:exceedSpeedLimit', ...
          'value exeeds maximum speed, refer to the datasheet');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% calculate the data to be sent
data = ZaberSpeed2Data(device, devNr, speed);

% send
command = 42;
ZaberSendCommand(device, devNr, command, data);

% read back the speed
[data err] = ZaberWaitForReturns(device, devNr, command, false);

% calculate the speed in m/s
ret = ZaberData2Speed(device, devNr, data);