function [ret err] = ZaberSetAcceleration(device, devNr, acceleration)
% SetAcceleration - Sets the acceleration used by the movement commands. 
% 
% When a movement command is issued, the device will accelerate at a rate
% determined by this command "Set Acceleration" up to a maximum speed
% determined by the target velocity. The acceleration may be changed
% on-the-fly even when the device is in the middle of a move. To determine
% the acceleration that will result from a given data value, the following
% formulas may be used:
% 
%     Actual Acceleration
%         = 11250 * Data * M mm/s^2 or deg/s^2 
%         = 11250 * Data microsteps/s^2 
%         = 11250 * Data / R steps/s^2 
% 
% Where:
%     Data is the value specified in the Command Data
%     M (mm or deg) is the microstep size
%     R is the microstep resolution set in command #37 (microsteps/step) 
% 
% The maximum value allowable is (512*R-1). This is the same as the maximum
% allowable data for velocity, which means that the device will reach
% maximum velocity immediately. If acceleration is set to 0, it is as if
% acceleration is set to (512*R-1). Effectively acceleration is turned off
% and the device will start moving at the target speed immediately.
%
% inputs:
% -------
% devNr			... the daisy-chain device number
% acceleration	... acceleration in m/s^2
%
% returns:
% --------
% ret ... acceleration in m/s^2
% err ... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:SetAcceleration:wrongArgument', ...
          'devNr must be numeric and inbetween [0...255]');
end
if ~(isnumeric(acceleration))
    error('ZABERInstrumentDriver:SetAcceleration:wrongArgument', ...
          'acceleration must be numeric');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% calculate the data to be sent
data = ZaberAcceleration2Data(device, devNr, acceleration);

% Send data
command = 43;
ZaberSendCommand(device, devNr, command, data);

% wait while moving
[data err] = ZaberWaitForReturns(device, devNr, command, false);

% calculate the speed in m/s
ret = ZaberData2Acceleration(device, devNr, data);