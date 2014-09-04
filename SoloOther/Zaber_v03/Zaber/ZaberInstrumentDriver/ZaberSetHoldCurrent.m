function [ret err] = ZaberSetHoldCurrent(device, devNr, currentDivider)
% SetHoldCurrent - Sets the desired current to be used when the device is
% holding its position.
% 
% It is typical to run stepper motors at their rated current only during
% moves (for highest torque) and reduce the current when idle just to hold the position.
% 
% Typically the hold current can be set to around 25 - 50% of the running
% current. In some applications, the friction of the drive system alone is
% sufficient to hold the microstep position of the motor, and the hold
% current can be turned off completely. The hold current can be turned off
% by issuing the "Set Hold Current" instruction with data of 0.
% 
% When the device is moving, it applies running current to the motor. When
% the device stops moving, running current is applied for an additional 0.1
% second before hold current is applied.
% 
% The current is related to the data by the formula:
%     Current = CurrentCapacity * 10 / CommandData 
% 
% The range of accepted values is 0 (no current), 10 (max) - 127 (min).
% CurrentCapacity is the hardware's maximum capability of output current.
% 
% To prevent damage, some devices limit the maximum output current to a
% lower value. In that case the valid range is 0, Limit - 127. Current
% limits are listed under the device specifications.
% 
% Some devices limit the voltage rather than the current. In this case the
% same formula can be used by replacing Current and CurrentCapacity with
% Voltage and PowerSupplyVoltage.
% 
% For example, Suppose you connect a stepper motor rated for 420mA per
% phase to a T-CD2500. Reversing the equation above and using 420mA as
% Current gives:
% 
% CommandData
%     = 10 * CurrentCapacity / Current 
%     = 10 * 2500mA / 420mA 
%     = 59.5 (round to 60) 
% 
% Therefore CommandData = 60. 
%
% inputs:
% -------
% devNr			 ... the daisy-chain device number
% currentDivider ... current divider value
% 	
% returns:
% --------
% ret ... current divider value
% err ... errors
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer, type-check by J.Oberreiter)
%--------------------------------------------------------------------------

% Debug Flags & error checking
if ~(isnumeric(devNr) && all(devNr >= 0) && all(devNr <= 255))
    error('ZABERInstrumentDriver:SetHoldCurrent:wrongArgument', ...
          'devNr must be numeric and inbetween [1...255]');
end
if ~(isnumeric(currentDivider) && all((currentDivider == 0) | (currentDivider >= 10) & (currentDivider <= 127)))
    error('ZABERInstrumentDriver:SetHoldCurrent:wrongArgument', ...
          'commanddata must be scalar, numeric and inbetween [0 or 10..127]');
end

% flush serial port input buffer
ZaberFlushBuffer(device);

% send
command = 39;
ZaberSendCommand(device, devNr, command, currentDivider);

% receive reply
[ret err] = ZaberWaitForReturns(device, devNr, command, false);