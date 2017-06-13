*----------------------------------------------------------------------------------------*
* Create a data file containing 1st generation (index persons' fathers) wealth variables *
*----------------------------------------------------------------------------------------*

use "data\bouppteckningar.dta", clear

rename Mid_SCB mid_scb

keep  far_f_dd far_d_d fars_tilg_ngar fars_g_ld mid_scb livf__far livf__mor

rename far_f_dd fatherborn
rename far_d_d fatherdead
rename fars_tilg_ngar fatherW
rename fars_g_ld fatherD

sort mid_scb

* Remove duplicate observations
*-------------------------------

duplicates drop

* Tag all duplicates on the family identifier
duplicates tag mid_scb, gen(dups)

* For duplicates that have missing values on some variables in only one of the observations, this 
* copies values to make the duplicates identical on all variables
ds, has(type string)
foreach v in `r(varlist)' { 
	bysort mid_scb (`v') : replace `v' = `v'[_N] if missing(`v') & dups>0
} 


ds, has(type numeric)
foreach v in `r(varlist)' { 
	bysort mid_scb (`v') : replace `v' = `v'[1] if missing(`v') & dups>0
}

* Drop duplicates on all variables
duplicates drop

drop dups


*-------------------------------

* Replace some wrong values (according to Sofia)

replace fatherD = "15" if mid_scb==78
replace fatherD = "." if mid_scb>=124 & mid_scb<=156
replace fatherD = "." if fatherD=="-"
replace fatherD = "15" if fatherD=="-15"
replace fatherD = "." if fatherD=="?"

replace fatherW = "." if mid_scb>=123 & mid_scb<=156
replace fatherW = "." if fatherW=="-"
replace fatherW = "." if fatherW=="?"

destring fatherW fatherD, replace

drop if fatherW==. & fatherD==.

* Create year of death variables, and fix some issues

replace fatherdead = "" if mid_scb==674
gen fatherdy = substr(fatherdead,1,4)
destring fatherdead fatherdy, replace
replace fatherdead = 193000 if fatherdead==1930
replace fatherdead = 194100 if fatherdead==1941

replace fatherborn = "190801" if fatherborn=="080102"
gen fatherby = substr(fatherborn,1,4)
destring fatherborn fatherby, replace

* Create net wealth variables and adjust for inflation
gen year=fatherdy
drop if year==.
merge m:1 year using "data\cpi.dta", keep(match master) nogenerate
drop year

gen wd = (fatherW*100 - fatherD*100)*(4434/cpi)
drop cpi


keep wd mid_scb fatherby fatherdy

rename wd =_far
rename father* *_far

*save "data\workdata\estate_wealth_1stGen_fathers_new.dta", replace
tempfile estate_fathers
save `estate_fathers'


*----------------------------------------------------------------------------------------*
* Create a data file containing 1st generation (index persons' mothers) wealth variables *
*----------------------------------------------------------------------------------------*

use "data\bouppteckningar.dta", clear

rename Mid_SCB mid_scb

keep  mor_f_dd mor_yrke_vid_f_dsel mor_d_d mors_tillg_ngar mors_g_ld mid_scb

rename mor_f_dd motherborn
rename  mor_yrke_vid_f_dsel motherprofB
rename mor_d_d motherdead
rename  mors_tillg_ngar motherW
rename  mors_g_ld motherD

sort mid_scb

* Remove duplicate observations
*------------------------------

duplicates drop

* Tag all duplicates on the family identifier
duplicates tag mid_scb, gen(dups)

* For duplicates that have missing values on some variables in only one of the observations, this 
* copies values to make the duplicates identical on all variables
ds, has(type string)
foreach v in `r(varlist)' { 
	bysort mid_scb (`v') : replace `v' = `v'[_N] if missing(`v') & dups>0
} 


ds, has(type numeric)
foreach v in `r(varlist)' { 
	bysort mid_scb (`v') : replace `v' = `v'[1] if missing(`v') & dups>0
}

* Drop duplicates on all variables
duplicates drop

drop dups

* Check if there are still any duplicates on the family identifier
duplicates report mid_scb

duplicates tag mid_scb, gen(dups)

* Fix the remaining duplicate
bysort mid_scb (motherW): replace motherW = motherW[2] if motherW=="-" & dups>0
duplicates drop

drop dups

*-------------------------------

replace motherW="." if motherW=="-"
replace motherD="." if motherD=="-"

destring motherW motherD, replace

drop if motherW==. & motherD==.

replace motherdead="197100" if motherdead=="(19710"
replace motherborn="189403" if motherborn=="199403"

gen motherby = substr(motherborn,1,4)
gen motherdy = substr(motherdead,1,4)

destring motherby motherdy motherborn motherdead, replace

* Create net wealth variables and adjust for inflation
gen year=motherdy
drop if year==.
merge m:1 year using "data\cpi.dta", keep(match master) nogenerate
drop year

gen wd = (motherW*100 - motherD*100)*(4434/cpi)
drop cpi

keep wd mid_scb motherdy motherby

rename wd =_mor
rename mother* *_mor

sort mid_scb


* Merge mothers and fathers into one file

merge 1:1 mid_scb using `estate_fathers', nogenerate

merge 1:m mid_scb using "data\workdata\malmorelationerextended.dta", nogenerate keep(match master) keepusing(*rby *rdy generation)
keep if generation=="Indexgen"

replace dy_far=fatherdy if dy_far==. & fatherdy!=.
replace dy_mor=motherdy if dy_mor==. & motherdy!=.
replace by_far=fatherby if by_far==. & fatherby!=.
replace by_mor=motherby if by_mor==. & motherby!=.

drop *ther* generation

* Calculate peak mid-parent lifetime wealth
gen wd = 0.5 * (wd_far + max(0, wd_mor)) if dy_far<dy_mor
replace wd = 0.5 * (max(0, wd_far) + wd_mor) if dy_far>dy_mor
replace wd = 0.5 * (wd_far + wd_mor) if dy_far==dy_mor

egen by=rowmean(by_mor by_far)
egen dy=rowmean(dy_mor dy_far)

save "data\workdata\estate_wealth_1stGen.dta", replace
