#!/bin/bash

# Author: Yikang Liu
# Last modified date: 11/01/2020

path="/path/to/data"
template="templates/t2_isotropic.nii" # template to which fMRI is registered
prefix_len=2 # length of the prefix in scan name

cd $path
for subj in rat*
do
	echo "processing $subj ..."
	cd ${path}/${subj}/rfmri_intermediate
	for f in *motioncorrected_frame1.nii
	do
		echo $f
		scanname=${f:0:${prefix_len}} # extract prefix in the file name 'f'
		
		# ANTS
		# call antsIntroduction.sh to do deformable registration.
		# -d 3: means deformation can happen in all three directions. Although distortion only happens in plane, 
		#	 I found that d=2 makes ANTS unstable.
		# -r: reference image (image to be fixed)
		# -i: moving image (image to be warped)
		# -o: prefix of output results
		antsIntroduction.sh -d 3 -r ${scanname}_motioncorrected_frame1.nii -i $template -o ${scanname}_ANTS_
		
		# rename output files
		mv ${scanname}_ANTS_Affine.txt ${scanname}_warp_affine.txt # affine transformation matrix
		mv ${scanname}_ANTS_InverseWarp.nii.gz ${scanname}_warp_field.nii.gz # field to warp fMRI
		
		# call antsApplyTransforms to apply affine transformation matrix and warping field
		# -i: image to be warped
		# -r, --reference-image imageFileName
		#	 For warping input images, the reference image defines the spacing, origin, size, and direction of the output warped image.
		# -e, --input-image-type 0/1/2/3
		#	 scalar/vector/tensor/time-series
		# -t, --transform transformFileName
		#	 [transformFileName,useInverse]
		# -o: output file name
		antsApplyTransforms -i ${scanname}_motioncorrected.nii.gz -r ${scanname}_motioncorrected_frame1.nii -o ${scanname}_warped.nii -e 3 -t [${scanname}_warp_affine.txt,1] ${scanname}_warp_field.nii.gz
		
		# gzip the file
		gzip ${scanname}_warped.nii

		# write JSON file
		order=$(jq -r '.Steps.Order' ${scanname}_motioncorrected.json)'; Deformable Registration'
		jq --arg v1 "$order" --arg v2 ${scanname}_warp_field.nii.gz --arg v3 ${scanname}_affine.txt -r '.Steps.Order = $v1 | .Steps.DeformReg.field = $v2 | .Steps.DeformReg.affinemat = $v3' ${scanname}_motioncorrected.json > ${scanname}_warped.json

	done
done
