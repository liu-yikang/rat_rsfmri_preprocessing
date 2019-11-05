list = dir('/home/yliu/projects/organize_database/data/ica_clean_added_data2/rat*');
data_dir = '/home/yliu/projects/organize_database/data/Rat_Database_AllBaseline';

for i = 1:length(list)
    cd(fullfile(list(i).folder, list(i).name));
    mkdir('report');
    load('ica__ica.mat');
    load('ica__ica_br1.mat');
    tc = compSet.tc';
    
    for j = 1:50
        
        close all;
        show_brain_map(icasig(j,:),[],1.1,max(icasig(j,:)),0,3:18,1);colormap('jet');colorbar;
        export_fig(fullfile(list(i).folder, list(i).name, 'report', ['ic', num2str(j),'_map.tif']));
        close all;
        
        subplot(3,1,1);
        spec = abs(fft(tc(:, j)));
        plot(0:0.5/(round(length(spec)/2)-1):0.5, spec(1:round(length(spec)/2)));
        xlabel('f (Hz)');
        subplot(3,1,2);
        plot(tc(:, j));
        f = gcf;
        f.Position(3:4) = [1500, 900];
        
        motion = load(fullfile(data_dir, list(i).name(1:6), 'rfmri_intermediate', ...
            [list(i).name(8:9), '_despiked_registered_motion.txt']));
        motion = (motion - repmat(mean(motion,1), size(motion,1),1))./repmat(std(motion,1), size(motion,1),1);
        subplot(3,1,3);
        plot(motion);
        
        export_fig(fullfile(list(i).folder, list(i).name, 'report', ['ic', num2str(j),'_tc.tif']));
        close all;
    end
end