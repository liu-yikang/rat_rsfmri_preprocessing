% Spatial smoothing the motion-corrected images with a Gaussian kernel 
% with FWHM = FWHM_ica; Run ICA on smoothed images with #IC=50 
% (feed 'inputs_ica.m' to the GIFT toolbox).

%%%%%%%%%%%%%% set parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_dir='/path/to/data';
FWHM_ica=0.7; %FWHM=0.7mm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author: Yikang Liu
% Last modified data: 05/24/2020

rat_list = dir(fullfile(data_dir, 'rat*'));
for i=1:length(rat_list)
    cd(fullfile(data_dir, rat_list(i).name, 'rfmri_intermediate'));
    scan_list = dir('*motioncorrected.nii.gz'); 
    
    for j = 1:length(scan_list)
        scan_name = scan_list(j).name(1:2);
        
        % make a folder for ICA results
        folder = fullfile(pwd, [scan_name, '.gift_ica']);
        mkdir(folder);
        delete([folder, '/*']);
        
        % load a motion corrected image
        nii = load_nii([scan_name, '_motioncorrected.nii.gz']);
        img = nii.img;
        
        % spatial smoothing
        img = rsfmri_smooth(img,FWHM_ica,nii.hdr.dime.pixdim(2));
        img(isnan(img)) = 0;
        nii.img = img;
        tmp = fullfile(pwd, [scan_name, '_despiked_registered_aligned_sm_ica.nii']);
        save_nii(nii, tmp);
        
        % write a script for GIFT ICA
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
    end
end