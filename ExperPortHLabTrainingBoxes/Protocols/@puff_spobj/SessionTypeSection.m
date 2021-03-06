% [x, y] = SessionTypeSection(obj, action, x, y)
%
% Section that takes care of choosing the stage of training.
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it.
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
%            'get_session_type'  Returns string giving session type.
%
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%
% x        When action = 'get_session_type', x will be string giving name of
%          session type.
%

function [x, y] = SessionTypeSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   
   switch action
    
    case 'init',   % ------------ CASE INIT ----------------
      % Save the figure and the position in the figure where we are
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

      MenuParam(obj, 'SessionType', {'Licking','Pole-conditioning','Periodic_Puff',...
          'Water-Valve-Calibration','Beam-Break-Indicator','FlashLED'},'Beam-Break-Indicator', x, y);
      
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', {'SessionType'});
      SoloFunctionAddVars('SidesSection', 'ro_args', {'SessionType'});
      SoloFunctionAddVars('state35', 'ro_args', 'SessionType');
      next_row(y, 1);
      SubheaderParam(obj, 'title', 'Type of Session', x, y);
      next_row(y, 1.5);
      
%     case 'get_session_type'  
%       x = value(SessionType);
      return;
       
      
    case 'reinit',   % ------- CASE REINIT -------------
      currfig = gcf; 

      % Get the original GUI position and figure:
      x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

      delete(value(myaxes));
      
      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
                      'fullname', ['^' mfilename]);

      % Reinitialise at the original GUI position and figure:
      [x, y] = feval(mfilename, obj, 'init', x, y);

      % Restore the current figure:
      figure(currfig);      
   end;
   
   
      