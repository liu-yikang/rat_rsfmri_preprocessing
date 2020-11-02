% 1. Soft IC cleaning + motion regression + WM/CSF signal regression
% 2. Spatial smoothing the motion-corrected images with a Gaussian kernel 
% with FWHM = FWHM. Save the averaged WM/CSF signals in the resulting
% images.
% 3. Bandpass temporal filtering.

% Author: Yikang Liu
% Last modified date: 05/24/2020

%%%%%%%%%%%%%% set parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_dir = '/path/to/your/data'; % database folder
FWHM = 1; % unit mm
TR = 1;             % Repetition time of the scan.
low_cutoff = 0.01;  % low cutoff frequency of the bandpass filter  (unit: Hz)
high_cutoff = 0.1;  % high cutoff frequency of the bandpass filter  (unit: Hz)
regression_option = 1; 
% choices of hard regression
% 1. hard-regress average WM/CSF signal and motion parameters
% 2. hard-regress principal components of WM/CSF signals and motion parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

brain_mask = load_nii('templates/brain_mask_64x64.nii');
brain_mask = brain_mask.img;
brain_mask(:,:,[1,2,19,20]) = 0;
wm = load_nii('templates/WM_mask_64x64.nii');
wm_mask = wm.img>0;
csf = load_nii('templates/CSF_mask_64x64_smaller.nii');
csf_mask = csf.img>0;
csf_mask(:,:,[1,2,19,20]) = 0;
wm_mask(:,:,[1,2,19,20]) = 0;

rat_list = dir(fullfile(data_dir, 'rat*'));
for i_rat = 1:length(rat_list)
    cd(fullfile(data_dir, rat_list(i_rat).name, 'rfmri_intermediate'));
    
    scan_list = dir('*_warped.nii.gz'); 
    % list all images that need to be further processed
    
    for i_scan = 1:length(scan_list)
        
        scan_name = scan_list(i_scan).name(1:2);
        preproc_dir = fullfile(data_dir, rat_list(i_rat).name, 'rfmri_processed');
                
        %% load IC time courses and labels %%%%%%%%%%%
        x = load(fullfile([scan_name, '.gift_ica'], 'ica__ica_br1.mat'));
        tc = x.compSet.tc';
        tc = detrend(tc);
        try
            label_tab = readtable(fullfile([scan_name, '.gift_ica'], 'labels.csv'));
        catch
            label_tab = readtable(fullfile([scan_name, '.gift_ica'], 'labels.xlsx'));
        end
        bad_index = label_tab{:,3} == 1;
        
        %% load scan %%%%%%%%%%
        nii = load_nii(scan_list(i_scan).name);
        img = nii.img;
        img_2d = reshape(img, [], size(img,4)); % flatten image
        % detrend signals
        img_2d = detrend(img_2d')';
        img = reshape(img_2d, size(img,1), size(img,2), size(img,3), size(img,4));
        
        if regression_option == 1
            wmcsf_reg = mean(img_2d(wm_mask(:)>0|csf_mask(:)>0,:), 1);
            tcs = normalize(wmcsf_reg);
            dlmwrite([scan_name, '_WMCSF_timeseries.txt'], ...
                tcs, 'delimiter', '\t', 'precision', 18);
                
            s = jsonencode(struct('Description', 'averaged (and normalized) signal of WM/CSF'));
            fid = fopen([scan_name, '_WMCSF_timeseries.json'], 'w');
            fwrite(fid, s, 'char');
            fclose(fid);                
        elseif regression_option == 2
            %% get regressors from the CompCor method %%%%%
            img_2d_wmcsf = img_2d(wm_mask(:)>0|csf_mask(:)>0,:);
            [coeff,score,latent,tsquared,explained,mu] = pca(detrend(img_2d_wmcsf',0)');
            exp_dist=zeros(1000,1);
            for i = 1:1000
                [~,~,~,~,exp,~] = pca(randn(size(img_2d_wmcsf,1),size(img_2d_wmcsf,2)));
                exp_dist(i) = exp(1);
            end
            % select significant regressors
            thresh = prctile(exp_dist,95);
            wmcsf_reg = coeff(:,explained>thresh);

            % save WM/CSF mean and CompCor regressors
            tcs = normalize([mean(img_2d_wmcsf)', wmcsf_reg]);
            dlmwrite([scan_name, '_WMCSF_timeseries.txt'], ...
                tcs, 'delimiter', '\t', 'precision', 18);

            s = jsonencode(struct('Description', 'First column: averaged (and normalized) signal of WM/CSF; other columns: CompCor regressors from WM/CSF signals'));
            fid = fopen([scan_name, '_WMCSF_timeseries.json'], 'w');
            fwrite(fid, s, 'char');
            fclose(fid);                
        end
        
        %% summarize hard regressors %%%%%%%%%%%%%%
        % load motion param
        motion = load([scan_name, '_motion.txt']);
        motion = detrend(motion);
        % hard regressors: WM/CSF + motion parameters        
        regressors = normalize([wmcsf_reg, motion], 1);
        
        %% soft regression %%%%%%%%%%%%%%%%%%%%%%%    
        % regress WM/CSF signal and motion parameters from image
        img=rsfmri_regression(img,regressors,brain_mask);
        % regress WM/CSF signal and motion parameters from IC time courses
        for c = 1:size(tc, 2)
            [~,~,tc(:,c)] = regress(tc(:,c), regressors);
        end
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
        img_2d(brain_mask(:)==0, :) = 0;
        img = reshape(img_2d, size(img,1), size(img,2), size(img,3), size(img,4));
        img(isnan(img))=0;

        %% save the cleaned scan %%%%%%%%%%%%
        nii.img = img;
        save_nii(nii, [scan_name,'_cleaned.nii'], [1,1,1]);
        gzip([scan_name,'_cleaned.nii']);
        delete([scan_name,'_cleaned.nii']);

        fid = fopen([scan_name, '_cleaned.json'], 'r');
        s = fread(fid);
        a = jsondecode(char(s)');
        load([scan_name, '.gift_ica/ica__ica_br1.mat']);
        a.Steps.ICA.IC_timeseries = compSet.tc;
        a.Steps.ICA.IC_bad = find(bad_index>0);
        a.Steps.ICNoiseCleaning.regression_method = 'soft';
        if regression_option == 1:
            a.Steps.ICNoiseCleaning.other_regressors = ['Average WM/CSF signal + motion parameters'];
        elseif regression_option == 2:
            a.Steps.ICNoiseCleaning.other_regressors = ['First ', num2str(size(wmcsf_reg, 2)), ' PCs of WM/CSF signal + motion parameters'];
        end

        s = jsonencode(a);
        json = [scan_name, '_cleaned.json'];
        fid = fopen(json, 'w');
        fwrite(fid, s, 'char');
        fclose(fid);
        a = loadjson(json); savejson('', a, json); % reformat

        %% spatial smoothing %%%%%%%%%%%%%%
        img = rsfmri_smooth(img,FWHM,nii.hdr.dime.pixdim(2));
        img(isnan(img)) = 0;
        
        %% bandpass filtering %%%%%%%%%%%%%
        img=rsfmri_bandpassfilt(img,TR,4,low_cutoff,high_cutoff,brain_mask);
        img(isnan(img))=0;
        
        %% save the final result %%%%%%%%%%%%
        nii.img = img;
        preproc_dir = fullfile(data_dir, rat_list(i_rat).name, 'rfmri_processed');
        save_nii(nii, fullfile(preproc_dir, [scan_name,'.nii']), [1,1,1]);
        
        % save .json file
        fid = fopen([scan_name, '_cleaned.json'], 'r');
        s = fread(fid);
        a = jsondecode(char(s)');
        a.Steps.SpatialSmoothing.FWHM = '1 mm';        
        a.Steps.TemporalFiltering.band = '0.01 Hz - 0.1 Hz';
        a.Steps.TemporalFiltering.filter = '4th-order Butterworth';
        
        s = jsonencode(a);
        json = ['../rfmri_processed/', scan_name, '.json'];
        fid = fopen(json, 'w');
        fwrite(fid, s, 'char');
        fclose(fid);
        a = loadjson(json); savejson('', a, json); % reformat
         
    end 
    display(i_rat);
    
end
