% ZaberTest.m
%
% Tests for functions of the Zaber instrument driver.
% Refer to the files or "http://zaber.com/wiki/Manuals/T-LSM" for details
% on the firmware.
%
% Refer to "http://www.zaber.com/support/?tab=Device%20ids" for details on
% device IDs, limits and dividers (file ZaberDeviceList.m).
%
% REMARK:
% -------
% device number 0 issues a command to all devices, T-JOY and other
% non-stages do not have the same command set, and thus return errors.
%
% Most commands use ZaberWaitForReturns.m to read replies. Here, device
% number 0 queries all devices if they are ready or still in motion: T-JOY
% returns error 64 (invalid command in this firmware).
% In single device calls devNr = [1 2 ...] these queries are limited to
% translation stages, and no offending commands are sent to T-JOY.
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer)
%--------------------------------------------------------------------------

% clear up workspace
delete(instrfind);
clear;
clc;

% include driver directories
addpath(genpath('ZaberInstrumentDriver'));

% some predefined variables
devNr = 1;
wait=true;

%% open device, build list of devices & start testing functions
s = serial('com3');
zaber = ZaberOpen(s);
% zaber = ZaberOpen(s, 'debugLevel', 1);

% manual update (if necessary)
zaber = ZaberUpdateDeviceList(zaber)

%% echo, home, renumber
[ret err] = ZaberEchoData(zaber, devNr, 3)

[ret err] = ZaberHome(zaber, 0)
[ret err] = ZaberHome(zaber, devNr)
[ret err] = ZaberHome(zaber, devNr, true)
[ret err] = ZaberHome(zaber, devNr, false)
ret = ZaberFlushBuffer(zaber);
[ret err] = ZaberHome(zaber, [1 2 3])

[ret err] = ZaberRenumber(zaber, 0, 0)

[ret err zaber] = ZaberSetAliasNumber(zaber, devNr, 5)
[ret err zaber] = ZaberSetAliasNumber(zaber, [1 2 3], [5 5 6])

%% device specific data

% ZaberWaitForReturns.m queries the device number 0 if it still
% moving, T-JOY answers with error 64 (invalid command in this firmware).
% Use devNr = [1 2 ...] instead of 0 to query all devices 
%

% manipulate current position
[ret err] = ZaberReturnCurrentPosition(zaber, 0)
[ret err] = ZaberReturnCurrentPosition(zaber, devNr)
[ret err] = ZaberReturnCurrentPosition(zaber, [1 2])

[ret err] = ZaberSetCurrentPosition(zaber, devNr, 0.05)
[ret err] = ZaberSetCurrentPosition(zaber, [1 2 3], 0.05)

% return device id, firmware version and power supply voltage
[ret err] = ZaberReturnDeviceId(zaber, 0)
[ret err] = ZaberReturnDeviceId(zaber, devNr)
[ret err] = ZaberReturnDeviceId(zaber, [1 2])

[ret err] = ZaberReturnFirmwareVersion(zaber, devNr)
[ret err] = ZaberReturnFirmwareVersion(zaber, [1 2 3])

[ret err] = ZaberReturnPowerSupplyVoltage(zaber, devNr)
[ret err] = ZaberReturnPowerSupplyVoltage(zaber, [1 2])

% get settings and status
settingNumber=48;
[ret err] = ZaberReturnSetting(zaber, devNr, settingNumber)
[ret err] = ZaberReturnSetting(zaber, [1 2 3], settingNumber)
[ret err] = ZaberReturnStatus(zaber, devNr)
[ret err] = ZaberReturnStatus(zaber, [1 2])

%% movement

% absolute movement
[ret err] = ZaberMoveAbsolute(zaber, 0, 10e-3)

for k = 1:10
	absolutePosition = k * 1e-3;
	[ret err] = ZaberMoveAbsolute(zaber, devNr, absolutePosition)
end
for k = 1:10
	absolutePosition = k * 1e-3;
	[ret err] = ZaberMoveAbsolute(zaber, devNr, absolutePosition, true)
end
for k = 1:10
	absolutePosition = k * 1e-3;
	[ret err] = ZaberMoveAbsolute(zaber, devNr, absolutePosition, false)
end
ret = ZaberReadReplies(zaber, true) % or flush buffer
ret = ZaberFlushBuffer(zaber)

% absolute movement of a group (more than one device with alias 5)
for k = 1:10
	absolutePosition = k * 1e-3;
	[ret err] = ZaberMoveAbsolute(zaber, [5 3], absolutePosition)
end

% relative moevement
for k = 10:-1:-10
	relativePosition = k * 1e-3;
	[ret err] = ZaberMoveRelative(zaber, devNr, relativePosition)
end
for k = 10:-1:-10
	relativePosition = k * 1e-3;
	[ret err] = ZaberMoveRelative(zaber, devNr, relativePosition, true)
end
for k = 10:-1:-10
	relativePosition = k * 1e-3;
	[ret err] = ZaberMoveRelative(zaber, devNr, relativePosition, false)
end
ret = ZaberReadReplies(zaber, true) % or flush buffer
ret = ZaberFlushBuffer(zaber)

% relative movement of a group (more than one device with alias 5)
for k = 10:-1:-10
	relativePosition = k * 1e-3;
	[ret err] = ZaberMoveRelative(zaber, [3 5], relativePosition, true)
end

% simultaneous movement
[ret err] = ZaberMoveRelative(zaber, 1, 0.05, false)
[ret err] = ZaberMoveRelative(zaber, 2, 0.05, false)
[ret err] = ZaberMoveRelative(zaber, 3, 0.05, false)
[data err] = ZaberWaitForReturns(zaber, [1 2 3], 21, true)
ret = ZaberMicroSteps2Position(zaber, [1 2 3], data)

% constant speed
[ret err] = ZaberMoveAtConstantSpeed(zaber, devNr, 0.002)
[ret err] = ZaberStop(zaber, devNr)
[ret err] = ZaberMoveAtConstantSpeed(zaber, [1 2], 0.002)
[ret err] = ZaberStop(zaber, [1 2])
[ret err] = ZaberMoveAtConstantSpeed(zaber, [1 2], [0.002 0.003])
[ret err] = ZaberStop(zaber, [1 2])

% stored position
[ret err] = ZaberStoreCurrentPosition(zaber, devNr, 1)
[ret err] = ZaberStoreCurrentPosition(zaber, [1 2 3], 1)
[ret err] = ZaberStoreCurrentPosition(zaber, [5 3], 1)

[ret err] = ZaberReturnStoredPosition(zaber, devNr, 1)
[ret err] = ZaberReturnStoredPosition(zaber, [1 2 3], 1)

[ret err] = ZaberMoveToStoredPosition(zaber, devNr, 1)
[ret err] = ZaberMoveToStoredPosition(zaber, devNr, 1, true)
[ret err] = ZaberMoveToStoredPosition(zaber, devNr, 1, false)
ret = ZaberReadReplies(zaber, true) % or flush buffer
ret = ZaberFlushBuffer(zaber)
[ret err] = ZaberMoveToStoredPosition(zaber, [1 2 3], 1)

% set acceleration, initial value was 0.0595 m/s^2, read back the value
[ret err] = ZaberSetAcceleration(zaber, devNr, 0.06)
[ret err] = ZaberSetAcceleration(zaber, [1 2 3], 0.06)

[data err] = ZaberReturnSetting(zaber, devNr, 43)
ret = ZaberData2Acceleration(zaber, devNr, data)
[data err] = ZaberReturnSetting(zaber, 0, 43)
ret = ZaberData2Acceleration(zaber, devNr, data)

% set target speed, initial value was 0.006 m/s, read back the value
[ret err] = ZaberSetTargetSpeed(zaber, devNr, 0.005)
[data err] = ZaberReturnSetting(zaber, devNr, 42)
ret = ZaberData2Speed(zaber, devNr, data)

[ret err] = ZaberSetTargetSpeed(zaber, [1 2 3], [0.004 0.005 0.006])
[data err] = ZaberReturnSetting(zaber, 1, 42);
ret = ZaberData2Speed(zaber, 1, data)
[data err] = ZaberReturnSetting(zaber, 2, 42);
ret = ZaberData2Speed(zaber, 2, data)
[data err] = ZaberReturnSetting(zaber, 3, 42);
ret = ZaberData2Speed(zaber, 3, data)

%% memory & settings
[ret err] = ZaberReadOrWriteMemory(zaber, devNr, iswrite, address, outbyte)

[ret err] = ZaberRestoreSettings(zaber, 0, 0)
[ret err] = ZaberHome(zaber, 0)                     % homeing is necessary
[ret err] = ZaberRestoreSettings(zaber, devNr, 0)
[ret err] = ZaberHome(zaber, devNr)
[ret err] = ZaberRestoreSettings(zaber, [1 2 3], 0)
[ret err] = ZaberHome(zaber, [1 2 3])

[ret err] = ZaberSetHoldCurrent(zaber, devNr, 60)
[ret err] = ZaberSetHoldCurrent(zaber, [1 2], [60 65])

[ret err] = ZaberSetRunningCurrent(zaber, devNr, 23)
[ret err] = ZaberSetRunningCurrent(zaber, [1 2 3], [23 24 23])

[ret err] = ZaberSetHomeOffset(zaber, devNr, 0.01)
[ret err] = ZaberSetHomeOffset(zaber, [5], 0.01)

[ret err] = ZaberSetHomeSpeed(zaber, devNr, 0.006)
[ret err] = ZaberSetHomeSpeed(zaber, [1 2], 0.006)

[ret err] = ZaberSetLockState(zaber, devNr, true)
[ret err] = ZaberSetLockState(zaber, [1 2 3], [true false false])
[ret err] = ZaberSetLockState(zaber, 0, false)

[ret err] = ZaberSetMaximumPosition(zaber, 0, 0.05)
[ret err] = ZaberSetMaximumPosition(zaber, devNr, 0.05)
[ret err] = ZaberSetMaximumRelativeMove(zaber, devNr, 0.01)

[ret err zaber] = ZaberSetMicroStepResolution(zaber, devNr, 64)
[ret err zaber] = ZaberSetMicroStepResolution(zaber, [1 2 3], [64 128 32])
[ret err zaber] = ZaberSetMicroStepResolution(zaber, 0, 64)

% still to test!!!
[ret err] = ZaberSetDeviceMode(zaber, devNr, mode)

%% close device
ZaberClose(zaber);
clear zaber;