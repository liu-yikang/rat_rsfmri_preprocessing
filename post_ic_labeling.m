data_dir = '/home/yliu/projects/organize_database/data/Rat_Database_AllBaseline';
brain_mask = spm_read_vols(spm_vol(which('brain_mask_64x64.nii')));

TR = 1;
low_cutoff = 0.01;
high_cutoff = 0.1;

%% 
% rat_list = dir(fullfile(data_dir, 'rat*'));
rat_num = [73,88,89,90,91,34,37,39,51,53,57,59,68];
for i_rat = 1:length(rat_num) %length(rat_list)
    % cd(fullfile(data_dir, rat_list(i_rat).name, 'rfmri_intermediate'));
    
    cd(fullfile(data_dir, ['rat', num2str(rat_num(i_rat), '%.3d')], 'rfmri_intermediate'));
    scan_list = dir('*smoothed.nii');
    
    for i_scan = 1:length(scan_list)
        
        % cd(fullfile(data_dir, rat_list(i_rat).name, 'rfmri_intermediate'));
        cd(fullfile(data_dir, ['rat', num2str(rat_num(i_rat), '%.3d')], 'rfmri_intermediate'));
        scan_name = scan_list(i_scan).name(1:2);
        
%         try
%             movefile([scan_name, '_despiked_registered_aligned_sm7_ica.nii'], [scan_name, '.gift_ica/']);
%         catch
%             fprintf('rat %.3d, %.2d, sm7_ica not found\n', rat_num(i_rat), i_scan);
%         end
        
        % load IC time courses and labels
        x = load(fullfile([scan_name, '.gift_ica'], 'ica__ica_br1.mat'));
        tc = x.compSet.tc';
        tc = (tc-repmat(mean(tc), size(tc,1), 1))./repmat(std(tc), size(tc,1), 1);
%         try
%             movefile([scan_name, '.gift_ica/rat', num2str(rat_num(i_rat), '%.3d'), '_', scan_name, '.xlsx'], ...
%                 [scan_name, '.gift_ica/', 'labels.xlsx']);
%         catch
%             fprintf('rat %.3d, %.2d, labels not found\n', rat_num(i_rat), i_scan);
%         end
        label_tab = xlsread(fullfile([scan_name, '.gift_ica'], 'labels.xlsx'));
        bad_index = label_tab(:,3) == 1;
        
        % load motion param and WM/CSF signal
        x = load([scan_name, '_despiked_registered_aligned_smoothed_regressors.mat']);
        regressors = x.regressors;
        
        % load smoothed image
        nii = load_nii(scan_list(i_scan).name);
        img = nii.img;
        
        % soft regression
        img=rsfmri_regression(img,regressors,brain_mask);
        for c = 1:size(tc, 2)
            [~,~,tc(:,c)] = regress(tc(:,c), regressors(:,1:6));
        end
        img_2d = reshape(img, [], size(img,4));
        img_2d_brain = img_2d(brain_mask(:)>0, :);
        for i_vxl = 1:size(img_2d_brain, 1)
            beta = regress(img_2d_brain(i_vxl, :)', tc);
            img_2d_brain(i_vxl, :) = (img_2d_brain(i_vxl, :)' - tc(:,bad_index)*beta(bad_index,1))';
        end
        img_2d(brain_mask(:)>0, :) = img_2d_brain;
        img = reshape(img_2d, size(img,1), size(img,2), size(img,3), size(img,4));
        img(isnan(img))=0;
        
        % perform bandpass filtering
        img=rsfmri_bandpassfilt(img,TR,4,low_cutoff,high_cutoff,brain_mask);
        img(isnan(img))=0;
        nii.img = img;
        preproc_dir = fullfile(data_dir, ['rat', num2str(rat_num(i_rat), '%.3d')], 'rfmri_processed');
        save_nii(nii, fullfile(preproc_dir, [scan_name,'.nii']));
        
    end 
    display(i_rat);
    
end