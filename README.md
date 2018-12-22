# DW-MRI-Group-Analysis
The goal of this project is to document known steps of doing the fixel-based analysis of fiber density and cross-section in single bash-script that provide an easy way to modify data managing of the analysis.

This repository includes pre-processing, registration and fixel-based analysis steps which can be clearly found in [here](https://mrtrix.readthedocs.io/en/latest/index.html).

This scripts use [Mrtrix3](https://github.com/MRtrix3/mrtrix3), [FSl](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation) and [ANTS](http://stnava.github.io/ANTs/) and instalation of these package is required.

This project includes three groups (nl, ep, bi) which the "nl" group is used to generate the template space!
# Usage
To perform analysis at first you need to redefine the directories. For further information about directory managing please check the sample-project-folder format.

For running each step, it just needs to import the step number after considering your directory using the commands included in the file.
