function ret = ZaberUpdateDeviceList(device)
% UpdateDeviceList - Get all relevant information on connected devices and
% assign some appropriate parameters.
%
% inputs:
% -------
% device	... a Zaber device object
% 
% returns:
% --------
% ret		... a newly configured Zaber device object
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer)
% 16.01.2013: device.devNumbers from device 1 to max(devNumbers)
% 10.07.2013: support all T-LSM compatible devices (firmware 5.29)
%             replaced switch-case with cell-array 'ZaberDevices'
%--------------------------------------------------------------------------

% get serial port object
s = device.serialPort;

% get common data
if s.Bytesavailable > 0
	fread(s, s.BytesAvailable, 'uint8');
end

% clear relevant fields
device.devNumbers = [];				% device numbers
device.microSteps = [];				% microsteps per full step
device.microStepSize = [];			% movement per microstep
device.defaultMicroStepSize = [];	% max. movement of all stages
device.maxPosition = [];			% max. position (length)
device.maxSpeed = [];
device.devNames = {};				% device names
device.nrOfDevices = 0;				% number of devices found
device.isTranslationStage = [];		% boolean flag indicating stages
device.aliases = [];				% alias numbers
device.isInitialized = false;		% boolean flag indicating init is done

% search device ids, i.e. ask all devices for their id
fwrite(s, [0 50 0 0 0 0], 'uint8', 'async');

if device.debugLevel > 0
    disp([num2str(toc(device.time)) ' --> ' num2str([0 50 0 0 0 0]) ' (send return device id)']);
end

% wait some time
t = cputime;
while(cputime - t < 0.5) ; end;

% read replies, build device.devNumbers array
devIDs = [];
while (s.BytesAvailable > 5) || isempty(devIDs)
    byteid = fread(s, 6, 'uint8');
	id = ZaberBytes2Cmd(byteid(3:6));
	if byteid(2) == 50
		devIDs(byteid(1)) = id;
    end
end
device.devNumbers = [1:numel(devIDs); devIDs].';

% get number of devices, define alias cell array
device.nrOfDevices = numel(devIDs);
device.isTranslationStage = false(1,device.nrOfDevices);
device.aliases = cell(1,device.nrOfDevices);

% name devices
for k = 1:size(device.devNumbers, 1)
	if device.devNumbers(k,2) == 0
		device.devNames{device.devNumbers(k,1)} = 'none';
	else
		device.devNames{device.devNumbers(k,1)} = 'other';
	end
	
	load('ZaberDevices.mat', 'ZaberDevices');
	for m = 1 : length(ZaberDevices)
        % load firmware presets
		if device.devNumbers(k,2) == ZaberDevices{m}{1}			
			device.devIds(device.devNumbers(k,1)) = ZaberDevices{m}{1}; %  1 Device_Id
			device.devNames{device.devNumbers(k,1)} = ZaberDevices{m}{2}; %  2 Product_Name
			device.mode(device.devNumbers(k,1)) = ZaberDevices{m}{3}; %  3 Mode(cmd 40)
			device.range(device.devNumbers(k,1)) = ZaberDevices{m}{4}; %  4 Range(cmd 44)
			device.fwPositionOnPowerUp(device.devNumbers(k,1)) = ZaberDevices{m}{5}; %  5 Position_on_Powerup
			device.fwTargetSpeed(device.devNumbers(k,1)) = ZaberDevices{m}{6}; %  6 Target_Speed(cmd 42)
			device.fwHomeSpeed(device.devNumbers(k,1)) = ZaberDevices{m}{7}; %  7 Home_Speed(cmd 41)
			device.fwAcceleration(device.devNumbers(k,1)) = ZaberDevices{m}{8}; %  8 Acceleration(cmd 43)
			device.fwCurrentRun(device.devNumbers(k,1)) = ZaberDevices{m}{9}; %  9 Current_Run (38)
			device.fwCurrentHold(device.devNumbers(k,1)) = ZaberDevices{m}{10}; % 10 Current_Hold (39)
			device.fwCurrentLimit(device.devNumbers(k,1)) = ZaberDevices{m}{11}; % 11 Current_Limit 
			device.fwMicroStepSize(device.devNumbers(k,1)) = ZaberDevices{m}{12}; % 12 microstepping
			device.maxSpeed(device.devNumbers(k,1)) = ZaberDevices{m}{13}; % 13 maxSpeed
			device.isTranslationStage(device.devNumbers(k,1)) = ZaberDevices{m}{14}; % 14 isTranslationStage
			device.devType{device.devNumbers(k,1)} = ZaberDevices{m}{15}; % 15 type			

			% calculate maximum position = range * microstep size
			device.maxPosition(device.devNumbers(k,1)) = device.range(device.devNumbers(k,1)) * device.fwMicroStepSize(device.devNumbers(k,1));
			
			% calculate missing microstep size (in case there are not 64 microsteps per full step)
            % get stepper resolution
			fwrite(s, [device.devNumbers(k,1) 53 37 0 0 0], 'uint8');
            if device.debugLevel > 0
                disp([num2str(toc(device.time)) ' --> ' num2str([device.devNumbers(k,1) 53 37 0 0 0]) ' (send return microstep setting)']);
            end
            
            ret = fread(s, 6, 'uint8');
            if device.debugLevel > 0
                disp([num2str(toc(device.time)) ' <-- ' num2str(ret') ' (receive microstep setting)']);
            end
            
            % get microstepsize, default stepsize from datasheet (in [m],
            % 1/64 full step)
			if numel(ret) > 5
				device.microSteps(device.devNumbers(k,1)) = ret(3);
                device.microStepSize(device.devNumbers(k,1)) = device.fwMicroStepSize(device.devNumbers(k,1)) * 64 / ret(3);
			else
				error(['no data returned for device ', num2str(devices(k,1))]);
			end
		end
	end
	clear ZaberDevices;
		
	% get alias number
	if device.devNumbers(k,2) > 0
		[alias err] = ZaberReturnSetting(device, device.devNumbers(k,1), 48);
        if alias(2) > 0
            if device.devNumbers(k,1) > length(device.aliases)
                device.aliases{alias(:,2)} = [];
            end
            if alias(:,2) > length(device.aliases)
                device.aliases{alias(:,2)} = [];
            end
            % the device aliases itself
            device.aliases{device.devNumbers(k,1)} = [device.aliases{alias(:,1)}, device.devNumbers(k,1)];
            % and here the final alias
            device.aliases{alias(:,2)} = [device.aliases{alias(:,2)}, device.devNumbers(k,1)];
        else
            % there is no alias, so the alias equals the device number
            device.aliases{device.devNumbers(k,1)} = [device.aliases{device.devNumbers(k,1)}, device.devNumbers(k,1)];
        end
	end
end

% display the results
disp('DevNr, DevName, Microsteps');
for k = 1:size(device.devNumbers, 1)
	if device.devNumbers(k,2) > 0
		disp([num2str(device.devNumbers(k,1)), ', ' ...
			device.devNames{device.devNumbers(k,1)} ', ' ...
			num2str(device.microSteps(device.devNumbers(k,1)))]);
	end
end
disp(' ');

% choose max stepsize as a default
device.defaultMicroStepSize = max(device.microStepSize(:));

% set initialization ready flag
device.isInitialized = true;

% define return statement
ret = device;