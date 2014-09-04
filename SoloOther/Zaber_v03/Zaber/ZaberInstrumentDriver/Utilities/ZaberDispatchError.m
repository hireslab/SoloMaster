function dispatchError(device, err)
% dispatchError - Searches the error list and displays some info on the
% error. In debug levels greater than 0, throw an error.
%
% inputs:
% -------
% device	... a Zaber device object
% err		... an error number
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer)
%--------------------------------------------------------------------------

% search through device.errors
for k = 1 : length(device.errors)
	if device.errors{k,1} == err
		% text output
		disp('the device returned an error:');
		disp([num2str(device.errors{k,1}) ' - ' device.errors{k,2} ': ' device.errors{k,3}]); 

		% throw error
		if (device.debugLevel > 0)
			error(['ZABERInstrumentDriver:'  device.errors{k,2}], ...
			device.errors{k,3});
		end
	end
end