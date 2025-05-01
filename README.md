# F-Phot-Analysis
This Matlab code was created for Michaelides' Lab to analyze fiber photometry across multiple animals with support for saline vs. drug conditions and per-minute AUC analysis.

 Fiber Photometry Analysis - MATLAB Toolkit

 ---------------------------------------------------------------
 FILES INCLUDED

- fn_plotfiberphotometry.m     : Main function to process and plot data
- fn_getMeasureByMin.m         : Helper function to compute per-minute AUC or mean
- shadedErrorBar.m             : Plotting utility for shaded SEM lines (MATLAB File Exchange)
- README.txt                   : 

---------------------------------------------------------------
 DATA FOLDER STRUCTURE

Your input folder should contain:

1. CSV files with normalized fiber photometry traces obtained by using pMAT (https://pubmed.ncbi.nlm.nih.gov/33385438). (e.g., rat1.csv, rat2.csv, ...)
2. A subfolder called `time_admin_files` that contains matching CSVs with administration timestamps for each animal.

Example:

    your_data_folder/
    ├── rat1.csv
    ├── rat2.csv
    ├── ...
    └── time_admin_files/
        ├── rat1.csv
        ├── rat2.csv
        └── ...

Each time_admin file should contain two rows:
- Row 1 = time of saline administration (in seconds)
- Row 2 = time of drug administration (in seconds)

---------------------------------------------------------------
 HOW TO RUN

1. Open MATLAB and set the folder as your working directory.
2. Run the following command in the Command Window or a script:

    datatosave = fn_plotfiberphotometry('your_data_folder');

3. Optional arguments:

    fn_plotfiberphotometry(folder, minutesbaseline, minutespost, toplotornot)

    - minutesbaseline : default = 1
    - minutespost     : default = 19
    - toplotornot     : default = 1 (1 = yes, 0 = no)

Example:
    
    datatosave = fn_plotfiberphotometry('C:\MyData', 1, 19, 1);

---------------------------------------------------------------
 OUTPUT

The function returns a struct `datatosave` with fields:

- time                 : time vector (in minutes)
- saline               : matrix of baseline-corrected traces (saline)
- cocaine              : matrix of baseline-corrected traces (drug)
- AUCsaline, AUCcocaine: full AUC values
- AUCsalineNorm        : normalized AUC after saline
- AUC_drugNorm         : normalized AUC after drug
- perminAUC            : per-minute AUCs (saline)
- perminAUCDrug        : per-minute AUCs (drug)

---------------------------------------------------------------
 DEPENDENCIES

- MATLAB R2020 or later
- shadedErrorBar.m (File Exchange ID: 26311)

Download shadedErrorBar from:
https://www.mathworks.com/matlabcentral/fileexchange/26311-shadederrorbar

---------------------------------------------------------------
 CONTACT

Maintainer: Oscar Solis Castrejon
Institution: NIDA / NIH]
Email: oscar.soliscastrejon@nih.gov]
