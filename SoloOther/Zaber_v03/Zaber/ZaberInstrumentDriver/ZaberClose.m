function ZaberClose(device)
% ZaberClose - Close a Zaber device, actually only its serial port.
%
% inputs:
% -------
% device	... a Zaber device object
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer)
%--------------------------------------------------------------------------

fclose(device.serialPort);