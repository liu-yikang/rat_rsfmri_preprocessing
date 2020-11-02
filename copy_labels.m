% Copy IC labels to the database folder

% Author: Yikang Liu
% Last modified data: 11/05/2019

%%%%%%%%%%%%%% set parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_dir = '/home/project/organize_database/Rat_Database_AllBaseline';
% database folder
ica_dir = '/home/project/organize_database/test';
% temporary ICA folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
list = dir(fullfile(ica_dir, 'labels', '*csv'));
cd(fullfile(ica_dir, 'labels'));
for i = 1:length(list)
    copyfile(list(i).name, fullfile(data_dir, list(i).name(1:6), ...
        'rfmri_intermediate', [list(i).name(8:9), '.gift_ica'], 'labels.csv'));
end