function bytes = ZaberCmd2Bytes(data)
% cmd2Bytes - Translates a command to its corresponding data bytes.
%
% inputs:
% -------
% data	... one or more (number equals numel(devNr)) command data values
% 
% returns:
% --------
% ret	... 4 bytes representing above command data
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer)
%--------------------------------------------------------------------------

for k = 1 : numel(data)
    if data(k) < 0
       data(k) = data(k) + 256^4; 
    end

    uData = uint32(data(k));

    bytes(k,1) = bitand(uData, 255);
    bytes(k,2) = bitand(bitshift(uData,-8), 255);
    bytes(k,3) = bitand(bitshift(uData,-16), 255);
    bytes(k,4) = bitand(bitshift(uData,-24), 255);
end