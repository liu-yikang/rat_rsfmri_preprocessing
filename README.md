# Rat rsfMRI Preprocessing Toolbox
Preprocessing codes for the rat rs-fMRI database (www.nitrc.org/projects/rat_rsfmri). 

## Quick Start
This section is a quick-start guide to this toolbox. More details can be found in code comments.
### Step 1: Download prerequisites:
Download the following software packages before using the toolbox:
- GIFT ICA toolbox. (https://www.nitrc.org/projects/gift) 
- jsonlab. (https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encode-decode-json-files)
- Tools for NIfTI and ANALYZE image (https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image)
- ANTS. (http://stnava.github.io/ANTs/)
- export_fig. (https://github.com/altmany/export_fig)
### Step 2: Organize your data into the following structure.
- `ratxxx` is the label for the subject. You can other names here.
- Folder `rfmri_unprocessed` under `ratxxx` contains raw EPI scans for the subject.
```bash
├── rat001
│   ├── rfmri_unprocessed
│   │   ├── 01.nii
│   │   ├── 02.nii
│   │   ├── 03.nii
│   │   └── 04.nii
├── rat002
...
```
### Step 3: Despiking (motion scrubbing).
- Change `data_dir` parameter in `despiking.m` to the path to your data.
- Run `despiking.m` to discard frames with excessive motion. 
- The script will create a folder `rfmri_intermediate` in each subject folder `ratxxx` and generate the following files:
    - `xx_despiked.json`: despiking information for `xx.nii` in `rfmri_unprocessed`, containing Contains framewise displacements, scrubbing criterion, and scrubbed frames.
    - `xx_despiked.nii.gz`: despiked fMRI scan.

### Step 4: Rigid-body registration
- Use `alignment_checking_tool.m` to manually register a rsfMRI scan to a built-in anatomical template.
- `alignment_checking_tool.m` generates the following files under `rfmri_intermediate` in each subject folder `ratxxx`:
    - `xx_tform.mat`: rigid-body registration matrix
    - `xx_registered.json`: rigid-body registration matrix in .json format
    - `xx_registered.nii.gz`: registered fMRI scan

### Step 5: Motion correction
- Change `data_dir` parameter in `motion_correction.m` to the path to your data.
- Run `motion_correction.m` to correct motion (register every frame to the first one) in `xx_registered.nii.gz` using SPM built-in functions.
- `motion_correction.m` generates the following files under `rfmri_intermediate` in each subject folder `ratxxx`:
    - `xx_motioncorrected.json`: SPM settings for motion correction.
    - `xx_motion.json` and `xx_motion.txt`: motion parameters in .json format and text format respectively. 
    - `xx_motioncorrected.nii.gz`: motion-corrected fMRI scans.

### Step 6: ICA cleaning
- In this step, we will run ICA (IC=50) on individual scans (`xx_motioncorrected.nii.gz`), manually label bad components, and regress out time courses of these components.
- Change `data_dir` parameter in `ica_cleaning.m` to the path to your data.
- Adjust `FWHM_ica` parameter in `ica_cleaning.m` based on your need. It controls the strengh of spatial smoothing prior to ICA, via adjusting full-width-at-half-maximum of Gaussian kernel for spatial smoothing (default = 0.7 mm). Smoothing helps to make spatial IC maps look cleaner and easier to label. fMRI scans with high signal/contrast-to-noise ratio don't need smoothing (set `FWHM_ica` to 0). 
- `ica_cleaning.m`generates a folder `xx.gift_ica` under `rfmri_intermediate` in each subject folder `ratxxx`, which contains ICA outputs by SPM. 


<ol>
<li> 
<strong>Despiking (motion scrubbing)</strong></br>
<em>Description</em> Discard frames with excessive motion.</br>
<em>Instruction</em> Run `Despiking.m`
<li>
<strong>Rigid-body registration</strong>Register fMRI images to a template</strong>

<li>1. despiking.m  
* (aka motion scrubbing).*
2. alignment\_checking\_tool.m  
*A graphcial user interface (GUI) to manually coregister a rsfMRI scan to a template.*
3. motion\_correction.m
*Motion correction (save motion parameters);*  
4. ica_cleaning.m  
*Run independent component analysis (ICA) with the GIFT ICA toolbox to identify noisy independent components (ICs);*  
5. copy\_ica\_results\_4labeling.m  
*Copy ICA results to an temporary folder for the ease of manual labeling.*  
*Save spatial maps, time courses, and frequency spetrums of the ICs to figures.*  
6. ica_cleaning_view.m  
*A GUI to manually label the ICs.*  
7. copy\_labels.m  
*Copy IC labels to the database folder.*  
8. last_steps.m  
*Soft IC-regressing warped images, along with the motion parameters and the [CompCor](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2214855/) regressors;*  
*Spatial smoothing.*
*Temporal filtering.*  

</ol>

## Prerequisites:
The following packages need to be downloaded before using the toolbox:
1. GIFT ICA toolbox. (https://www.nitrc.org/projects/gift)
2. jsonlab. (https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encode-decode-json-files)
3. Tools for NIfTI and ANALYZE image (https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image)
4. ANTS. (http://stnava.github.io/ANTs/)
5. export_fig. (https://github.com/altmany/export_fig)

## Preprocessing steps


## Database folder structure
```bash
./
├── rat001
│   ├── rat001_info.json  [Sequence names, acquisition dates, number of frames, and corresponding names inside folders]
│   ├── raw  [Nifti files converted from raw Bruker data using Bru2Nii (https://github.com/neurolabusc/Bru2Nii)]
│   │   ├── X2P1.nii
│   │   ├── X4P1.nii
│   │   ├── X7P1.nii
│   │   ├── X8P1.nii
│   │   └── ...
│   ├── rfmri_unprocessed  [rsfMRI scans from the folder 'raw']
│   │   ├── 01.nii
│   │   ├── 02.nii
│   │   ├── 03.nii
│   │   └── 04.nii
│   ├── rfmri_intermediate  [Intermediate files generated from preprocessing] 
│   │   ├── 01_despiked.json	[Contains framewise displacements, scrubbing criterion, and scrubbed frames]
│   │   ├── 01_despiked.nii.gz  [Not further processed since more than 10% of the frames were motion-scrubbed]
│   │   ├── 02_despiked.json
│   │   ├── 02_despiked.nii.gz  [Despiked image] 
│   │   ├── 02_registered.json	[Contains rigid-body registration matrix]
│   │   ├── 02_registered.nii.gz  [Manually coregistered image] 
│   │   ├── 02_motioncorrected.json
│   │   ├── 02_motioncorrected.nii.gz  [Motion corrected image]
│   │   ├── 02_warped.json
│   │   ├── 02_warped.nii.gz  [Warped image]
│   │   ├── 02_warp_field.nii.gz  [Deformation field]
│   │   ├── 02_warp_affine.txt  [Affine transformation applied with the deformation field]
│   │   ├── 02_motion.json
│   │   ├── 02_motion.txt  [Motion parameters]
│   │   ├── 02.gift_ica  [Results from single-scan ICA]
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
│   │   │   └── labels.csv  [IC labels: only the ones labeled with 'noise' were soft-regressed] 
│   │   ├── 02\_WMCSF_timeseries.json
│   │   ├── 02\_WMCSF_timeseries.txt  [Averaged signal and PCs from white matter and ventricle voxels]
│   │   ├── ...
│   └── rfmri_processed  [Preprocessed images]
│       ├── 02.json
│       ├── 02.nii
│       ├── 04.json
│       └── 04.nii
├── rat002
│   ├── ...
```
