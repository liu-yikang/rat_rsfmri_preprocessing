% Preprocessing steps after manually coregistering rsfMRI to a template and
% before manually labeling noise independent components.

% Author: Yikang Liu
% Last modified data: 11/05/2019

% Description:
% 1. Correcting head motions in manually coregistered images with SPM.
% 2. Spatial smoothing the motion-corrected images with a Gaussian kernel 
% with FWHM = FWHM_ica; Run ICA on smoothed images with #IC=50 
% (feed 'inputs_ica.m' to the GIFT toolbox).
% 3. Spatial smoothing the motion-corrected images with a Gaussian kernel 
% with FWHM = FWHM. Save the averaged WM/CSF signals in the resulting
% images.

%%%%%%%%%%%%%% set parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_dir='/home/project/organize_database/Rat_Database_AllBaseline';
FWHM_ica = 0.7; % unit mm
FWHM = 1; % unit mm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in the brain mask
brain_mask=spm_read_vols(spm_vol(which('brain_mask_64x64.nii')));
SE=strel('square', 3);
brain_mask_dilated=zeros(size(brain_mask));
for x=1:size(brain_mask,3)
    brain_mask_dilated(:,:,x)=imdilate(brain_mask(:,:,x),SE);
end

% read in the white matter and CSF mask
WM_CSF_mask = load_nii('WM_CSF_mask_64x64.nii');
WM_CSF_mask = WM_CSF_mask.img>0;

rat_list = dir(fullfile(data_dir, 'rat*'));
for i=1:length(rat_list)
    cd(fullfile(data_dir, rat_list(i).name, 'rfmri_intermediate'));
    scan_list = dir('mr*'); 
    % 'mr*' indicates newly manually registered image;
    % after ICA and spatial smoothing, it's renamed to *_registered.nii.gz
    
    for j = 1:length(scan_list)
        nii = load_nii(scan_list(j).name);
        img = nii.img;
        scan_name = scan_list(j).name(3:4);
        
        for t = 1:size(img,4)
            img0 = img(:,:,:,t);
            img0(brain_mask_dilated<1) = 0;
            img(:,:,:,t) = img0;
        end
        nii = make_nii(img,nii.hdr.dime.pixdim(2:4)*10);
        save_nii(nii,[scan_name,'_x10.nii']);
        
        % SPM motion correction
        P = spm_select('expand',[scan_name,'_x10.nii']);
        realign_flags.quality = 0.9;
        realign_flags.fwhm = 5;
        realign_flags.sep = 2.5;
        realign_flags.rtm = 0;
        realign_flags.wrap = [0 0 0];
        realign_flags.interp = 2;
        realign_flags.graphics=0;
        spm_realign(P,realign_flags);
        
        reslice_flags.mask = 0;
        reslice_flags.which = 2;
        reslice_flags.interp = 4;
        reslice_flags.wrap = [0 0 0];
        reslice_flags.prefix = 'mcspm_';
        spm_reslice(P,reslice_flags);
                
        nii = load_nii(['mcspm_',scan_name,'_x10.nii']);
        delete(['mcspm_',scan_name,'_x10.nii']);
        delete([scan_name,'_x10.nii']);
        delete([scan_name,'_x10.mat']);
        delete('mean*');
        img = nii.img;
        nii = make_nii(img,nii.hdr.dime.pixdim(2:4)/10);
        save_nii(nii, [scan_name, '_motioncorrected.nii']);
        gzip([scan_name, '_motioncorrected.nii']);
        delete([scan_name, '_motioncorrected.nii']);
        movefile(['rp_', scan_name, '_x10.txt'], [scan_name, '_motion.txt']);
        
        % create *_motion.json
        tbl = {'TransX, TransY, TransZ', 'mm/10', 'Translation parameters ';...
            'RotX, RotY, RotZ', 'radians', 'Rotation parameters'};
        tbl = cell2table(tbl, 'VariableNames', {'Motion_param', 'Units', 'Description'});
        s = jsonencode(struct('Description','Motion parameters of the despiked and manually registered image', ...
            'Content', tbl));
        fid = fopen([scan_name, '_motion.json'], 'w');
        fwrite(fid, s, 'char');
        fclose(fid);
               
        % ica
        folder = fullfile(pwd, [scan_name, '.gift_ica']);
        mkdir(folder);
        delete([folder, '/*']);
        nii = load_nii([scan_name, '_motioncorrected.nii.gz']);
        img = nii.img;
        img = rsfmri_smooth(img,FWHM_ica,nii.hdr.dime.pixdim(2));
        img(isnan(img)) = 0;
        nii.img = img;
        tmp = fullfile(pwd, [scan_name, '_despiked_registered_aligned_sm_ica.nii']);
        save_nii(nii, tmp);
        
        script_dir = strrep(mfilename('fullpath'), mfilename, '');
        fi = fopen(fullfile(script_dir, 'inputs_ica.m'),'r');
        fileo = fullfile(script_dir, ['inputs_ica',...
            rat_list(i).name,'_',scan_list(j).name(3:4),'.m']);
        fo = fopen(fileo,'w');
                
        while ~feof(fi)
            l = fgetl(fi);
            if strfind(l,'outputDir') == 1
                l = ['outputDir = ''',...
                    folder, ''';'];
            end
            if strfind(l,'input_data_file_patterns =') == 1
                l = ['input_data_file_patterns = {''',...
                    tmp, '''};'];
            end
            fprintf(fo,'%s\n',l);
        end
        fclose(fi);
        fclose(fo);
        
        cd(folder);
        icatb_batch_file_run(fileo);
        close all;
        
        cd(fullfile(data_dir, rat_list(i).name, 'rfmri_intermediate'));
        delete(tmp);
                      
        % spatial smoothing
        nii = load_nii(scan_list(j).name);
        img = nii.img;
        img = rsfmri_smooth(img,FWHM,nii.hdr.dime.pixdim(2));
        img(isnan(img)) = 0;
        nii.img = img;
        save_nii(nii, [scan_name, '_despiked_registered_aligned_smoothed.nii']);
        
        % rename registered file
        movefile(scan_list(j).name, [scan_name, '_registered.nii']);
        gzip([scan_name, '_registered.nii']);
        delete([scan_name, '_registered.nii']);
        
        % create *_registered.json
        fid = fopen([scan_name, '_despiked.json'], 'r');
        s = fread(fid);
        fclose(fid);
        a = jsondecode(char(s)');
        a.Space = 'atlas';
        a.SkullStripped = false;
        a.Steps.Order = 'Despiking; Registration';
        a.Steps.Registration.method='Manually register the 1st frame';
        load([scan_name, '_despiked_checked_tform.mat']);
        a.Steps.Registration.transformation_matrix = tform.T;
        s = jsonencode(a);
        fid = fopen([scan_name, '_registered.json'], 'w');
        fwrite(fid, s, 'char');
        fclose(fid);
        a = loadjson([scan_name, '_registered.json']); savejson('', a, [scan_name, '_registered.json']); % reformat
        delete([scan_name, '_despiked_checked_tform.mat']);
        
        % create *_motioncorrected.json
        fid = fopen([scan_name, '_registered.json'], 'r');
        s = fread(fid);
        fclose(fid);
        a = jsondecode(char(s)');
        a.Space = 'atlas';
        a.SkullStripped = true;
        a.Steps.Order = 'Despiking; Registration; Motion Correction';
        a.Steps.MotionCorrection.software='SPM';
        a.Steps.MotionCorrection.spatial_resize='x10';
        a.Steps.MotionCorrection.realign_flags.quality = 0.9;
        a.Steps.MotionCorrection.realign_flags.fwhm = 5;
        a.Steps.MotionCorrection.realign_flags.sep = 2.5;
        a.Steps.MotionCorrection.realign_flags.rtm = 0;
        a.Steps.MotionCorrection.realign_flags.wrap = [0 0 0];
        a.Steps.MotionCorrection.realign_flags.interp = 2;
        
        a.Steps.MotionCorrection.reslice_flags.mask = 0;
        a.Steps.MotionCorrection.reslice_flags.which = 2;
        a.Steps.MotionCorrection.reslice_flags.interp = 4;
        a.Steps.MotionCorrection.reslice_flags.wrap = [0 0 0];
        json = [scan_name, '_motioncorrected.json'];
        s = jsonencode(a);
        fid = fopen(json,'w');
        fwrite(fid,s,'char'); fclose(fid);
        a = loadjson(json); savejson('', a, json); % reformat
        
        % save WM/CSF signal
        wvtc = rsfmri_WVTC(img,WM_CSF_mask)';
        wvtc = (wvtc - mean(wvtc))/std(wvtc);
        dlmwrite([scan_name, '_WMCSF_timeseries.txt'], ...
            wvtc(:), 'delimiter', '\t', 'precision', 18);
        s = jsonencode(struct('Description', 'Averaged (and normalized) signal of WM and CSF in smoothed (FWHM=1mm) image'));
        fid = fopen([scan_name, '_WMCSF_timeseries.json'], 'w');
        fwrite(fid, s, 'char');
        fclose(fid);
                
    end
    
end

