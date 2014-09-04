function cmd = bytes2Cmd(cmdBytes)
% bytes2Cmd - Translates four command data bytes to a single value.
%
% inputs:
% -------
% data	... 4 bytes representing above command data
% 
% returns:
% --------
% ret	... command data
%
%-file history-------------------------------------------------------------
% 21.04.2012: initial creation (D.Hofer)
%--------------------------------------------------------------------------

cmd = cmdBytes(1) + 256 * cmdBytes(2) + 256^2 * cmdBytes(3) + 256^3 * cmdBytes(4);

% handle negative return values
if cmdBytes(4) > 127
    cmd = cmd - 256^4;
end