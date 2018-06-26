# Intergenerational wealth mobility

This repository contains the complete Stata and R code for generating all figures and tables in the paper "Intergenerational wealth mobility and the role of inheritance: Evidence from multiple generations" by Adrian Adermon, Mikael Lindahl, and Daniel Waldenström.

All of the analysis except for the figures was performed using Stata version 14.2; the graphs were created using the R statistical package version 3.4.2. The file master.do contains a list of the other do-files in the order they must be executed, together with short descriptions of what each files does, which input files it requires, and which output files it produces. All data cleaning, merging, and analysis steps can be performed at once by executing this file. The individual do-files contain further documentation of the code.

In order to run the analysis, the main directory must include a subdirectory called "do-files" containing the analysis files from this repository; and a subdirectory called "data" containing the source data files for the project. For information on how to obtain the data files, contact the authors or [IFAU](https://www.ifau.se/en/). 
