* Merge data for the 1st generation

use "data\workdata\malmorelationerextended.dta", clear

keep lopnrgems mid_scb generation fathersyear fatherby motherby fatherdy motherdy fathersyear
rename fathersyear fathers

keep if generation=="Indexgen"

rename father* *_far
rename mother* *_mor

merge 1:1 lopnrgems using "data\workdata\tax_wealth_1stGen.dta", update nogenerate

merge 1:1 mid_scb using "data\workdata\estate_wealth_1stGen.dta", update nogenerate


save "data\workdata\merged_1stGen.dta", replace

*------------------------------------------------------------------------------------------------

* Merge data for the 2nd generation, i.e. the index generation and their spouses

set more off

use "data\workdata\malmorelationerextended.dta", clear

keep if generation=="Indexgen" | generation=="Ejindexgen"

keep lopnrgems mid_scb by syear
rename syear s
replace s=. if by>1984

* Add tax wealth data
merge m:1 lopnrgems using "data\workdata\tax_wealth_2ndGen.dta", update nogenerate

* Add inheritance data
merge m:1 lopnrgems using "data\workdata\inheritances_2ndGen.dta", nogenerate

* Add capitalized inheritance data
merge m:1 lopnrgems using "data\workdata\inheritances_cap_purged.dta", nogenerate

* Add income data
merge m:1 lopnrgems using "data\workdata\incomes_ind_2ndGen.dta", nogenerate

* Add parental income data
merge m:1 lopnrgems using "data\workdata\incomes_fam_1stGen.dta", nogenerate

keep lopnrgems mid_scb by w* dy* inh* y* s one

save "data\workdata\merged_2ndGen.dta", replace

*-------------------------------------------------------------------------------------------------

* Merge data for the  3rd generation, i.e. the children of the index generation and their spouses

set more off

use "data\workdata\malmorelationerextended.dta", clear

keep if generation=="Barn" | generation=="Forald_bb"

keep lopnrgems mid_scb lopnrgemsfar lopnrgemsmor by sex syear
rename syear s
replace s=. if by>1984

* Add tax wealth data
merge m:1 lopnrgems using "data\workdata\tax_wealth_3rdGen.dta", nogenerate

merge m:1 lopnrgems using "data\workdata\tax_wealth_3rdGen_young.dta", nogenerate

* Add income data
merge m:1 lopnrgems using "data\workdata\incomes_ind_3rdGen.dta", nogenerate

* Add parental income data
merge m:1 lopnrgems using "data\workdata\incomes_fam_2ndGen.dta", nogenerate

keep lopnrgems* mid_scb by w wc wy y y_par s

save "data\workdata\merged_3rdGen.dta", replace

*---------------------------------------------------------------------------------------

* Merge data for the 4nd generation, i.e. the grandchildren of the index generation

set more off

use "data\workdata\malmorelationerextended.dta", clear

keep if generation=="Barnbarn"

keep lopnrgems* mid_scb sex by syear
rename syear s
replace s=. if by>1984

* Add tax wealth data
merge m:1 lopnrgems using "data\workdata\tax_wealth_4thGen.dta", nogenerate

* Add parental income data
merge m:1 lopnrgems using "data\workdata\incomes_fam_3rdGen.dta", nogenerate

keep lopnrgems* mid_scb by w wc y_par s
rename y_par y3

save "data\workdata\merged_4thGen.dta", replace
