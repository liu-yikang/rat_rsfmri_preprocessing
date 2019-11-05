%% copy out ICA results for manual labeling
data_dir = '/home/project/organize_database/Rat_Database_AllBaseline';
ica_dir = '/home/project/organize_database/test';
mkdir(ica_dir);
rat_list = dir(fullfile(data_dir, 'rat*'));
for i = 1:length(rat_list)
    scan_list = dir(fullfile(data_dir, rat_list(i).name, 'rfmri_intermediate', '*smoothed.nii'));
    for j = 1:length(scan_list)
        copyfile(fullfile(scan_list(j).folder, [scan_list(j).name(1:2), '.gift_ica']),...
            fullfile(ica_dir, [rat_list(i).name, '_', scan_list(j).name(1:2)]));
    end
end

%% plot ICs
list = dir(ica_dir);
list(1:2) = [];
data_dir = '/home/project/organize_database/Rat_Database_AllBaseline';

for i = 1:length(list)
    cd(fullfile(list(i).folder, list(i).name));
    mkdir('report');
    load('ica__ica.mat');
    load('ica__ica_br1.mat');
    tc = compSet.tc';
    
    for j = 1:50
        
        f = figure('visible', 'off');
        show_brain_map(icasig(j,:),[],1.1,max(icasig(j,:)),0,3:18,1,f);colormap('jet');colorbar;
        export_fig(fullfile(list(i).folder, list(i).name, 'report', ['ic', num2str(j),'_map.tif']));
        close all;
        
        figure('visible', 'off');
        subplot(3,1,1);
        spec = abs(fft(tc(:, j)));
        plot(0:0.5/(round(length(spec)/2)-1):0.5, spec(1:round(length(spec)/2)));
        xlabel('f (Hz)');
        subplot(3,1,2);
        plot(tc(:, j));
        f = gcf;
        f.Position(3:4) = [1500, 900];
        
        motion = load(fullfile(data_dir, list(i).name(1:6), 'rfmri_intermediate', ...
            [list(i).name(8:9), '_motion.txt']));
        motion = (motion - repmat(mean(motion,1), size(motion,1),1))./repmat(std(motion,1), size(motion,1),1);
        subplot(3,1,3);
        plot(motion);
        
        export_fig(fullfile(list(i).folder, list(i).name, 'report', ['ic', num2str(j),'_tc.tif']));
        close all;
    end
end

%% copy back labeled ICA results
ica_dir = '/home/yliu/projects/organize_database/ica/indi_clean_wo_nr_sm7';
list = dir(fullfile(ica_dir, 'labels', '*xlsx'));
cd(fullfile(ica_dir, 'labels'));
for i = 1:length(list)
    copyfile(list(i).name, fullfile(data_dir, ['rat', list(i).name(1:6)], ...
        'rfmri_intermediate', [list(i).name(8:9), '.gift_ica'], 'labels.xlsx'));
end