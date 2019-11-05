# Rat rsfMRI preprocessing
Reprocessing codes for the rat rs-fMRI database. 

## Prerequisites:
1. GIFT ICA toolbox. (https://www.nitrc.org/projects/gift)
2. jsonlab. (https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encode-decode-json-files)

## Preprocessing steps
1. rsfmri_despiking.m  
*Discard frames with excessive motion in data (aka motion scrubbing).*
2. alignment\_checking\_tool.m  
*A graphcial user interface (GUI) to manually coregister a rsfMRI scan to a template.*
3. pre\_ic\_labeling.m  
*Motion correction (save motion parameters);*  
*Run independent component analysis (ICA) with the GIFT ICA toolbox to identify noisy independent components (ICs);*  
*Spatial smoothing;*  
*Save WM/CSF signal.*  
4. copy\_ica\_results\_4labeling.m  
*Copy ICA results to an temporay folder for the ease of manual labeling.*  
5. plot_ic.m  
*Plot spatial maps, time courses, and frequency spetrums of the ICs.*  
6. ica_cleaning_view.m  
*A GUI to manually label the ICs.*  
7. copy\_labels.m  
*Copy back labels to the database folder.*  
8. post\_ic\_labeling.m  
*Soft IC regressing spatially-smoothed images with the motion parameters and WM/CSF signal as extra regressors; temporal filtering.*  

## Database folder structure
```bash
./  
├── rat001  
│   ├── rat001_info.json  [Sequence names, acquisition dates, number of frames, and corresponding names inside folders
│   ├── raw  [Nifti files converted from raw Bruker data using Bru2Nii (https://github.com/neurolabusc/Bru2Nii)
│   │   ├── X2P1.nii  
│   │   ├── X4P1.nii  
│   │   ├── X7P1.nii  
│   │   ├── X8P1.nii  
│   │   └── ...  
│   ├── rfmri_unprocessed  [rsfMRI scans from the folder 'raw' 
│   │   ├── 01.nii  
│   │   ├── 02.nii  
│   │   ├── 03.nii  
│   │   └── 04.nii  
│   ├── rfmri_intermediate  [Intermediate files generated from preprocessing  
│   │   ├── 01_despiked.json  
│   │   ├── 01_despiked.nii.gz  [Not further processed since more than 10% of the frames motion-scrubbed
│   │   ├── 02_despiked.json  
│   │   ├── 02_despiked.nii.gz  [Despiked image  
│   │   ├── 02_registered.json  
│   │   ├── 02_registered.nii.gz  [Manually coregistered image  
│   │   ├── 02_motioncorrected.json  
│   │   ├── 02_motioncorrected.nii.gz  [Motion corrected image  
│   │   ├── 02_motion.json  
│   │   ├── 02_motion.txt  [Motion parameters  
│   │   ├── 02.gift_ica  [Results from single-scan ICA  
│   │   │   ├── ica__ica_br1.mat  
│   │   │   ├── ica__ica_c1-1.mat  
│   │   │   ├── ica__ica.mat  
│   │   │   ├── ica__icasso_results.mat  
│   │   │   ├── ica_Mask.hdr  
│   │   │   ├── ica_Mask.img  
│   │   │   ├── ica__pca_r1-1.mat  
│   │   │   ├── ica__postprocess_results.mat  
│   │   │   ├── ica__results.log  
│   │   │   ├── ica__sub01\_component\_ica\_s1_.mat  
│   │   │   ├── ica__sub01\_component\_ica\_s1_.nii  
│   │   │   ├── ica__sub01\_timecourses\_ica\_s1_.nii  
│   │   │   ├── ica_Subject.mat  
│   │   │   └── labels.xlsx  [IC labels: only the ones labeled with 'noise' are soft-regressed 
│   │   ├── 02\_WMCSF_timeseries.json  
│   │   ├── 02\_WMCSF_timeseries.txt  [Averaged signal from white matter and ventricle voxels  
│   │   ├── ...  
│   └── rfmri_processed  [Preprocessed images  
│       ├── 02.json  
│       ├── 02.nii  
│       ├── 04.json  
│       └── 04.nii  
├── rat002  
│   ├── ...  
```
