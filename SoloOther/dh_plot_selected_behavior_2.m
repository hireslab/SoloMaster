function dh_plot_selected_behavior_2(av_range, cuts, varargin)

% dh_plot_selected_behavior(av_range, cuts, varargin) will plot a
% perfomance plot form the original behavior files

% av_range: range for the moving average. ~50 works well
% cuts= number of trials to cut beofer and after i.e. [10 20]
% varargin: path to the folder   
%the name of the protcol has to adapted for each situationin :
%dh_solo_moving_pc_original
%DH 11.5.2009

if nargin==2
    [first_behav_prefix behav_path] = uigetfile('*.mat', 'select first source prefix');
elseif nargin>2
    cd(varargin{1})
    behav_path=[varargin{1} filesep];
elseif nargin==0
    av_range=50;
    cuts=[10 20];
    [first_behav_prefix behav_path] = uigetfile('*.mat', 'select first source prefix');
end




data_file=selectFilesFromList(behav_path, '*.mat');

x=[]; 
y=[];
z=[];

%le=0;
m=0; 
l_x=[];
%a=[];
for i=1:length(data_file)
    solo_filename=[behav_path data_file{i}];
    [trialnum,all, nogo_trial_num, fa_perf, go_trial_num, hit_perf] = dh_solo_moving_pc_original_4(solo_filename, av_range,cuts);
    a=[];
    b=[];
    c=[];
    
    a(:,1)=trialnum+m;
    b(:,1)=nogo_trial_num+m;
    c(:,1)=go_trial_num+m;
    
    a(:,2)=all; 
    b(:,2)=fa_perf;
    c(:,2)=hit_perf;
    
    label_location(i)=m+(max(trialnum)/2);
    m=a(end,1);
    l_beg(i)=a(1,1);
    
    x=[x, a'];
    y=[y, b'];
    z=[z, c'];
    
    
   
    %le=le+m;
    l_end(i)=m;
    
end
% 
figure; hold on
hax1=plot(x(1,:), x(2,:));
set(hax1, 'Marker', 'o', 'LineStyle', 'none',  'Color', 'b');hold on;
hax2=plot(y(1,:), y(2,:));
set(hax2,  'Color', 'r', 'Marker', '.', 'LineStyle', 'none');hold on;
hax3=plot(z(1,:), z(2,:));
set(hax3, 'Marker', '.', 'Color', 'g', 'LineStyle', 'none');hold on;


% figure; hold on
% hax1=plot(x(1,:), x(2,:));
% set(hax1, 'linewidth', 3, 'Color', 'b');hold on;
% hax2=plot(y(1,:), y(2,:));
% set(hax2,  'Color', 'r', 'linewidth', 1);hold on;
% hax3=plot(z(1,:), z(2,:));
% set(hax3, 'Color', 'g', 'linewidth', 1);hold on;

for i=1:length(data_file)
    %plot([l_end(i) l_end(i)],[0 1], 'r-', 'linewidth', 1);
    if i>1 
        fill([l_end(i-1) l_beg(i) l_beg(i) l_end(i-1)],[0 0 1 1], 'w')
    end
    %plot legend
    label{i}=data_file{i}(end-10:end-5);
    
end


plot(gca, [0:100:2000], 0.5, 'k.')
set(gca, 'Xtick', label_location, 'XTickLabel', label);
title(data_file{1}(end-18:end-12));

ylim([0 1]); xlim([0 x(1, end)]); xlabel('sessions'); ylabel('performance');

end


