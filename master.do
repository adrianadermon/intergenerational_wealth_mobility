version 14.2

*-------------*
* Master file *
*-------------*

/* This should be set to your working directory, which must containg the
subdirectory "data" containing the files listed below, and the subdirectory
"data\workdata" for saving intermediate results
*/
cd "C:\Intergenerational wealth"

/* Required input files
*----------------------
malmorelationer, louise\louise_1985-2008, malmobas_lopnr, incomes\iot_68-85, ureg_sunkod_2009,
familjindikator_ut, cpi, wealth\form85, wealth\form88, wealth\form91, malmobas_formogenhet_1999,
form_2006, kapitalinkomster1937_ut, scbluga_adrian_insamling52_ut, kapink45, bouppteckningar,
arvsstegar_final_ut
*/

* Define a program for transforming wealth variables
include "do-files\transprog"
* Provides transprog

*** Data preparation ***

* Create the extended Malmo data
include "do-files\malmoext"
* Uses malmorelationer, louise_1985-2008, malmobas_lopnr, iot_68-85, ureg_sunkod_2009
* Creates malmorelationerextended


* Clean up incomes data
include "do-files\incomes_cleanup"
* Uses malmorelationerextended
* Creates malmorelationerextended_incomes

* Prepare income data
include "do-files\prepare_incomes"
/* Uses cpi, malmorelationerextended_incomes, malmorelationerextended
Creates incomes_fam_1stGen, incomes_fam_2ndGen, incomes_ind_2ndGen,
	incomes_fam_3rdGen, incomes_ind_3rdGen */

* Create family indicator for clustering
include "do-files\create_cluster_id"
* Uses familjindikator_ut, Malmorelationer
* Creates cluster_id

* Prepare tax wealth data
include "do-files\tax_wealth_prepare"
/* Uses form85, form88, form91, malmobas_formogenhet_1999, form_2006,
	kapitalinkomster1937_ut, kapink45,
	malmorelationerextended,
  scbluga_adrian_insamling52_ut
Creates tax_wealth_2ndGen, tax_wealth_3rdGen_young, tax_wealth_3rdGen,
tax_wealth_1stGen, tax_wealth_4thGen */

*Prepare estate wealth data
include "do-files\estate_wealth_prepare"
/* Uses bouppteckningar, cpi
	malmorelationerextended
Creates estate_wealth_1stGen */

* Prepare inheritance data
include "do-files\inheritance_prepare"
/* Uses arvsstegar_final_ut, cpi, malmorelationerextended
Creates inheritances_2ndGen_ind, inheritances_2ndGen */

* Calculate 2nd gen wealth purged of capitalized inheritances
include "do-files\inheritance_capitalize"
/* Uses inheritances_2ndGen, tax_wealth_2ndGen
Creates inheritances_cap_purged */

* Merge data sets for each generation
include "do-files\merge_data"
/* Uses malmorelationerextended, tax_wealth_1stGen, estate_wealth_1stGen,
	tax_wealth_2ndGen, inheritances_cap_purged,
	incomes_ind_2ndGen, incomes_fam_1stGen,
	tax_wealth_3rdGen, tax_wealth_3rdGen_young,
	incomes_ind_3rdGen, incomes_fam_2ndGen,
	tax_wealth_4thGen, incomes_fam_3rdGen
Creates merged_1stGen, merged_2ndGen, merged_3rdGen, merged_4thGen */

* Create estimation files
include "do-files\final_merge"
/* Uses merged_1stGen, merged_2ndGen, merged_3rdGen, merged_4thGen,
	cluster_id
Creates estimation_data_4thGen, estimation_data_3rdGen, estimation_data_2ndGen */

* Create an indicator for the three-generation panel sample
include "do-files\ind_321sample"
* Uses malmorelationerextended, estimation_data_2ndGen, estimation_data_3rdGen
* Creates gen2ind_321sample, gen3ind_321sample

*** Analysis ***

* Tables 1-2, appendix tables 1-2
include "do-files\summary_statistics"
* Uses malmorelationerextended_incomes,
* estimation_data_2ndGen, estimation_data_3rdGen, estimation_data_4thGen

* Tables 4a and 9, appendix tables 3a-c, 4-6, 8, 14-15
include "do-files\regressions_main"
* Uses estimation_data_2ndGen, estimation_data_3rdGen,
*	gen2ind_321sample, gen3ind_321sample

* Table 4b and appendix table 7
include "do-files\imputation_bootstrap"
* Uses estimation_data_2ndGen, estimation_data_3rdGen

* Table 5
include "do-files\regressions_4gen"
* Uses estimation_data_4thGen

* Tables 7-8, appendix tables 9-13
include "do-files\regressions_inheritance"
* Uses estimation_data_2ndGen
* Creates inh_sample

* Table 6
include "do-files\rentiers_savers"
* Uses inheritances_2ndGen, tax_wealth_2ndGen, inh_sample

* Appendix table 3
include "do-files\imputation_bootstrap_estate"
* Uses estimation_data_2ndGen, estimation_data_3rdGen

* Prepare data for creating graphs in R (Figure 1 and Appendix Figure 1)
include "do-files\figures"
* Uses estimation_data_2ndGen, estimation_data_3rdGen, estimation_data_4thGen
* Creates plot_data

include "do-files\figures_estate"
* Uses estimation_data_2ndGen, estimation_data_3rdGen, estimation_data_4thGen
* Creates plot_data_estate

include "do-files\figures_imputed"
* Uses estimation_data_2ndGen, estimation_data_3rdGen, estimation_data_4thGen
* Creates plot_data_imputed

* Graphs are created by running the file plots.R in R
