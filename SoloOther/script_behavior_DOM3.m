%figure all behaviors: 
dh_plot_selected_behavior_2(50, [10 2], 'G:\_data\Dom3_behavior\JF27332');
dh_plot_selected_behavior_2(50, [10 2] , 'G:\_data\Dom3_behavior\JF25609');
dh_plot_selected_behavior_2(50, [10 2] , 'G:\_data\Dom3_behavior\JF25607');
dh_plot_selected_behavior_2(50,[10 2] , 'G:\_data\Dom3_behavior\JF26706');





solo_filename='G:\_data\Dom3_behavior\JF27332\data_@pole_detect_nx2obj_JF27332_100115a.mat';   [trialnum,a] = dh_solo_moving_pc_original(solo_filename, 50,[2 10]);
total=[a'];%, c', d', e', f', g', h'];

figure;
hax=plot(total);
set(hax, 'linewidth', 3, 'Color', 'b');hold on;


flush; 
solo_filename='G:\_data\Dom3_behavior\JF27332\data_@pole_detect_nx2obj_JF27332_100121a.mat';   
trim=[10 10];
span=50;


[trialnum,y, nogo_trial_num, nogo_perf, go_trials_num, go_perf] = dh_solo_moving_pc_original_4(solo_filename, span, trim)
%

figure; hold on
plot(trialnum,y, 'b')
plot(nogo_trial_num, nogo_perf,'r');
plot(go_trials_num, go_perf, 'g')
