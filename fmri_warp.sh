#!/bin/bash
path="/path/to/data"
template="templates/t2_isotropic.nii"

cd $path
for subj in rat*
do
	echo "processing $subj ..."
	cd ${path}/${subj}/rfmri_intermediate
	for f in *motioncorrected_frame1.nii
	do
		echo $f
		scanname=${f:0:2}
		
		# ANTS
		antsIntroduction.sh -d 3 -r ${scanname}_motioncorrected_frame1.nii -i $template -o ${scanname}_ANTS_
		mv ${scanname}_ANTS_Affine.txt ${scanname}_affine.txt
		mv ${scanname}_ANTS_InverseWarp.nii.gz ${scanname}_warp_field.nii.gz
		antsApplyTransforms -i ${scanname}_motioncorrected.nii.gz -r ${scanname}_motioncorrected_frame1.nii -o ${scanname}_warped.nii -e 3 -t [${scanname}_affine.txt,1] ${scanname}_warp_field.nii.gz

	done
done
