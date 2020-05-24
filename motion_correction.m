% Correcting head motions in manually coregistered images with SPM.

% Author: Yikang Liu
% Last modified data: 05/24/2020

%%%%%%%%%%%%%% set parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_dir='/path/to/data';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in the brain mask
brain_mask = load_nii('brain_mask_64x64.nii');
brain_mask = brain_mask.img;
SE=strel('square', 3);
brain_mask_dilated=zeros(size(brain_mask));
for x=1:size(brain_mask,3)
    brain_mask_dilated(:,:,x)=imdilate(brain_mask(:,:,x),SE);
end

rat_list = dir(fullfile(data_dir, 'rat*'));
for i=1:length(rat_list)
    cd(fullfile(data_dir, rat_list(i).name, 'rfmri_intermediate'));
    scan_list = dir('mr*'); 
    % 'mr*' indicates newly manually registered image;
    % it's renamed to *_registered.nii.gz after motion correction
    
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
        save_nii(nii, [scan_name, '_motioncorrected.nii'], [1,1,1]);
        gzip([scan_name, '_motioncorrected.nii']);
        delete([scan_name, '_motioncorrected.nii']);
        nii = make_nii(img(:,:,:,1), nii.dime.pixdim(2:4));
        save_nii(nii, [scan_name, '_motioncorrected_frame1.nii'], [1,1,1]);
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
                
    end
    
end

