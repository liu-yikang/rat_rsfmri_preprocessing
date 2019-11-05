#!/bin/bash

datapath='/home/yliu/projects/organize_database/data/added_data/database_structure'
cd $datapath

for folder in $(ls | grep rat)
do
    if [ ! -d "$datapath/$folder/nifti" ]
    then
        mkdir $datapath/$folder/nifti
        /home/yliu/projects/tools/Bru2 -a -f -o $datapath/$folder/nifti $datapath/$folder/bruker
    fi
done
