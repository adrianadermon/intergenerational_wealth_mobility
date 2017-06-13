* This file estimates life-time incomes for the 1st generation men, i.e. the fathers of the index generation

set more off

use "data\workdata\malmorelationerextended_incomes.dta", clear

keep lopnrgems mid_scb generation fathersyear fathery???? mothery???? fatherby motherby fatherdy motherdy

keep if generation=="Indexgen"
drop generation


reshape long fathery mothery, i(lopnrgems) j(year)

drop if mothery==. & fathery==.
replace mothery=0 if mothery==.
replace fathery=0 if fathery==.

egen famy=rowmean(fathery mothery)
egen by=rowmean(fatherby motherby)


* Adjust for inflation
* CPI 2010=4434
merge m:1 year using "data\cpi.dta", nogenerate keep(match master)
replace famy=famy*(4434/cpi)
drop cpi

gen age = year-by

gen loginc = log(famy)

reg loginc c.age##c.age##c.age i.year

predict e, resid

bysort lopnrgems: egen y_par=mean(e)
label variable y_par "Lifetime income, 1st generation"

* We drop all time-varying variables, and put the data back in cross-section format
keep lopnrgems mid_scb y_par
duplicates drop

save "data\workdata\incomes_fam_1stGen.dta", replace

*---------------------------------------------------------------------

* This file estimates life-time incomes for the 2nd generation, i.e. the index generation and their spouses

use "data\workdata\malmorelationerextended_incomes.dta", clear

keep if generation=="Indexgen" | generation=="Ejindexgen"

drop generation

keep lopnrgems mid_scb sex by y????

reshape long y, i(lopnrgems mid_scb) j(year)

tempfile gen2
save `gen2'




use "data\workdata\malmorelationerextended.dta", clear

keep if generation=="Barn" | generation=="Forald_bb"

keep lopnrgems lopnrgemsfar lopnrgemsmor

* Add 2nd gen
rename lopnrgems lopnrgems_barn
rename lopnrgemsmor lopnrgems

joinby lopnrgems using `gen2', unmatched(master) update
drop _merge

rename (year sex by y) =_mor

rename lopnrgems lopnrgemsmor
rename lopnrgemsfar lopnrgems

joinby lopnrgems using `gen2', unmatched(master) update
drop _merge

rename (year sex by y) =_far

rename lopnrgems lopnrgemsfar

rename lopnrgems_barn lopnrgems

duplicates drop

drop if year_mor!=year_far & year_mor!=. & year_far!=.

drop if year_mor==. & year_far==.

gen year=year_far
replace year=year_mor if year==.
drop year_far year_mor
drop sex*

drop if y_far==0 & y_mor==0

replace y_far=0 if y_far==.
replace y_mor=0 if y_mor==.

egen y_fam=rowmean(y_far y_mor)
egen by=rowmean(by_far by_mor)

* Adjust for inflation
* CPI 2010=4434
merge m:1 year using "data\cpi.dta", nogenerate keep(match master)
replace y_fam=y_fam*(4434/cpi)
drop cpi

gen age = year-by
drop if age<23

gen loginc = log(y_fam)

* Calculate weights for the regressions
duplicates tag lopnrgems year, gen(dups)
gen freq=dups+1
gen weight=1/freq
drop dups freq

* Predict incomes
reg loginc c.age##c.age##c.age i.year [pw=weight]
predict e, resid

bysort lopnrgems: egen y_par=mean(e)

label variable y_par "Lifetime income, 2nd generation"

* We drop all time-varying variables, and put the data back in cross-section format
keep lopnrgems y_par
duplicates drop

save "data\workdata\incomes_fam_2ndGen.dta", replace







*----------------------------------------------------------------------------------------------------

* This file estimates life-time incomes for the 2nd generation, i.e. the index generation and their spouses


use "data\workdata\malmorelationerextended_incomes.dta", clear

keep if generation=="Indexgen" | generation=="Ejindexgen"

keep lopnrgems mid_scb sex by y????

* Calculate weights for the regressions
bysort lopnrgems: egen freq=count(lopnrgems)
gen weight=1/freq
drop freq

reshape long y, i(lopnrgems mid_scb) j(year)

* Adjust for inflation
* CPI 2010=4434
merge m:1 year using "data\cpi.dta", nogenerate keep(match master)
replace y=y*(4434/cpi)
drop cpi

gen age = year-by
drop if age<23

gen loginc = log(y)
drop y


* Predict incomes for men
* Use age instead of birth year for numerical stability
reg loginc c.age##c.age##c.age i.year if sex==1 [pw=weight]
predict eM if sex==1, resid

bysort lopnrgems: egen meM=mean(eM)

* Predict incomes for women
reg loginc c.age##c.age##c.age i.year if sex==2 [pw=weight]
predict eW if sex==2, resid

bysort lopnrgems: egen meW=mean(eW)

gen y = meM
replace y = meW if sex==2
label variable y "Lifetime income, 2nd generation"

* We drop all time-varying variables, and put the data back in cross-section format
keep lopnrgems y
duplicates drop

save "data\workdata\incomes_ind_2ndGen.dta", replace



*----------------------------------------------------------------------------------------------------


/* This file estimates life-time incomes for the 3rd generation, i.e. the children of the index generation 
and their spouses */

use "data\workdata\malmorelationerextended_incomes.dta", clear

keep if generation=="Barn" | generation=="Forald_bb"

keep lopnrgems mid_scb by sex y????

duplicates drop

reshape long y, i(lopnrgems mid_scb) j(year) 

tempfile gen3
save `gen3'

use "data\workdata\malmorelationerextended.dta", clear

keep if generation=="Barnbarn"

keep lopnrgems* mid_scb

rename lopnrgems lopnrgems_barn

* Add 3rd gen
rename lopnrgemsmor lopnrgems

joinby lopnrgems using `gen3', unmatched(master) update
drop _merge

rename (year sex by y) =_mor

rename lopnrgems lopnrgemsmor
rename lopnrgemsfar lopnrgems

joinby lopnrgems using `gen3', unmatched(master) update
drop _merge

rename (year sex by y) =_far

rename lopnrgems lopnrgemsfar
rename lopnrgems_barn lopnrgems

duplicates drop

drop if year_mor!=year_far & year_mor!=. & year_far!=.

drop if year_mor==. & year_far==.

gen year=year_far
replace year=year_mor if year==.
drop year_far year_mor
drop sex*

drop if y_far==0 & y_mor==0

replace y_far=0 if y_far==.
replace y_mor=0 if y_mor==.

egen y_fam=rowmean(y_far y_mor)
egen by=rowmean(by_far by_mor)

* Adjust for inflation
* CPI 2010=4434
merge m:1 year using "data\cpi.dta", nogenerate keep(match master)
replace y_fam=y_fam*(4434/cpi)
drop cpi

gen age = year-by
drop if age<27

gen loginc = log(y_fam)

* Calculate weights for the regressions
duplicates tag lopnrgems year, gen(dups)
gen freq=dups+1
gen weight=1/freq
drop dups freq

* Predict incomes
reg loginc c.age##c.age##c.age i.year [pw=weight]
predict e, resid

bysort lopnrgems: egen y_par=mean(e)

label variable y_par "Lifetime income, 3rd generation"

* We drop all time-varying variables, and put the data back in cross-section format
keep lopnrgems y_par
duplicates drop

save "data\workdata\incomes_fam_3rdGen.dta", replace


*---------------------------------------------------------------------------------------------

/* This file estimates life-time incomes for the 3rd generation, i.e. the children of the index generation 
and their spouses */

use "data\workdata\malmorelationerextended_incomes.dta", clear

keep if generation=="Barn" | generation=="Forald_bb"

keep lopnrgems mid_scb by sex syear y????
duplicates drop

* Calculate weights for the regressions
bysort lopnrgems: egen freq=count(lopnrgems)
gen weight=1/freq
drop freq

reshape long y, i(lopnrgems mid_scb) j(year) 

* Adjust for inflation
* CPI 2010=4434
merge m:1 year using "data\cpi.dta", nogenerate keep(match master)
replace y=y*(4434/cpi)
drop cpi

gen age=year-by
drop if age<27

gen loginc=log(y)
drop y


* Predict incomes for men
reg loginc c.age##c.age##c.age i.year if sex==1 [pw=weight]
predict eM if sex==1, resid 

bysort lopnrgems: egen meM=mean(eM)


* Predict incomes for women
reg loginc c.age##c.age##c.age i.year if sex==2 [pw=weight]
predict eW if sex==2, resid

bysort lopnrgems: egen meW=mean(eW) if sex==2

gen y = meM
replace y = meW if sex==2

label variable y "Lifetime income, 3rd generation"

* We drop all time-varying variables, and put the data back in cross-section format
keep lopnrgems y
duplicates drop

save "data\workdata\incomes_ind_3rdGen.dta", replace
