#!/bin/sh
basedir=/seastor/helenhelen/isr
datadir=$basedir/Searchlight_RSM/ref_space/zscore/diff
for m in 1 2 3 4 6 7 9 10 13 14 17 20 21 22 23 27 30 35 36 37 38 39 41
do
    if [ ${m} -lt 10 ];
    then
       SUB=isr_0${m}
	sub=sub0${m}
    else
        SUB=isr_${m}
	sub=sub${m}
    fi
    echo $SUB
maskdir=$basedir/${SUB}/roi_ref
	for c in ERS_IBwc ERS_DBwc mem_DBwc ln_DBwc
	do
	resultdir=$basedir/peak/VVC/data/vvc_data/${c}
	mkdir $resultdir -p
	datafile=$datadir/${c}_${sub}.nii.gz
	maskfile=$maskdir/vvc.nii.gz
	resultfile=$resultdir/${sub}.nii.gz
	fsl_sub fslmaths $datafile -mul $maskfile $resultfile
	done
done
