% Preprocessing steps after manually labeling noise independent components.

% Author: Yikang Liu
% Last modified data: 11/05/2019

% Description:
% 1. Soft IC cleaning
% 2. Bandpass temporal filtering.

%%%%%%%%%%%%%% set parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_dir = '/home/project/organize_database/Rat_Database_AllBaseline'; % database folder
TR = 1;             % Repetition time of the scan.
low_cutoff = 0.01;  % low cutoff frequency of the bandpass filter  (unit: Hz)
high_cutoff = 0.1;  % high cutoff frequency of the bandpass filter  (unit: Hz)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

brain_mask = spm_read_vols(spm_vol(which('brain_mask_64x64.nii')));

rat_list = dir(fullfile(data_dir, 'rat*'));
for i_rat = 1:length(rat_list)
    cd(fullfile(data_dir, rat_list(i_rat).name, 'rfmri_intermediate'));
    
    scan_list = dir('*smoothed.nii'); 
    % list all images that need to be further processed
    % '*smoothed.nii' will be deleted after preprocessing
    
    for i_scan = 1:length(scan_list)
        
        scan_name = scan_list(i_scan).name(1:2);
                
        %%%% load IC time courses and labels %%%%%%%%%%%
        x = load(fullfile([scan_name, '.gift_ica'], 'ica__ica_br1.mat'));
        tc = x.compSet.tc';
        tc = (tc-repmat(mean(tc), size(tc,1), 1))./repmat(std(tc), size(tc,1), 1);
        label_tab = readtable(fullfile([scan_name, '.gift_ica'], 'labels.csv'));
        bad_index = label_tab{:,3} == 1;
        
        %%%% load motion param and WM/CSF signal %%%%%%%
        wm = load([scan_name, '_WMCSF_timeseries.txt']);
        wm = (wm-mean(wm))/std(wm); % demean and normalize
        motion = load([scan_name, '_motion.txt']);
        motion = (motion - repmat(mean(motion,1), size(motion,1),1))./...
            repmat(std(motion,1), size(motion,1),1); % demean and normalize
        regressors = [wm(:), motion];
        
        %%%%%%%% load smoothed image %%%%%%%%%%%%%%%%%%%
        nii = load_nii(scan_list(i_scan).name);
        img = nii.img;
        
        %%%%%%%% soft regression %%%%%%%%%%%%%%%%%%%%%%%
        % regress WM/CSF signal and motion parameters from image
        img=rsfmri_regression(img,regressors,brain_mask);
        % regress WM/CSF signal and motion parameters from IC time courses
        for c = 1:size(tc, 2)
            [~,~,tc(:,c)] = regress(tc(:,c), regressors(:,1:6));
        end

        % flatten image
        img_2d = reshape(img, [], size(img,4));
        % get the signals in the brain
        img_2d_brain = img_2d(brain_mask(:)>0, :);
        for i_vxl = 1:size(img_2d_brain, 1)
            % regress the IC time course residuals from the image residuals; 
            % get the weights of all ICs
            beta = regress(img_2d_brain(i_vxl, :)', tc);
            % remove the contributions of bad ICs
            img_2d_brain(i_vxl, :) = (img_2d_brain(i_vxl, :)' - tc(:,bad_index)*beta(bad_index,1))';
        end
        % put the cleaned signals back to a 4D matrix with full FOV
        img_2d(brain_mask(:)>0, :) = img_2d_brain;
        img = reshape(img_2d, size(img,1), size(img,2), size(img,3), size(img,4));
        img(isnan(img))=0;
        
        %%%%%%% perform bandpass filtering %%%%%%%%%%%%%
        img=rsfmri_bandpassfilt(img,TR,4,low_cutoff,high_cutoff,brain_mask);
        img(isnan(img))=0;
        nii.img = img;
        preproc_dir = fullfile(data_dir, rat_list(i_rat).name, 'rfmri_processed');
        save_nii(nii, fullfile(preproc_dir, [scan_name,'.nii']));
        
        % save .json file
        fid = fopen([scan_name, '_motioncorrected.json'], 'r');
        s = fread(fid);
        a = jsondecode(char(s)');
        a.Steps.Order = 'Despiking; Registration; Motion Correction; ICA; Spatial Smoothing; IC Noise Cleaning; Temporal Filtering';
        a.Steps.ICA.software = 'GIFT ICA';
        a.Steps.ICA.spatial_smoothing_fwhm = '0.7 mm';
        a.Steps.ICA.IC_number = 50;
        load([scan_name, '.gift_ica/ica__ica_br1.mat']);
        a.Steps.ICA.IC_timeseries = compSet.tc;
        a.Steps.ICA.IC_bad = find(bad_index>0);
        a.Steps.SpatialSmoothing.FWHM = '1 mm';
        a.Steps.ICNoiseCleaning.regression_method = 'soft';
        a.Steps.ICNoiseCleaning.other_regressors = 'WM/CSF signal + motion parameters';
        a.Steps.TemporalFiltering.band = '0.01 Hz - 0.1 Hz';
        a.Steps.TemporalFiltering.filter = '4th-order Butterworth';
        
        s = jsonencode(a);
        json = ['../rfmri_processed/', scan_name, '.json'];
        fid = fopen(json, 'w');
        fwrite(fid, s, 'char');
        fclose(fid);
        a = loadjson(json); savejson('', a, json); % reformat
        
        % delete *smoothed.nii
        delete(scan_list(i_scan).name);
        
    end 
    display(i_rat);
    
end