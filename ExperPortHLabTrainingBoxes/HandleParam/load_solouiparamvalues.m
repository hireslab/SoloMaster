% [outflag] = load_solouiparamvalues(ratname, varargin)
% Loads a 'settings' file, containing the value of all UI Solo params
% for a particular object. The object is determined either through
% determine_owner.m (which usually returns the class of the calling
% object), or, if the optional parameter 'child_protocol', is passed
% in, by the class of the value of the passed child_protocol.
%   
% All the settings files are stored in Solo_datadir/Settings, where
% Solo_datadir is a global variable containing the pathname of the
% relevant directory.
%

function [outflag] = load_solouiparamvalues(ratname, varargin)

pairs = { ...
    'child_protocol', [] ; ...
    };
parse_knownargs(varargin, pairs);

if isempty(child_protocol),
    owner = determine_owner;
else
    owner = class(value(child_protocol));   % the child protocol owns all vars
    %owner = c(2:end);
end;

   % ---  DEFINE THE SETTINGS DIRECTORY  ---------
   global Solo_datadir;
   if isempty(Solo_datadir), 
      Solo_datadir=[pwd filesep '..' filesep 'SoloData'];
   end;
   settings_path = [Solo_datadir filesep 'Settings'];
   if ~exist(settings_path, 'dir'),
      success = mkdir(Solo_datadir, 'Settings');
      if ~success, error(['Couldn''t make directory ' settings_path]); end;
   end;
   if settings_path(end)~=filesep, settings_path=[settings_path filesep]; end;

   
   % --- DETERMINE THE FULL SET OF UI HANDLES THAT THE OWNER OBJECT HAS ---
   handles = get_sphandle('owner', owner);
   k = zeros(size(handles));
   for i=1:length(handles),
      if ~isempty(get_type(handles{i}))  &&  ...
             ~ismember(get_type(handles{i}), {'disp' 'pushbutton'}),
         k(i) = 1;
      end;
   end;
   handles = handles(find(k));
   

   % --- FIND FULLNAME, THE LATEST FILENAME THAT MATCHES THE OWNER AND THE RAT
   rat_dir = [settings_path ratname];
   if ~exist(rat_dir)
       success = mkdir(settings_path, ratname);
       if ~success, error(['Couldn''t make directory ' rat_dir]); end;      
   end;    
  if rat_dir(end)~=filesep, rat_dir=[rat_dir filesep]; end;
   u = dir([rat_dir 'settings_' owner '_' ratname '*.mat']);
   if ~isempty(u),
      [filenames{1:length(u)}] = deal(u.name); filenames = sort(filenames');
      fullname = [rat_dir filenames{end}]; 
   else
      fullname = [rat_dir 'settings_' owner '_' ratname '_' ...
                  yearmonthday 'a'];
   end;

   % --- USER DIALOG TO CHOOSE FILE TO LOAD; DEFAULT IS FULLNAME
   rn = ratname;
   [fname, pname] = ...
       uigetfile({['settings_' owner '*' rn '*.mat'], ...
                  ['settings_' owner ' ' rn ' files (' owner '*' rn '*.mat)'] ; ...
                  ['*' rn '*.mat'], [rn ' files (*' rn '*.mat)'] ; ...
                  ['*' owner '*.mat'], [owner ' files (*' owner '*.mat)'] ; ...
                  '*.mat',  'All .mat files (*.mat)'}, ...
                 'Load settings', fullname);
   if fname == 0, outflag = 0; return; end;
   load([pname fname]);

   % --- SET POSITION OF MAIN FIGURE BELONGING TO THIS PROTOCOL ---
   protocol_name = get_sphandle('owner', owner, 'name', 'protocol_name');
   if ~isempty(protocol_name) && exist('fig_position', 'var') && ...
        ~isempty(fig_position),
      protocol_name = protocol_name{1};
      % Get the main figure for this protocol and set its position
      f = findobj(get(0, 'Children'), 'Name', value(protocol_name));
      set(f, 'Position', fig_position); drawnow;
      % If window is too big, Macs automatically move it after drawnow and
      % can be a little off-screen. Check the position and correct if needed.
      pos = get(f, 'Position');
      if pos(2)<0, % If bottom is below screen make window shorter and move up
         pos(4) = pos(4) + pos(2); pos(2) = 0;
         set(f, 'Position', pos); drawnow;
      end;
   end;

   % --- NOW SET THE VALUES OF THE HANDLES ---
   fnames = fieldnames(saved);
   % Make a place to store all the SPHs that we find, for future use with 
   % autoset. Keys will be fnames, elements will the existing SPHs.
   myhandles = cell2struct(cell(size(fnames)), fnames, 1);   
   updated_handles = {}; % A list of handles that had their values
                         % updated. This will be used below for
                         % calling all the corresponding callbacks. 
   for i=1:length(fnames),
      % For each saved value, use the name to find the corresponding
      % existing handle from within the current owner's handles. 
      % get_sphandle.m is the service to do this with. 
      % However, get_sphandle does regexp's (see regexp.m); so, for an exact
      % match to the full string, we specify '^' (start of string) and '$'
      % (end of string) at the start and end, respectively:
      this_handle = ...
          get_sphandle('fullname', ['^' fnames{i} '$'], 'handlelist', handles);

      if ~isempty(this_handle), % If there is a target handle to load to 
         % Store for later use:
         myhandles.(fnames{i}) = this_handle;
         try,
            this_handle{1}.value = saved.(fnames{i});
            % Now store the handle in a list of updated handles; this will
            % be used for callbacks below.
            updated_handles = [updated_handles ; this_handle(1)];
         catch, % In case the handle couldn't be loaded up for some reason:
            fprintf(2, '\n\n   *** Warning! ***\n');
            fprintf(2, ['Couldn''t set the value of "%s" while loading:\n' ...
                        'you''ll have to set it yourself, manually.\n'], ...
                    fnames{i});
            if ischar(saved.(fnames{i})),
               fprintf(2, '  Intended value was "%s"\n\n', saved.(fnames{i}));
            elseif isnumeric(saved.(fnames{i})),
               fprintf(2, '  Intended value was %g\n\n', saved.(fnames{i}));
            end;
            fprintf(2, 'The error message was "%s"\n\n\n', lasterr);
         end;
      end;
   end;

   
   % --- NOW CHECK FOR HANDLES THAT WERE NOT UPDATED BUT HAVE A DEFAULT
   % --- RESET VALUE 

   unloaded_handles = setdiff_sph(handles, updated_handles);
   for i=1:length(unloaded_handles),
      % If there is a defined default reset value for the handle, this
      % function call will now set its value to that:
      restore_default_reset_value(unloaded_handles{i});
   end;
   
   
   % --- CALL ALL NECESSARY CALLBACKS FROM CHANGES TO HANDLE VALUES
   % First, get a list of all the callbacks. First column is number of
   % callback args.
   cback_list = cell(rows(updated_handles), 2);
   ncalls        = 0;
   for i=1:length(updated_handles), 
      cback = get_callback(updated_handles{i});
      if ~isempty(cback), % We have an explicit callback
         % First make sure cback_list has the requisite number of columns
         if cols(cback) > cols(cback_list)
            emptycell = cell(rows(cback_list), cols(cback)-cols(cback_list));
            emptycell(:) = {''};
            cback_list = [cback_list emptycell];
         end;
         % Now store # of args and actual callback
         cback_list(ncalls+1:ncalls+rows(cback),1) = {cols(cback)-1};
         cback_list(ncalls+1:ncalls+rows(cback), 2:1+cols(cback)) = cback;
         ncalls = ncalls+rows(cback);
      else % Implicit callback for method with same name as SPH
         if exist([owner filesep get_name(updated_handles{i}) '*.m'], 'file'),
            ncalls = ncalls+1;
            cback_list{ncalls,1} = 0;
            cback_list{ncalls,2} = get_name(updated_handles{i});
         end;
      end;
   end;
   cback_list = cback_list(1:ncalls,:);
   if ~isempty(cback_list),
      if iscellstr(cback_list(:,cols(cback_list)))
         cback_list = uniquecell(cback_list);
      else
         cback_list = uniquecell_nonsquare(cback_list);
      end;
   end;
   %
   % Ok, now call all the callbacks...
   % First make an empty object:
   try
       if strcmp(owner(1),'@')
          obj = feval(owner(2:end),  'empty');
       else
           obj = feval(owner, 'empty');
       end;
   catch
      fprintf(2, ['When a SoloParamHandle is owned by an object, ' ...
                  'that object must allow constuction with a single '... 
                  ' (''empty'') argument\n']);
      rethrow(lasterror)
   end;
   % Now call them all:
   for i=1:rows(cback_list),
      parse_and_call_sph_callback(obj, owner, '', ...
                                  cback_list(i,2:cback_list{i,1}+2));
   end;
      

   % --- CHECK FOR AUTOSET STATEMENTS; EXECUTE THEM IF NECESSARY
   if exist('saved_autoset', 'var'),
      fnames = fieldnames(saved_autoset);
      for i=1:length(fnames),
         if isfield(myhandles, fnames{i}),
            this_handle = myhandles.(fnames{i});
         else
            % get_sphandle does regexp's (see regexp.m); for an exact match
            % to the full string, we specify '^' (start of string) and '$'
            % (end of string) at the start and end, respectively:      
            this_handle = get_sphandle('fullname', ['^' fnames{i} '$'], ...
                                                   'handlelist', handles);
         end;
         if ~isempty(this_handle), this_handle = this_handle{1}; end;
         autoset_string = strtrim(saved_autoset.(fnames{i}));
         
         if ~isempty(this_handle), % If there is a target handle to load to 
            set_autoset_string(this_handle, autoset_string);
            if isempty(autoset_string),
               RegisterAutoSetParam(this_handle, 'delete');
            else
               RegisterAutoSetParam(this_handle, 'add');
            end;
         end;
      end;
   end;
   
   
   
   outflag = 1;
   return;
   
