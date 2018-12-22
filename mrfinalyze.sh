#!/bin/bash

#This file is generated based on three separate classes: nl, ep and bi

#Number of individuals in each class:
bisub=10
epsub=20
nlsub=22

#####   directory initialization #####
# FILL THE FOLLOWING WITH THE ADDRESS POINTING TO YOUR DATA
for ((i=0;i< bisub ;i++));
	do
	bi[${i}]=/path/to/subjects/bilateral/bi${i}
done
for ((i=0;i< epsub ;i++));
	do
	ep[${i}]=/path/to/subjects/epilepsy/ep${i}
done
for ((i=0;i< nlsub ;i++));
	do
	nl[${i}]=/path/to/subjects/normal/nl${i}
done

total=/path/to/project/folder

temp=/path/to/template

temptl=/path/to/template_tl

tempwm=/path/to/template_wm

atlas=/path/to/atlas

##### variables initialization #####
peak_threshold=.33
fixel_threshold=.2


for ((i=0;i<= 24 ;i++));
	do
	step[${i}]=0
done
: '
step[0]: Reads b-vals, b-vecs, and dwi.nii from a raw folder which exists in each individual folder and generates 00_data_dwi.mif dwi data in the folder. 
step[1]: Operates denoise preprocessing on 00_data_dwi.mif and generate 01_data_dwi_denoised.mif
step[2]: Operates motion and distortion correction preprocessing on 01_data_dwi_denoised.mif and generate 02_data_dwi_preproc.mif
step[3]: Estimate a temporary brain mask (03_data_mask.mif and 03_data_mask_max.mif) using both mrtrix and FSL toolboxes. It certainly needs to be double checked by the user! 
step[4]: Bias field correction using produced masks and 02_data_dwi_preproc.mif to generate 04_data_dwi_unbias.mif
step[5]: Global intensity normalization across all subjects. This step based on the study can be applied to each class separately. 05_data_dwi_normalized.mif
step[6]: Computing an (average) white matter response function using the irritative Tournier method on top 300 uni-direction voxels. 06_data_response.mif
step[7 & 8]: Upsampling DW and mask images in the same size. in this case, it is transforming to 0.9766,0.9766,1.25. Generated files are 07_data_dwi_upsampled.mif 08_data_dwi_upmask.mif
step[9]: Fibre Orientation Distribution estimation (spherical deconvolution) using msmt_csd techniques after computing extracted data even with single shell data. 09_data_wmfod.mif
step[10]: Generate a study-specific unbiased FOD template and save it with the wmfod_template.mif name.
step[11]: Register all subject FOD images to the FOD template and preserve warps in data_sub2tem_warp.mif and data_tem2sub_warp.mif
step[12]: Compute the template mask (intersection of all subject masks in template space) using previous warps applied on original upsampled masks.
step[13]: Compute a white matter template analysis fixel mask and save it in "fixel_mask" using wmfod_template.mif
step[14]: Warp FOD images to template space with the new name which is data_wmfod_in_template_space.mif
step[15]: Segment FOD images to estimate fixels and their apparent fiber density (FD)
step[16]: Reorient fixels
step[17]: Assign subject fixels to template fixels and calculate final the (FD) parameter after reorientation 
step[18]: Compute the fibre cross-section (FC) metric using log(FC)
step[19]: Compute a combined measure of fiber density and cross-section (FDC) and calculate reduced tractogram after Performation of whole-brain fiber tractography on the FOD template 
step[20]: Perform statistical analysis of FD, FC, and FDC on the normal group and the left unilateral TLE group
step[21]: Perform statistical analysis of FD, FC, and FDC on the normal group and the right unilateral TLE group
step[22]: Perform statistical analysis of FD, FC, and FDC on the normal group and the unilateral TLE group
step[23]: Perform statistical analysis of FD, FC, and FDC on the left unilateral TLE group and the right unilateral TLE group
step[24]: Perform statistical analysis of FD, FC, and FDC on the normal group and the bilateral TLE group
    '
echo "Please enter the step number..."
while :
do
  read INPUT_STEP
  case $INPUT_STEP in
###############################  step 0  ##############################
0)
echo "Performing step 0:"
for ((i=0;i< $nlsub ;i++));
	do
		mrconvert ${nl[$i]}/nl${i}_nii/nl${i}_dwi.nii ${nl[$i]}/00_nl${i}_dwi.mif -fslgrad ${nl[$i]}/nl${i}_nii/nl${i}_dwi.bvec ${nl[$i]}/nl${i}_nii/nl${i}_dwi.bval
	done
	for ((i=0;i< $epsub ;i++));
	do
		mrconvert ${ep[$i]}/ep${i}_nii/ep${i}_dwi.nii ${ep[$i]}/00_ep${i}_dwi.mif -fslgrad ${ep[$i]}/ep${i}_nii/ep${i}_dwi.bvec ${ep[$i]}/ep${i}_nii/ep${i}_dwi.bval
	done
	for ((i=0;i< $bisub ;i++));
	do
		mrconvert ${bi[$i]}/bi${i}_nii/bi${i}_dwi.nii ${bi[$i]}/00_bi${i}_dwi.mif -fslgrad ${bi[$i]}/bi${i}_nii/bi${i}_dwi.bvec ${bi[$i]}/bi${i}_nii/bi${i}_dwi.bval
	done
echo "Step 0 is performed. Please enter the step number..."
;;
###############################  step 1  ##############################
1)
echo "Performing step 1:"
	echo Step 1: Denoising and unringing
	for ((i=0;i< $nlsub ;i++));
	do
		dwidenoise ${nl[$i]}/00_nl${i}_dwi.mif ${nl[$i]}/01_nl${i}_dwi_denoised.mif
	done
	for ((i=0;i< $epsub ;i++));
	do
		dwidenoise ${ep[$i]}/00_ep${i}_dwi.mif ${ep[$i]}/01_ep${i}_dwi_denoised.mif
	done
	for ((i=0;i< $bisub ;i++));
	do
		dwidenoise ${bi[$i]}/00_bi${i}_dwi.mif ${bi[$i]}/01_bi${i}_dwi_denoised.mif
	done
echo "Step 1 is performed. Please enter the step number..."
;;
###############################  step 2  ##############################
2)
echo "Performing step 2:"
	for ((i=0;i< $nlsub ;i++));
	do
		dwipreproc ${nl[$i]}/01_nl${i}_dwi_denoised.mif ${nl[$i]}/02_nl${i}_dwi_preproc.mif -rpe_none -pe_dir Ap
	done
	for ((i=0;i< $epsub ;i++));
	do
		dwipreproc ${ep[$i]}/01_ep${i}_dwi_denoised.mif ${ep[$i]}/02_ep${i}_dwi_preproc.mif -rpe_none -pe_dir Ap
	done
	for ((i=0;i< $bisub ;i++));
	do
		dwipreproc ${bi[$i]}/01_bi${i}_dwi_denoised.mif ${bi[$i]}/02_bi${i}_dwi_preproc.mif -rpe_none -pe_dir Ap
	done
echo "Step 2 is performed. Please enter the step number..."
;;
###############################  step 3  ##############################
3)
	for ((i=0;i< $nlsub ;i++));
	do
		bet ${nl[$i]}/nl${i}_nii/nl${i}_str.nii.gz ${nl[$i]}/nl${i}_nii/nl${i}_str_bet.nii.gz -m -f 0.5
		bet ${nl[$i]}/nl${i}_nii/nl${i}_dwi.nii.gz ${nl[$i]}/nl${i}_nii/nl${i}_dwi_bet.nii.gz -m -f 0.35
		flirt -in ${nl[$i]}/nl${i}_nii/nl${i}_str_bet.nii.gz -ref ${nl[$i]}/nl${i}_nii/nl${i}_dwi_bet.nii.gz -out ${nl[$i]}/00_nl${i}_str2dwi_bet.nii.gz -omat ${nl[$i]}/nl${i}_nii/nl${i}_mat_str2dwi.mat
		flirt -in ${nl[$i]}/nl${i}_nii/nl${i}_str_bet_mask.nii.gz -ref ${nl[$i]}/nl${i}_nii/nl${i}_dwi_bet.nii.gz -applyxfm -init ${nl[$i]}/nl${i}_nii/nl${i}_mat_str2dwi.mat -out ${nl[$i]}/03_nl${i}_mask_in_dwi_space.nii.gz
		rm ${nl[$i]}/nl${i}_nii/nl${i}_dwi_bet.nii.gz ${nl[$i]}/nl${i}_nii/nl${i}_str_bet_mask.nii.gz ${nl[$i]}/nl${i}_nii/nl${i}_dwi_bet_mask.nii.gz 
		mrconvert ${nl[$i]}/03_nl${i}_mask_in_dwi_space.nii.gz ${nl[$i]}/03_nl${i}_mask_in_dwi_space.mif
		mrconvert ${nl[$i]}/00_nl${i}_str2dwi_bet.nii.gz ${nl[$i]}/00_nl${i}_str2dwi_bet..mif
		rm ${nl[$i]}/00_nl${i}_str2dwi_bet.nii.gz ${nl[$i]}/03_nl${i}_mask_in_dwi_space.nii.gz
		mrcalc ${nl[$i]}/03_nl${i}_mask_in_dwi_space.mif ${nl[$i]}/03_nl${i}_mask.mif -max ${nl[$i]}/03_nl${i}_mask_max.mif 
	done
	for ((i=0;i< $epsub ;i++));
	do
		bet ${ep[$i]}/ep${i}_nii/ep${i}_str.nii ${ep[$i]}/ep${i}_nii/ep${i}_str_bet.nii.gz -m -f 0.65
		bet ${ep[$i]}/ep${i}_nii/ep${i}_dwi.nii ${ep[$i]}/ep${i}_nii/ep${i}_dwi1_bet.nii.gz -m -f 0.3
		flirt -in ${ep[$i]}/ep${i}_nii/ep${i}_str_bet.nii.gz -ref ${ep[$i]}/ep${i}_nii/ep${i}_dwi_bet.nii.gz -out ${ep[$i]}/00_ep${i}_str2dwi_bet.nii.gz -omat ${ep[$i]}/ep${i}_nii/ep${i}_mat_str2dwi.mat
		flirt -in ${ep[$i]}/ep${i}_nii/ep${i}_str_bet_mask.nii.gz -ref ${ep[$i]}/ep${i}_nii/ep${i}_dwi_bet.nii.gz -applyxfm -init ${ep[$i]}/ep${i}_nii/ep${i}_mat_str2dwi.mat -out ${ep[$i]}/03_ep${i}_mask_in_dwi_space.nii.gz
		rm ${ep[$i]}/ep${i}_nii/ep${i}_dwi_bet.nii.gz ${ep[$i]}/ep${i}_nii/ep${i}_str_bet_mask.nii.gz ${ep[$i]}/ep${i}_nii/ep${i}_dwi_bet_mask.nii.gz 
		mrconvert ${ep[$i]}/ep${i}_nii/ep${i}_dwi1_bet_mask.nii.gz ${ep[$i]}/03_ep${i}_mask_cor.mif
		mrconvert ${ep[$i]}/00_ep${i}_str2dwi_bet.nii.gz ${ep[$i]}/00_ep${i}_str2dwi_bet..mif
		rm ${ep[$i]}/00_ep${i}_str2dwi_bet.nii.gz ${ep[$i]}/03_ep${i}_mask_in_dwi_space.nii.gz
		mrcalc ${ep[$i]}/03_ep${i}_mask_in_dwi_space.mif ${ep[$i]}/03_ep${i}_mask.mif -max ${ep[$i]}/03_ep${i}_mask_max.mif 
	done
	for ((i=10;i< $bisub ;i++));
	do
		bet ${bi[$i]}/bi${i}_nii/bi${i}_str.nii ${bi[$i]}/bi${i}_nii/bi${i}_str_bet.nii.gz -m -f 0.35
		bet ${bi[$i]}/bi${i}_nii/bi${i}_dwi.nii ${bi[$i]}/bi${i}_nii/bi${i}_dwi_bet.nii.gz -m -f 0.4
		mrcalc ${bi[$i]}/03_bi${i}_mask_in_dwi_space.mif ${bi[$i]}/03_bi${i}_mask.mif -max ${bi[$i]}/03_bi${i}_mask_max.mif 
		flirt -in ${bi[$i]}/bi${i}_nii/bi${i}_str_bet.nii.gz -ref ${bi[$i]}/bi${i}_nii/bi${i}_dwi_bet.nii.gz -out ${bi[$i]}/00_bi${i}_str2dwi_bet.nii.gz -omat ${bi[$i]}/bi${i}_nii/bi${i}_mat_str2dwi.mat
		flirt -in ${bi[$i]}/bi${i}_nii/bi${i}_str_bet_mask.nii.gz -ref ${bi[$i]}/bi${i}_nii/bi${i}_dwi_bet.nii.gz -applyxfm -init ${bi[$i]}/bi${i}_nii/bi${i}_mat_str2dwi.mat -out ${bi[$i]}/03_bi${i}_mask_in_dwi_space.nii.gz
		rm ${bi[$i]}/bi${i}_nii/bi${i}_dwi_bet.nii.gz ${bi[$i]}/bi${i}_nii/bi${i}_str_bet_mask.nii.gz ${bi[$i]}/bi${i}_nii/bi${i}_dwi_bet_mask.nii.gz 
		mrconvert ${bi[$i]}/bi${i}_nii/bi${i}_dwi_bet_mask.nii.gz ${bi[$i]}/03_bi${i}_mask_cor.mif
		mrconvert ${bi[$i]}/00_bi${i}_str2dwi_bet.nii.gz ${bi[$i]}/00_bi${i}_str2dwi_bet..mif
		rm ${bi[$i]}/00_bi${i}_str2dwi_bet.nii.gz ${bi[$i]}/03_bi${i}_mask_in_dwi_space.nii.gz
		mrcalc ${bi[$i]}/03_bi${i}_mask_in_dwi_space.mif ${bi[$i]}/03_bi${i}_mask.mif -max ${bi[$i]}/03_bi${i}_mask_max.mif 
	done
echo "Step 3 is performed. Please enter the step number..."
;;
###############################  step 4  ##############################
4)
echo "Performing step 4:"
	echo Step 4: Computing unbiased DWIs using preprocessed data and its masks  
	
	for ((i=0;i< $nlsub ;i++));
	do	dwibiascorrect -ants -mask ${nl[$i]}/03_nl${i}_mask_max.mif ${nl[$i]}/02_nl${i}_dwi_preproc_AP.mif ${nl[$i]}/04_nl${i}_dwi_unbias.mif			
		
	done
	for ((i=0;i< $epsub ;i++));
	do	dwibiascorrect -ants -mask ${ep[$i]}/03_ep${i}_mask_cor.mif ${ep[$i]}/02_ep${i}_dwi_preproc_AP.mif ${ep[$i]}/04_ep${i}_dwi_unbias.mif			
		
	done
	for ((i=0;i< $bisub ;i++));
	do	dwibiascorrect -ants -mask ${bi[$i]}/03_bi${i}_mask_cor.mif ${bi[$i]}/02_bi${i}_dwi_preproc.mif ${bi[$i]}/04_bi${i}_dwi_unbias.mif			
		
	done
echo "Step 4 is performed. Please enter the step number..."
;;
###############################  step 5  ##############################
5)
echo "Performing step 5:"

	echo Step 5: 
	mkdir $total/dwiintensitynorm
	mkdir $total/dwiintensitynorm/dwi_input
	mkdir $total/dwiintensitynorm/mask_input

	for ((i=0;i< $nlsub ;i++));
	do	ln -sr ${nl[$i]}/04_nl${i}_dwi_unbiased.mif $total/dwiintensitynorm/dwi_input/05_nl${i}norm.mif
		ln -sr ${nl[$i]}/03_nl${i}_mask_max.mif $total/dwiintensitynorm/mask_input/04_nl${i}_dwi_unbiased.mif
	done	
	for ((i=0;i< $epsub ;i++));
	do	ln -sr ${ep[$i]}/04_ep${i}_dwi_unbiased.mif $total/dwiintensitynorm/dwi_input/05_ep${i}norm.mif
		ln -sr ${ep[$i]}/03_ep${i}_mask_cor.mif $total/dwiintensitynorm/mask_input/04_ep${i}_dwi_unbiased.mif
		done
	for ((i=0;i< $bisub ;i++));	
	do	ln -sr bi${i}/04_bi${i}_dwi_unbiased.mif bi${i}/05_bi${i}norm.mif
		ln -sr ${bi[$i]}/03_bi${i}_mask_cor.mif $total/dwiintensitynorm/mask_input/04_bi${i}_dwi_unbiased.mif
	done
    
	dwiintensitynorm $total/dwiintensitynorm/dwi_input/ $total/dwiintensitynorm/mask_input/ $total/dwiintensitynorm/dwi_output/ $total/dwiintensitynorm/fa_template.mif $total/dwiintensitynorm/fa_template_wm_mask.mif

	for ((i=0;i< $nlsub ;i++));
	do
		mv $total/dwiintensitynorm/dwi_output/04_nl${i}_dwi_unbias.mif ${nl[$i]}/05_nl${i}_dwi_normalized.mif
 	done
	for ((i=0;i< $epsub ;i++));
	do
		mv $total/dwiintensitynorm/dwi_output/04_ep${i}_dwi_unbias.mif ${ep[$i]}/05_ep${i}_dwi_normalized.mif
	done
	for ((i=0;i< $bisub ;i++));
	do
		mv $total/dwiintensitynorm/dwi_output/04_bi${i}_dwi_unbias.mif ${bi[$i]}/05_bi${i}_dwi_normalized.mif
	done
echo "Step 5 is performed. Please enter the step number..."
;;
###############################  step 6  ##############################
6)
echo "Performing step 6:"

	for ((i=0;i< $nlsub ;i++)); 
		do	dwi2response tournier -mask ${nl[$i]}/03_nl${i}_mask_max.mif ${nl[$i]}/05_nl${i}_dwi_normalized.mif ${nl[$i]}/06_nl${i}_response.txt
	done
	for ((i=0;i< $epsub ;i++)); 
		do	dwi2response tournier -mask ${ep[$i]}/03_ep${i}_mask_cor.mif ${ep[$i]}/05_ep${i}_dwi_normalized.mif ${ep[$i]}/06_ep${i}_response.txt	
	done
	for ((i=0;i< $bisub ;i++));
		do	dwi2response tournier -mask ${bi[$i]}/03_bi${i}_mask_cor.mif ${bi[$i]}/05_bi${i}_dwi_normalized.mif ${bi[$i]}/06_bi${i}_response.txt
	done
echo "Step 6 is performed. Please enter the step number..."
;;
###############################  step 7 & 8  ###########################
7)
echo "Performing step 7:"
	for ((i=0;i< $nlsub ;i++));
	do
		mrresize ${nl[$i]}/05_nl${i}_norm.mif -vox 0.9766,0.9766,1.25 ${nl[$i]}/07_nl${i}_dwi_upsampled.mif
		dwi2mask ${nl[$i]}/07_nl${i}_dwi_upsampled.mif ${nl[$i]}/08_nl${i}_dwi_upmask.mif
	done
	for ((i=0;i< $epsub ;i++));
	do
		mrresize ${ep[$i]}/05_ep${i}_norm.mif -vox 0.9766,0.9766,1.25 ${ep[$i]}/07_ep${i}_dwi_upsampled.mif
		dwi2mask ${ep[$i]}/07_ep${i}_dwi_upsampled.mif ${ep[$i]}/08_ep${i}_dwi_upmask.mif
	done
	for ((i=0;i< $bisub ;i++));
	do
		mrresize ${bi[$i]}/05_bi${i}_norm.mif -vox 0.9766,0.9766,1.25 ${bi[$i]}/07_bi${i}_dwi_upsampled.mif
		dwi2mask ${bi[$i]}/07_bi${i}_dwi_upsampled.mif ${bi[$i]}/08_bi${i}_dwi_upmask.mif
	done
echo "Step 7 and 8 are performed. Please enter the step number..."
;;
###############################  step 9  ##############################
9)
echo "Performing step 9:"
	for ((i=0;i< $nlsub ;i++));
	do
		dwiextract ${nl[$i]}/07_nl${i}_dwi_upsampled.mif ${nl[$i]}/09_nl${i}_dwi_extracted.mif
		dwi2fod -mask ${nl[$i]}/08_nl${i}_dwi_upmask.mif msmt_csd ${nl[$i]}/09_nl${i}_dwi_extracted.mif $total/group_average_response_nl.txt ${nl[$i]}/09_nl${i}_wmfod.mif
	done
for ((i=0;i< $epsub ;i++));
	do
		dwiextract ${ep[$i]}/07_ep${i}_dwi_upsampled.mif ${ep[$i]}/09_ep${i}_dwi_extracted.mif
		dwi2fod -mask ${ep[$i]}/08_ep${i}_dwi_upmask.mif msmt_csd ${ep[$i]}/09_ep${i}_dwi_extracted.mif $total/group_average_response_nl.txt ${ep[$i]}/09_ep${i}_wmfod.mif
	done
for ((i=0;i< $bisub ;i++));
	do
		dwiextract ${bi[$i]}/07_bi${i}_dwi_upsampled.mif ${bi[$i]}/09_bi${i}_dwi_extracted.mif
		dwi2fod -mask ${bi[$i]}/08_bi${i}_dwi_upmask.mif msmt_csd ${bi[$i]}/09_bi${i}_dwi_extracted.mif $total/group_average_response_nl.txt ${bi[$i]}/09_bi${i}_wmfod.mif
	done
echo "Step 9 is performed. Please enter the step number..."
;;
###############################  step 10  ##############################
10)
echo "Performing step 10:"
	mkdir -p $total/template/fod_input
	mkdir $total/template/mask_input
	for ((i=0;i< $nlsub ;i++));
	do
		ln -sr ${nl[$i]}/09_nl${i}_wmfod.mif $total/template/fod_input/PRE.mif
		ln -sr ${nl[$i]}/08_nl${i}_dwi_upmask.mif $total/template/mask_input/PRE.mif
	done    
	population_template  -voxel_size 0.9766,0.9766,1.25 $total/template/fod_input -mask_dir $total/template/mask_input $total/wmfod_template.mif
echo "Step 10 is performed. Please enter the step number..."
;;
###############################  step 11  ##############################
11)
echo "Performing step 11:"
	for ((i=0;i< $nlsub ;i++));
	do
		mrregister ${nl[$i]}/09_nl${i}_wmfod.mif -mask1 ${nl[$i]}/08_nl${i}_dwi_upmask.mif $total/wmfod_template.mif -nl_warp ${nl[$i]}/11_nl${i}_sub2tem_warp.mif ${nl[$i]}/11_nl${i}_tem2sub_warp.mif
	done
	for ((i=0;i< $epsub ;i++));
	do
		mrregister ${ep[$i]}/09_ep${i}_wmfod.mif -mask1 ${ep[$i]}/08_ep${i}_dwi_upmask.mif $total/wmfod_template.mif -nl_warp ${ep[$i]}/11_ep${i}_sub2tem_warp.mif ${ep[$i]}/11_ep${i}_tem2sub_warp.mif
	done
	for ((i=0;i< $bisub ;i++));
	do
		mrregister ${bi[$i]}/09_bi${i}_wmfod.mif -mask1 ${bi[$i]}/08_bi${i}_dwi_upmask.mif $total/wmfod_template.mif -nl_warp ${bi[$i]}/11_bi${i}_sub2tem_warp.mif ${bi[$i]}/11_bi${i}_tem2sub_warp.mif
	done
echo "Step 11 is performed. Please enter the step number..."
;;
###############################  step 12  ##############################
12)
echo "Performing step 12:"
	for ((i=0;i< $nlsub ;i++));
	do
		mrtransform ${nl[$i]}/08_nl${i}_dwi_upmask.mif -warp ${nl[$i]}/11_nl${i}_sub2tem_warp.mif -interp nearest ${nl[$i]}/12_nl${i}_mask_in_template_space.mif
	done
	for ((i=0;i< $epsub ;i++));
	do
		mrtransform ${ep[$i]}/08_ep${i}_dwi_upmask.mif -warp ${ep[$i]}/11_ep${i}_sub2tem_warp.mif -interp nearest ${ep[$i]}/12_ep${i}_mask_in_template_space.mif
	done
	for ((i=0;i< $bisub ;i++));
	do
		mrtransform ${bi[$i]}/08_bi${i}_dwi_upmask.mif -warp ${bi[$i]}/11_bi${i}_sub2tem_warp.mif -interp nearest ${bi[$i]}/12_bi${i}_mask_in_template_space.mif
	done
# mrmath */dwi_mask_in_template_space.mif min ../template/template_mask.mif -datatype bit
echo "Step 12 is performed. Please enter the step number..."
;;
###############################  step 13  ##############################
13)
echo "Performing step 13:"
	fod2fixel $total/wmfod_template.mif -mask $temp/mask_intersection_nl.mif $temp/fixel_temp -peak peaks.mif
	mrthreshold $temp/fixel_temp/peaks.mif -abs $peak_threshold $temp/fixel_temp/mask.mif
	fixel2voxel $temp/fixel_temp/mask.mif max - | mrfilter - median $temp/voxel_mask.mif
	rm -rf $temp/fixel_temp
	fod2fixel -mask $temp/voxel_mask.mif -fmls_peak_value $fixel_threshold $total/wmfod_template.mif $temp/fixel_mask
echo "Step 13 is performed. Please enter the step number..."
;;
###############################  step 14  ##############################
14)
echo "Performing step 14:"
	for ((i=0;i< $nlsub ;i++));
	do
		mrtransform ${nl[$i]}/09_nl${i}_wmfod.mif -warp ${nl[$i]}/11_nl${i}_sub2tem_warp.mif -noreorientation ${nl[$i]}/14_nl${i}_wmfod_in_template_space.mif
	done
	for ((i=0;i< $epsub ;i++));
	do
		mrtransform ${ep[$i]}/09_ep${i}_wmfod.mif -warp ${ep[$i]}/11_ep${i}_sub2tem_warp.mif -noreorientation ${ep[$i]}/14_ep${i}_wmfod_in_template_space.mif
	done
	for ((i=0;i< $bisub ;i++));
	do
		mrtransform ${bi[$i]}/09_bi${i}_wmfod.mif -warp ${bi[$i]}/11_bi${i}_sub2tem_warp.mif -noreorientation ${bi[$i]}/14_bi${i}_wmfod_in_template_space.mif
	done
echo "Step 14 is performed. Please enter the step number..."
;;
###############################  step 15  ##############################
15)
echo "Performing step 15:"
	for ((i=0;i< $nlsub ;i++));
	do
		fod2fixel ${nl[$i]}/14_nl${i}_wmfod_in_template_space.mif -mask $tempwm/voxel_mask_wm.mif ${nl[$i]}/15_nl${i}_fixel_in_in_template_space -afd 15_nl${i}_fd.mif
	done
	for ((i=0;i< $epsub ;i++));
	do
		fod2fixel ${ep[$i]}/14_ep${i}_wmfod_in_template_space.mif -mask $tempwm/voxel_mask_wm.mif ${ep[$i]}/15_ep${i}_fixel_in_in_template_space -afd 15_ep${i}_fd.mif
	done
	for ((i=0;i< $bisub ;i++));
	do
		fod2fixel ${bi[$i]}/14_bi${i}_wmfod_in_template_space.mif -mask $tempwm/voxel_mask_wm.mif ${bi[$i]}/15_bi${i}_fixel_in_in_template_space -afd 15_bi${i}_fd.mif
	done
echo "Step 15 is performed. Please enter the step number..."
;;
###############################  step 16  ##############################
16)
echo "Performing step 16:"
	for ((i=0;i< $nlsub ;i++));
	do
		fixelreorient ${nl[$i]}/15_nl${i}_fixel_in_in_template_space ${nl[$i]}/11_nl${i}_sub2tem_warp.mif ${nl[$i]}/15_nl${i}_fixel_in_in_template_space --force
	done
	for ((i=0;i< $epsub ;i++));
	do
		fixelreorient ${ep[$i]}/15_ep${i}_fixel_in_in_template_space ${ep[$i]}/11_ep${i}_sub2tem_warp.mif ${ep[$i]}/15_ep${i}_fixel_in_in_template_space --force
	done
	for ((i=0;i< $bisub ;i++));
	do
		fixelreorient ${bi[$i]}/15_bi${i}_fixel_in_in_template_space ${bi[$i]}/11_bi${i}_sub2tem_warp.mif ${bi[$i]}/15_bi${i}_fixel_in_in_template_space --force
	done
echo "Step 16 is performed. Please enter the step number..."
;;
###############################  step 17  ##############################
17)
echo "Performing step 17:"
	for ((i=0;i< $nlsub ;i++));
	do
		fixelcorrespondence ${nl[$i]}/15_nl${i}_fixel_in_in_template_space/15_nl${i}_fd.mif $tempwm/fixel_mask_wm_new $tempwm/fd nl${i}.mif
	done
	for ((i=0;i< $epsub ;i++));
	do
		fixelcorrespondence ${ep[$i]}/15_ep${i}_fixel_in_in_template_space/15_ep${i}_fd.mif $tempwm/fixel_mask_wm_new $tempwm/fd ep${i}.mif
	done
	for ((i=0;i< $bisub ;i++));
	do
		fixelcorrespondence ${bi[$i]}/15_bi${i}_fixel_in_in_template_space/15_bi${i}_fd.mif $tempwm/fixel_mask_wm_new $tempwm/fd bi${i}.mif
	done
echo "Step 17 is performed. Please enter the step number..."
;;
###############################  step 18  ##############################
18)
echo "Performing step 18:"
	for ((i=0;i< $nlsub ;i++));
	do
		warp2metric ${nl[$i]}/11_nl${i}_sub2tem_warp.mif -fc $tempwm/fixel_mask_wm_new $tempwm/fc nl${i}.mif
	done
	for ((i=0;i< $epsub ;i++));
	do
		warp2metric ${ep[$i]}/11_ep${i}_sub2tem_warp.mif -fc $tempwm/fixel_mask_wm_new $tempwm/fc ep${i}.mif
	done
	for ((i=0;i< $bisub ;i++));
	do
		warp2metric ${bi[$i]}/11_bi${i}_sub2tem_warp.mif -fc $tempwm/fixel_mask_wm_new $tempwm/fc bi${i}.mif
	done

	mkdir $tempwm/log_fc
	cp $tempwm/fc/index.mif $tempwm/fc/directions.mif $tempwm/log_fc
	
	for ((i=0;i< $nlsub ;i++));
	do
		mrcalc $tempwm/fc/nl${i}.mif -log $tempwm/log_fc/nl${i}.mif
	done
	for ((i=0;i< $epsub ;i++));
	do
		mrcalc $tempwm/fc/ep${i}.mif -log $tempwm/log_fc/ep${i}.mif
	done
	for ((i=0;i< $bisub ;i++));
	do
		mrcalc $tempwm/fc/bi${i}.mif -log $tempwm/log_fc/bi${i}.mif
	done
echo "Step 18 is performed. Please enter the step number..."
;;
###############################  step 19  ##############################
19)
echo "Performing step 19:"
mkdir $tempwm/fdc
cp $tempwm/fc/index.mif cp $tempwm/fc/directions.mif $tempwm/fdc

	for ((i=0;i< $nlsub ;i++));
	do
		mrcalc $tempwm/fd/nl${i}.mif $tempwm/fc/nl${i}.mif -mult $tempwm/fdc/nl${i}.mif
	done
	for ((i=0;i< $epsub ;i++));
	do
		mrcalc $tempwm/fd/ep${i}.mif $tempwm/fc/ep${i}.mif -mult $tempwm/fdc/ep${i}.mif
	done
	for ((i=0;i< $bisub ;i++));
	do
		mrcalc $tempwm/fd/bi${i}.mif $tempwm/fc/bi${i}.mif -mult $tempwm/fdc/bi${i}.mif
	done
    
cd $tempwm
tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 wmfod_template.mif -seed_image template_mask.mif -mask template_mask.mif -select 20000000 -cutoff 0.10 tracks_20_million.tck
tcksift tracks_20_million.tck wmfod_template.mif tracks_sift_tl_wm_asli.tcks -term_number 2000000
echo "Step 19 is performed. Please enter the step number..."
;;
######################################################################
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ANALYZE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
######################################################################

############################### step 20 ##############################
############################### NL vs L ##############################
20)
echo "Performing step 20:"
	fixelcfestats $tempwm/fd $tempwm/analyze/nl_vs_ep_l/files.txt $tempwm/analyze/nl_vs_ep_l/design_matrix.txt $tempwm/analyze/nl_vs_ep_l/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/nl_vs_ep_l/stats_fd_nl_vs_ep_l
	fixelcfestats $tempwm/log_fc $tempwm/analyze/nl_vs_ep_l/files.txt $tempwm/analyze/nl_vs_ep_l/design_matrix.txt $tempwm/analyze/nl_vs_ep_l/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/nl_vs_ep_l/stats_log_fc_nl_vs_ep_l
	fixelcfestats $tempwm/fdc $tempwm/analyze/nl_vs_ep_l/files.txt $tempwm/analyze/nl_vs_ep_l/design_matrix.txt $tempwm/analyze/nl_vs_ep_l/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/nl_vs_ep_l/stats_fdc_nl_vs_ep_l
echo "Step 20 is performed. Please enter the step number..."
;;
###############################  step 21 ##############################
############################### NL vs R  ##############################
21)
echo "Performing step 21:"
	fixelcfestats $tempwm/fd $tempwm/analyze/nl_vs_ep_r/files.txt $tempwm/analyze/nl_vs_ep_r/design_matrix.txt $tempwm/analyze/nl_vs_ep_r/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/nl_vs_ep_r/stats_fd_nl_vs_ep_r
	fixelcfestats $tempwm/log_fc $tempwm/analyze/nl_vs_ep_r/files.txt $tempwm/analyze/nl_vs_ep_r/design_matrix.txt $tempwm/analyze/nl_vs_ep_r/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/nl_vs_ep_r/stats_log_fc_nl_vs_ep_r
	fixelcfestats $tempwm/fdc $tempwm/analyze/nl_vs_ep_r/files.txt $tempwm/analyze/nl_vs_ep_r/design_matrix.txt $tempwm/analyze/nl_vs_ep_r/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/nl_vs_ep_r/stats_fdc_nl_vs_ep_r
echo "Step 21 is performed. Please enter the step number..."
;;
###############################  step 22 ##############################
############################### NL vs RL ##############################
22)
echo "Performing step 22:"
	fixelcfestats $tempwm/fd $tempwm/analyze/nl_vs_ep_rl/files.txt $tempwm/analyze/nl_vs_ep_rl/design_matrix.txt $tempwm/analyze/nl_vs_ep_rl/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/nl_vs_ep_rl/stats_fd_nl_vs_ep_rl
	fixelcfestats $tempwm/log_fc $tempwm/analyze/nl_vs_ep_rl/files.txt $tempwm/analyze/nl_vs_ep_rl/design_matrix.txt $tempwm/analyze/nl_vs_ep_rl/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/nl_vs_ep_rl/stats_log_fc_nl_vs_ep_rl
	fixelcfestats $tempwm/fdc $tempwm/analyze/nl_vs_ep_rl/files.txt $tempwm/analyze/nl_vs_ep_rl/design_matrix.txt $tempwm/analyze/nl_vs_ep_rl/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/nl_vs_ep_rl/stats_fdc_nl_vs_ep_rl
echo "Step 22 is performed. Please enter the step number..."
;;
###############################  step 23 ##############################
###############################  L vs R  ##############################
23)
echo "Performing step 23:"
	fixelcfestats $tempwm/fd $tempwm/analyze/epl_vs_epr/files.txt $tempwm/analyze/epl_vs_epr/design_matrix.txt $tempwm/analyze/epl_vs_epr/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/epl_vs_epr/stats_fd_epl_vs_epr
	fixelcfestats $tempwm/log_fc $tempwm/analyze/epl_vs_epr/files.txt $tempwm/analyze/epl_vs_epr/design_matrix.txt $tempwm/analyze/epl_vs_epr/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/epl_vs_epr/stats_log_fc_epl_vs_epr
	fixelcfestats $tempwm/fdc $tempwm/analyze/epl_vs_epr/files.txt $tempwm/analyze/epl_vs_epr/design_matrix.txt $tempwm/analyze/epl_vs_epr/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/epl_vs_epr/stats_fdc_epl_vs_epr
echo "Step 23 is performed. Please enter the step number..."
;;
###############################  step 24 ##############################
############################### NL vs bi  ##############################
24)
echo "Performing step 24:"
	fixelcfestats $tempwm/fd $tempwm/analyze/nl_vs_bi/files.txt $tempwm/analyze/nl_vs_bi/design_matrix.txt $tempwm/analyze/nl_vs_bi/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/nl_vs_ep_r/stats_fd_nl_vs_bi
	fixelcfestats $tempwm/log_fc $tempwm/analyze/nl_vsbi/files.txt $tempwm/analyze/nl_vs_bi/design_matrix.txt $tempwm/analyze/nl_vs_bi/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/nl_vs_ep_r/stats_log_fc_nl_vs_bi
	fixelcfestats $tempwm/fdc $tempwm/analyze/nl_vs_bi/files.txt $tempwm/analyze/nl_vs_bi/design_matrix.txt $tempwm/analyze/nl_vs_bi/contrast_matrix.txt $tempwm/tracks_sift_tl_wm_asli.tck $tempwm/analyze/nl_vs_ep_r/stats_fdc_nl_vs_bi
echo "Step 24 is performed. Please enter the step number..."
;;
	end)
		echo "closing the analyze"
		break
		;;
	*)
		echo "Sorry, it's not defined"
		;;
  esac
done
