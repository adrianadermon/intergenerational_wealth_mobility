* This file calculates wealth variables for the parent, index and child generations using tax register data
*----------------------------------------------------------------------------------------------------------

* For the index generation, we use 1985 and 1988 wealth, which corresponds to ages 57-60
use "data\wealth\form85.dta", clear

keep LopnrGems formskp ufast*

* This variable captures net wealth, censored at zero
rename formskp w_85

/* Since net wealth includes the tax value of real estate, which is 75 percent 
of the market value, we can add the difference between the market value and the 
tax value to net wealth to get a better measure. In particular, this reduces the 
number of zeros by around ten percentage points, since many people have zero net 
wealth but positive gross housing wealth. */
gen wr_85 = w_85 + (1/3)*(ufasts + ufastj + ufasth)

keep w* LopnrGems

merge 1:1 LopnrGems using "data\wealth\form88.dta", nogenerate keepusing(formskp ufast*)

* This variable captures net wealth, censored at zero
rename formskp w_88

/* Since net wealth includes the tax value of real estate, which is 75 percent 
of the market value, we can add the difference between the market value and the 
tax value to net wealth to get a better measure. In particular, this reduces the 
number of zeros by around ten percentage points, since many people have zero net 
wealth but positive gross housing wealth. */
gen wr_88 = w_88 + (1/3)*(ufasts + ufastj + ufasth)

merge 1:1 LopnrGems using "data\wealth\form91.dta", nogenerate keepusing(formskp)

rename formskp w_91

* Adjust for inflation, and scale up by 100
* CPI 1985=2246
* CPI 1988=2582
* CPI 2010=4434

foreach i of varlist w*85 {
	replace `i'=`i'*(4434/2246)*100
}

foreach i of varlist w*88 {
	replace `i'=`i'*(4434/2582)*100
}

replace w_91=w_91*(4434/3319)*100

gen wc_91=w_91 if w_91>=0
replace wc_91=0 if w_91<0

egen w = rowmean(w_85 w_88 w_91)
egen wr = rowmean(wr_85 wr_88)
egen wc = rowmean(w_85 w_88 wc_91)

keep LopnrGems w wr wc w_91

rename LopnrGems lopnrgems
destring lopnrgems, replace

merge 1:m lopnrgems using "data\workdata\malmorelationerextended.dta", keep(match master) keepusing(generation)

tempfile gen3
save `gen3'

keep if generation=="Indexgen" | generation=="Ejindexgen"
drop _merge generation

duplicates drop

save "data\workdata\tax_wealth_2ndGen.dta", replace

* Create young wealth for 3rd gen
use `gen3'

keep if generation=="Barn" | generation=="Forald_bb"

drop _merge generation

duplicates drop

keep lopnrgems w

rename w wy

save "data\workdata\tax_wealth_3rdGen_young.dta", replace



*----------------------------------------------------------------------

* For the children generation, we use 1999 and 2006 wealth, which corresponds to ages 43-50 on average
use "data\malmobas_formogenhet_1999.dta", clear
keep LopnrGems fnettmv

rename fnettmv w

rename w =_99


merge 1:1 LopnrGems using "data\form_2006.dta", nogenerate keepusing(fnettmv)

rename fnettmv w_06


* Adjust for inflation
* CPI 1999=3772
* CPI 2006=4152
* CPI 2010=4434

replace w_99=w_99*(4434/3772)
replace w_06=w_06*(4434/4152)

* Create alternative wealth variables that are censored at zero, and thus more comparable to those for the index generation
gen wc_99=w_99 if w_99>=0
replace wc_99=0 if w_99<0

gen wc_06=w_06 if w_06>=0
replace wc_06=0 if w_06<0


egen w = rowmean(w_99 w_06)
egen wc = rowmean(wc_99 wc_06)


rename LopnrGems lopnrgems
destring lopnrgems, replace

merge 1:m lopnrgems using "data\workdata\malmorelationerextended.dta", keep(match master) keepusing(generation)

keep if generation=="Barn" | generation=="Forald_bb"
drop _merge generation

duplicates drop

keep lopnrgems w wc

save "data\workdata\tax_wealth_3rdGen.dta", replace

*--------------------------------------------------------------------------------------------

* Prepare tax wealth data for the first generation
*-----------------------------------------------------------------------------

* Prepare 1952 capitalized income
use "data/scbluga_adrian_insamling52_ut.dta", clear
rename Lopnrgems lopnrgems
destring lopnrgems, replace

rename k_n sex
destring sex, replace
destring SPFORM52, gen(w52)

keep sex lopnrgems Avk3 w52

rename Avk3 wk52
destring wk52, replace
drop if wk52 == . & w52 == .

* Adjust for inflation
* CPI 1952=326
* CPI 2010=4434
foreach i of varlist w52 wk52 {
	replace `i'=`i'*(4434/326)
}

reshape wide w52 wk52, i(lopnrgems) j(sex)
rename *1 *_far
rename *2 *_mor

tempfile k52
save `k52'


* Prepare 1937 capitalized income for first generation fathers

use "data\kapitalinkomster1937_ut.dta", clear
rename Lopnrgems lopnrgems
destring lopnrgems, replace

gen wk37_far = kinkomst_1937/0.03

* Adjust for inflation
* CPI 1937=162
* CPI 2010=4434

replace wk37_far=wk37_far*(4434/162)

drop kinkomst_1937

tempfile k37
save `k37'

* For the parent generation, we use 1945 wealth, which on average corresponds to age 48
use "data\kapink45.dta", clear

rename k_n sex
rename f_delse_r by

* Fix a coding error
replace by=1908 if by==801

* w is wealth, calculated as W = 100*F = 100*(TAXBEL45+SAA45-SRI45)
* We also have two wealth variables calculated using reported returns. Avk2 assumes a 2 percent real interest rate, and Avk3 assumes 3 percent. The calculation is Avr(r) = KKAP / r

keep Lopnrgems sex by w Avk3

rename Avk3 wk45
rename w w45

destring wk45, replace


drop if w45==. & wk45==.

gen wk45s=wk45

replace wk45=0 if wk45==. & w45!=.

* There shouldn't be any negative values - set these to zero
replace w45=0 if w45<0

rename Lopnrgems lopnrgems
destring lopnrgems, replace


* Adjust for inflation
* CPI 1945=233
* CPI 2010=4434

foreach i of varlist w* {
  replace `i'=`i'*(4434/233)
}


reshape wide w45 wk45 wk45s by, i(lopnrgems) j(sex)
rename *1 *_far
rename *2 *_mor


merge m:1 lopnrgems using `k37', keep(match master) nogenerate

merge 1:1 lopnrgems using `k52', keep(match master) nogenerate

egen wk_far = rowmean(wk37_far wk45_far wk52_far)
egen wk_mor = rowmean(wk45_mor wk52_mor)
egen w_far = rowmean(w45_far w52_far)
egen w_mor = rowmean(w45_mor w52_mor)

keep lopnrgems by_* w_* wk_*

save "data\workdata\tax_wealth_1stGen.dta", replace



*----------------------------------------------------------------------

* For the grandchildren generation, we use 2006 wealth
use "data\form_2006.dta", clear
keep LopnrGems fnettmv

rename fnettmv w

* Adjust for inflation
* CPI 1999=3772
* CPI 2006=4152
* CPI 2010=4434

replace w=w*(4434/4152)

* Create alternative wealth variable that is censored at zero, and thus more comparable to that for the index generation
gen wc=w if w>=0
replace wc=0 if w<0

drop if w==.

rename LopnrGems lopnrgems
destring lopnrgems, replace

merge 1:m lopnrgems using "data\workdata\malmorelationerextended.dta", keep(match master) keepusing(generation)

keep if generation=="Barnbarn"
drop _merge generation

duplicates drop

save "data\workdata\tax_wealth_4thGen.dta", replace
