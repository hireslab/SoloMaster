% ZaberRandomTest.m
%
% Long term test for Zaber translation stages. Move to random position over
% the course of half an hour.
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

s = serial('com4');
zaber = ZaberOpen(s, 'debugLevel', 1)
ret = ZaberUpdateDeviceList(zaber)

tStart = tic
while toc(tStart) < 1800
	position = rand() * 0.1;
	[ret err] = ZaberMoveAbsolute(zaber, 5, position);
	disp([num2str(position) ' --> ' num2str(ret)]);
end

ZaberClose(zaber);
%delete('zaber');