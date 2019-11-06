% Despike (motion scrub) rsfMRI scans

% Authors: Yikang Liu and Zhiwei Ma
% Last modified data: 11/03/2019

% Description:
% 1. Calculate relative framewise displacement and then identify the motion volumes (the motion volume itself and its nearest temporal neighbors) which need to be excluded
% 2. Also remove the first 10 volumes of each original EPI run (ensure the magnetization to reach a steady state)

%%%%%%%%%%%%%% set parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_dir='/home/labuser/project/organize_database/Rat_Database_AllBaseline';    % obtain data directory
T_removed=10;           % the number of intial volumes for removal
remove_motion_NN=1;     % the option for removing the nearest temporal neighbors of motion volumes
FD_threshold=0.2;       % the relative FD threshold for motion volume removal
quality=0.9;            % the data quality criterion for classifying junk data (percentage of remaining volumes)
use_parallel = true;    % the indicator (true/false) to use parallel computing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['The current working directory is ',data_dir])
rats = dir(fullfile(data_dir, 'rat*'));

for i=1:length(rats)
    cd(fullfile(rats(i).folder, rats(i).name));
    scans=dir(fullfile('rfmri_unprocessed', '*.nii'));
    for j=1:length(scans)
        scanname = scans(j).name(1:2);
%         if exist(fullfile('rfmri_intermediate', [scanname, '_despiked.nii.gz']), 'file' ) || ...
%                 exist(fullfile('rfmri_intermediate', [scanname, '_despiked.nii']), 'file' )
%             continue; % skip the despiked scans
%         end
        if exist(fullfile('rfmri_processed', [scanname, '.nii']), 'file' )
            continue; % skip the despiked scans
        end
        
        nii = load_untouch_nii(fullfile(scans(j).folder, scans(j).name));
        ref = imref3d(size(nii.img(:,:,:,1)), nii.hdr.dime.pixdim(2), ...
            nii.hdr.dime.pixdim(3), nii.hdr.dime.pixdim(4));
        
        % estimate relative framewise displacement
        [optimizer, metric] = imregconfig( 'monomodal');
        optimizer.MaximumIterations = 600;
        motion=zeros(size(nii.img,4),6);
        if use_parallel
            parfor x=2:size(nii.img,4)
                motion0 = zeros(1,6);
                tform=imregtform(nii.img(:,:,:,x), ref, nii.img(:,:,:,1), ref, 'rigid', optimizer, metric);
                transform_mat=tform.T;
                motion0(1)=transform_mat(4,1);
                motion0(2)=transform_mat(4,2);
                motion0(3)=transform_mat(4,3);
                motion0(5)=-asin(transform_mat(1,3));
                motion0(4)=atan2(transform_mat(2,3)/cos(motion0(5)),transform_mat(3,3)/cos(motion0(5)));
                motion0(6)=atan2(transform_mat(1,2)/cos(motion0(5)),transform_mat(1,1)/cos(motion0(5)));
                motion(x,:) = motion0;
            end
        else
            for x=2:size(nii.img,4)
                motion0 = zeros(1,6);
                tform=imregtform(nii.img(:,:,:,x), ref, nii.img(:,:,:,1), ref, 'rigid', optimizer, metric);
                transform_mat=tform.T;
                motion0(1)=transform_mat(4,1);
                motion0(2)=transform_mat(4,2);
                motion0(3)=transform_mat(4,3);
                motion0(5)=-asin(transform_mat(1,3));
                motion0(4)=atan2(transform_mat(2,3)/cos(motion0(5)),transform_mat(3,3)/cos(motion0(5)));
                motion0(6)=atan2(transform_mat(1,2)/cos(motion0(5)),transform_mat(1,1)/cos(motion0(5)));
                motion(x,:) = motion0;
            end
        end
        motion_diff=zeros(size(motion));
        temp=motion;
        temp(:,4:6)=5*temp(:,4:6);  % displacement on surface of a r=5mm sphere
        for x=2:size(motion,1)
            motion_diff(x,:)=temp(x,:)-temp(x-1,:);
        end
        motion_diff=abs(motion_diff);
        framewise=sum(motion_diff,2);
        
        % identify the outlier volumes and their temporal nearest neighbors based on relative framewise displacement
        outlier=find(framewise>FD_threshold);
        outlier_all=outlier;
        if remove_motion_NN==1
            outlier_all=[outlier_all; outlier-1; outlier+1];
        end
        outlier_all=[outlier_all; (1:T_removed)'];
        outlier_all=unique(outlier_all);
        outlier_all(outlier_all<0)=[];
        outlier_all(outlier_all>size(nii.img,4))=[];
        removed_points_index=true(1, size(nii.img, 4));
        removed_points_index(outlier_all)=false;
        original_length=size(nii.img,4);
        img = nii.img(:,:,:,removed_points_index);
        nii = make_nii(img, nii.hdr.dime.pixdim(2:4));
        save_nii(nii, fullfile('rfmri_intermediate', [scanname, '_despiked.nii']));
        gzip(fullfile('rfmri_intermediate', [scanname, '_despiked.nii']));
        delete(fullfile('rfmri_intermediate', [scanname, '_despiked.nii']));
        fprintf('%s done\n', fullfile(rats(i).name, 'rfmri_intermediate', [scanname, '_despiked.nii.gz']));
        
        % save despiking metadata to a JSON file
        a = struct;
        a.Space = 'orig';
        a.SkullStripped = false;
        a.Steps.Order = 'Despiking';
        a.Steps.Despiking.software = 'MATLAB/imregtform.m';
        a.Steps.Despiking.param = 'MultimodalDefault(MaximumIterations=600)';
        a.Steps.Despiking.framewise_displacement.method = 'Power et al, 2012';
        a.Steps.Despiking.framewise_displacement.value = framewise;
        a.Steps.Despiking.framewise_displacement.unit = 'mm';
        a.Steps.Despiking.scrubbing_rule = 'FD>0.2mm + direct neighbors';
        a.Steps.Despiking.scrubbed_frames = outlier_all;
        s = jsonencode(a);
        json = fullfile('rfmri_intermediate', [scanname, '_despiked.json']);
        fid = fopen(json, 'w');
        fwrite(fid, s, 'char');
        fclose(fid);
        a = loadjson(json); savejson('', a, json); % reformat
         
    end
end