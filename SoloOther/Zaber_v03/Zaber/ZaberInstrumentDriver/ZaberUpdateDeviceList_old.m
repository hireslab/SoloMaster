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
    switch device.devNumbers(k,2)
		case 3003
			device.devNames{device.devNumbers(k,1)} = 'T-JOY3';
            
		case 6210
			device.devNames{device.devNumbers(k,1)} = 'T-LSM050A';
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
                device.microStepSize(device.devNumbers(k,1)) = 0.047625e-6 * 64 / ret(3);
			else
				error(['no data returned for device ', num2str(devices(k,1))]);
			end
			
			device.maxPosition(device.devNumbers(k,1)) = 0.05;
			device.maxSpeed(device.devNumbers(k,1)) = 0.007;
			device.isTranslationStage(device.devNumbers(k,1)) = true;
			
        case 6310
			device.devNames{device.devNumbers(k,1)} = 'T-LSM100A';
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
                device.microStepSize(device.devNumbers(k,1)) = 0.047625e-6 * 64 / ret(3);
			else
				error(['no data returned for device ', num2str(devices(k,1))]);
			end
			
			device.maxPosition(device.devNumbers(k,1)) = 0.1;
			device.maxSpeed(device.devNumbers(k,1)) = 0.007;
			device.isTranslationStage(device.devNumbers(k,1)) = true;
         
        case 28  %Added 4.10.2013 CSS
			device.devNames{device.devNumbers(k,1)} = 'T-LA28A';
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
                device.microStepSize(device.devNumbers(k,1)) = 0.09921875e-6 * 64 / ret(3);
			else
				error(['no data returned for device ', num2str(devices(k,1))]);
			end
			
			device.maxPosition(device.devNumbers(k,1)) = 0.028;
			device.maxSpeed(device.devNumbers(k,1)) = 0.004;
			device.isTranslationStage(device.devNumbers(k,1)) = true;            
            
		case 0
			device.devNames{device.devNumbers(k,1)} = 'none';
        otherwise
			device.devNames{device.devNumbers(k,1)} = 'other';
    end
    
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