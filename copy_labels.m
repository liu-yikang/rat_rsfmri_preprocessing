% Copy IC labels to the database folder

% Author: Yikang Liu
% Last modified data: 11/05/2019

%%%%%%%%%%%%%% set parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_dir = '/path/to/data';
% database folder
ica_dir = '/path/to/temporary/ica';
% temporary ICA folder
subjname_len = 6 % length of subject folder name
scanname_len = 2 % length of scan file name (postfix excluded)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
list = dir(fullfile(ica_dir, 'labels', '*csv'));
cd(fullfile(ica_dir, 'labels'));
for i = 1:length(list)
    copyfile(list(i).name, fullfile(data_dir, list(i).name(1:subjname_len), ...
        'rfmri_intermediate', [list(i).name(subjname_len+2:subj_name_len+1+scanname_len), '.gift_ica'], 'labels.csv'));
end