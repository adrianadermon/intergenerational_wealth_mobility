set more off

*-----------------------------------------------------------------------------

* Create 4th gen regression file

use "data\workdata\merged_4thGen.dta", clear

rename (lopnrgems* by w mid_scb s) =4

* Add 3rd gen
rename lopnrgemsmor4 lopnrgems

joinby lopnrgems using "data\workdata\merged_3rdGen.dta", unmatched(master) update

rename (lopnrgemsmor lopnrgemsfar by w y_par s) =_mor_3
drop _merge mid_scb

rename lopnrgems lopnrgemsmor4
rename lopnrgemsfar4 lopnrgems

joinby lopnrgems using "data\workdata\merged_3rdGen.dta", unmatched(master) update
drop _merge mid_scb

rename (lopnrgemsmor lopnrgemsfar by w y_par s) =_far_3



rename lopnrgems lopnrgemsfar4

* Add 2nd gen
rename lopnrgemsmor_mor_3 lopnrgems

joinby lopnrgems using "data\workdata\merged_2ndGen.dta", unmatched(master) update
drop _merge mid_scb

rename (by w dy y_par s) =_mormor_2

joinby lopnrgems using "data\workdata\merged_1stGen.dta", unmatched(master) update
drop _merge mid_scb

rename *_mor *_mormorsmor
rename *_far *_mormorsfar

rename lopnrgems lopnrgemsmor_mor_3
rename lopnrgemsmor_far_3 lopnrgems

joinby lopnrgems using "data\workdata\merged_2ndGen.dta", unmatched(master) update
drop _merge mid_scb

rename (by w dy y_par s) =_morfar_2

joinby lopnrgems using "data\workdata\merged_1stGen.dta", unmatched(master) update
drop _merge mid_scb

rename *_mor *_morfarsmor
rename *_far *_morfarsfar

rename lopnrgems lopnrgemsmor_far_3
rename lopnrgemsfar_mor_3 lopnrgems

joinby lopnrgems using "data\workdata\merged_2ndGen.dta", unmatched(master) update
drop _merge mid_scb

rename (by w dy y_par s) =_farmor_2

joinby lopnrgems using "data\workdata\merged_1stGen.dta", unmatched(master) update
drop _merge mid_scb

rename *_mor *_farmorsmor
rename *_far *_farmorsfar

rename lopnrgems lopnrgemsfar_mor_3
rename lopnrgemsfar_far_3 lopnrgems

joinby lopnrgems using "data\workdata\merged_2ndGen.dta", unmatched(master) update
drop _merge mid_scb

rename (by w dy y_par s) =_farfar_2

joinby lopnrgems using "data\workdata\merged_1stGen.dta", unmatched(master) update
drop _merge mid_scb

rename *_mor *_farfarsmor
rename *_far *_farfarsfar

rename lopnrgems lopnrgemsfar_far_3


* Add clustering variable
rename mid_scb4 mid_scb

merge m:1 mid_scb using "data\workdata\cluster_id.dta", keep(match master) nogenerate

drop mid_scb
duplicates drop


foreach i in by y_par s {
	egen `i'3=rowmean(`i'_mor_3 `i'_far_3)
}

egen w3=rowtotal(w_mor_3 w_far_3), missing


rename y_par3 y2
drop by_*3 w*_*3 y_par_*_3

foreach i in by dy y_par s {
	egen `i'2=rowmean(`i'_mormor_2 `i'_morfar_2 `i'_farmor_2 `i'_farfar_2)
}

egen w2=rowtotal(w_mormor_2 w_morfar_2 w_farmor_2 w_farfar_2), missing


rename y_par2 y1

foreach i in by dy {
	egen `i'1 = rowmean(`i'_mormorsmor `i'_mormorsfar `i'_morfarsmor `i'_morfarsfar `i'_farmorsmor `i'_farmorsfar `i'_farfarsmor `i'_farfarsfar)
}

foreach i in w wk {
	egen `i'1 = rowtotal(`i'_mormorsmor `i'_mormorsfar `i'_morfarsmor `i'_morfarsfar `i'_farmorsmor `i'_farmorsfar `i'_farfarsmor `i'_farfarsfar), missing
}

egen s1 = rowmean(s_mormorsfar s_morfarsfar s_farmorsfar s_farfarsfar)


* Calculate peak mid-parent lifetime wealth for each set of great grandparents
foreach i in mormors morfars farmors farfars {
	gen wd_`i'par = 0.5 * (wd_`i'far + max(0, wd_`i'mor)) if dy_`i'far<dy_`i'mor
	replace wd_`i'par = 0.5 * (max(0, wd_`i'far) + wd_`i'mor) if dy_`i'far>dy_`i'mor
	replace wd_`i'par = 0.5 * (wd_`i'far + wd_`i'mor) if dy_`i'far==dy_`i'mor
}
egen wd1=rowtotal(wd_mormorspar wd_morfarspar wd_farmorspar wd_farfarspar), missing


drop by_*2 w*_*2

forvalues i=1/4 {
	* Round birth years
	replace by`i'=round(by`i')
}


* Main wealth variables
forvalues i=1/4{
	transprog, w(w) gen(`i')
}

* Capitalised wealth
transprog, w(wk) gen(1)

* Estate wealth
transprog, w(wd) gen(1)

* Incomes
forvalues i=1/3{
	transprog, w(y) gen(`i')
}
drop ln_y? ihs_y?

* Schooling
forvalues i=1/4{
	transprog, w(s) gen(`i')
}
drop ln_s? ihs_s?


label variable by4 "4th gen birth year"
label variable by3 "3rd gen birth year"
label variable by2 "2nd gen birth year"
label variable by1 "1st gen birth year"

label variable dy2 "2nd gen year of death"
label variable dy1 "1st gen year of death"

label variable w4 "4th gen wealth, 2006 tax data"
label variable w3 "3rd gen wealth, 1999 and 2006 tax data"
label variable w2 "2nd gen wealth, 1985 and 1988 tax data"
label variable w1 "1st gen wealth, 1945 and 1952 tax data"


label variable ihs_w4 "4th gen wealth, inverse hyperbolic sine, 2006 tax data"
label variable ihs_w3 "3rd gen wealth, inverse hyperbolic sine, 1999 and 2006 tax data"
label variable ihs_w2 "2nd gen wealth, inverse hyperbolic sine, 1985 and 1988 tax data"
label variable ihs_w1 "1st gen wealth, inverse hyperbolic sine, 1945 and 1952 tax data"

label variable ln_w4 "4th gen wealth, natural log, 2006 tax data"
label variable ln_w3 "3rd gen wealth, natural log, 1999 and 2006 tax data"
label variable ln_w2 "2nd gen wealth, natural log, 1985 and 1988 tax data"
label variable ln_w1 "1st gen wealth, natural log, 1945 and 1952 tax data"

label variable rank_w4 "4th gen wealth, rank, 2006 tax data"
label variable rank_w3 "3rd gen wealth, rank, 1999 and 2006 tax data"
label variable rank_w2 "2nd gen wealth, rank, 1985 and 1988 tax data"
label variable rank_w1 "1st gen wealth, rank, 1945 and 1952 tax data"

save "data\workdata\estimation_data_4thGen.dta", replace


*---------------------------------------------------------------------------------

* Create 3rd gen regression file

use "data\workdata\merged_3rdGen.dta", clear

rename (lopnrgems* by w wc wy mid_scb y y_par s) =3

* Add 2nd gen
rename lopnrgemsmor3 lopnrgems

joinby lopnrgems using "data\workdata\merged_2ndGen.dta", unmatched(master) update
drop _merge mid_scb

rename (by w wr wc dy y_par s) =_mor_2

joinby lopnrgems using "data\workdata\merged_1stGen.dta", unmatched(master) update
drop _merge mid_scb

rename *_mor *_mormor
rename *_far *_morfar

rename lopnrgems lopnrgemsmor3
rename lopnrgemsfar3 lopnrgems

joinby lopnrgems using "data\workdata\merged_2ndGen.dta", unmatched(master) update
drop _merge mid_scb

rename (by w wr wc dy y_par s) =_far_2

joinby lopnrgems using "data\workdata\merged_1stGen.dta", unmatched(master) update
drop _merge mid_scb

rename *_mor *_farmor
rename *_far *_farfar

rename lopnrgems lopnrgemsfar3


* Add clustering variable
rename mid_scb3 mid_scb

merge m:1 mid_scb using "data\workdata\cluster_id.dta", keep(match master) nogenerate

drop mid_scb
duplicates drop


foreach i in by dy y_par s {
	egen `i'2=rowmean(`i'_mor_2 `i'_far_2)
}

foreach i in w wr wc {
	egen `i'2=rowtotal(`i'_mor_2 `i'_far_2), missing
}

rename y_par2 y1
rename y_par3 y2

foreach i in by dy {
	egen `i'1 = rowmean(`i'_mormor `i'_morfar `i'_farmor `i'_farfar)
}
foreach i in w wk {
	egen `i'1 = rowtotal(`i'_mormor `i'_morfar `i'_farmor `i'_farfar), missing
}

egen s1 = rowmean(s_morfar s_farfar)

* Calculate peak mid-parent lifetime wealth for each set of grandparents
foreach i in mor far {
	gen wd_`i'par = 0.5 * (wd_`i'far + max(0, wd_`i'mor)) if dy_`i'far<dy_`i'mor
	replace wd_`i'par = 0.5 * (max(0, wd_`i'far) + wd_`i'mor) if dy_`i'far>dy_`i'mor
	replace wd_`i'par = 0.5 * (wd_`i'far + wd_`i'mor) if dy_`i'far==dy_`i'mor
}
egen wd1 = rowtotal(wd_morpar wd_farpar), missing


drop by_*2

forvalues i=1/3 {
	* Round birth years
	replace by`i'=round(by`i')
}


* Main wealth variables
forvalues i=1/3{
	transprog, w(w) gen(`i')
}

* Incomes
forvalues i=1/3{
	transprog, w(y) gen(`i')
}
drop ln_y? ihs_y?

* Schooling
forvalues i=1/3{
	transprog, w(s) gen(`i')
}
drop ln_s? ihs_s?


* Censored wealth variables
forvalues i=2/3 {
	transprog, w(wc) gen(`i')
}

* Corrected for real estate
transprog, w(wr) gen(2)

* Capitalised wealth
transprog, w(wk) gen(1)

* Estate wealth
transprog, w(wd) gen(1)

* Wealth when young
transprog, w(wy) gen(3)


label variable by3 "3rd gen birth year"
label variable by2 "2nd gen birth year"
label variable by1 "1st gen birth year"

label variable dy2 "2nd gen year of death"
label variable dy1 "1st gen year of death"

label variable w3 "3rd gen wealth, 1999 and 2006 tax data"
label variable w2 "2nd gen wealth, 1985 and 1988 tax data"
label variable w1 "1st gen wealth, 1945 and 1952 tax data"

label variable wc3 "3rd gen wealth, censored"

label variable wr2 "2nd gen wealth, corrected real estate value"

label variable wk1 "1st gen wealth, capital returns, 1937, 1945 and 1952"

label variable wd1 "1st gen wealth, estate"

label variable ihs_w3 "3rd gen wealth, inverse hyperbolic sine, 1999 and 2006 tax data"
label variable ihs_w2 "2nd gen wealth, inverse hyperbolic sine, 1985 and 1988 tax data"
label variable ihs_w1 "1st gen wealth, inverse hyperbolic sine, 1945 and 1952 tax data"
label variable ihs_wc3 "3rd gen wealth, inverse hyperbolic sine, censored"
label variable ihs_wr2 "2nd gen wealth, inverse hyperbolic sine, corrected real estate value"
label variable ihs_wk1 "1st gen wealth, inverse hyperbolic sine, capital returns, 1937, 1945 and 1952"
label variable ihs_wd1 "1st gen wealth, inverse hyperbolic sine, estate"

label variable ln_w3 "3rd gen wealth, natural log, 1999 and 2006 tax data"
label variable ln_w2 "2nd gen wealth, natural log, 1985 and 1988 tax data"
label variable ln_w1 "1st gen wealth, natural log, 1945 and 1952 tax data"
label variable ln_wc3 "3rd gen wealth, natural log, censored"
label variable ln_wr2 "2nd gen wealth, natural log, corrected real estate value"
label variable ln_wk1 "1st gen wealth, natural log, capital returns, 1937, 1945 and 1952"
label variable ln_wd1 "1st gen wealth, natural log, estate"

label variable rank_w3 "3rd gen wealth, rank, 1999 and 2006 tax data"
label variable rank_w2 "2nd gen wealth, rank, 1985 and 1988 tax data"
label variable rank_w1 "1st gen wealth, rank, 1945 and 1952 tax data"
label variable rank_wc3 "3rd gen wealth, rank, censored"
label variable rank_wr2 "2nd gen wealth, rank, corrected real estate value"
label variable rank_wk1 "1st gen wealth, rank, capital returns, 1937, 1945 and 1952"
label variable rank_wd1 "1st gen wealth, rank, estate"

save "data\workdata\estimation_data_3rdGen.dta", replace


*---------------------------------------------------------------------------------

* Create 2nd gen regression file

use "data\workdata\malmorelationerextended.dta", clear

keep if generation=="Indexgen"
keep lopnrgems
duplicates drop

merge 1:m lopnrgems using "data\workdata\merged_2ndGen.dta", keep(match master) nogenerate

duplicates drop

rename (by w* dy* inh* mid_scb y y_par s) =2

rename y_par2 y1


* Add 1st gen
merge m:1 lopnrgems using "data\workdata\merged_1stGen.dta", keep(match) nogenerate
drop mid_scb


* Add clustering variable
rename mid_scb2 mid_scb

merge m:1 mid_scb using "data\workdata\cluster_id.dta", keep(match master) nogenerate

drop mid_scb
duplicates drop


foreach i in by dy {
	egen `i'1 = rowmean(`i'_mor `i'_far)
}
foreach i in w wk {
	egen `i'1 = rowtotal(`i'_mor `i'_far), missing
}
rename s_far s1

* Calculate peak mid-parent lifetime wealth for parents
gen wd1 = 0.5 * (wd_far + max(0, wd_mor)) if dy_far<dy_mor
replace wd1 = 0.5 * (max(0, wd_far) + wd_mor) if dy_far>dy_mor
replace wd1 = 0.5 * (wd_far + wd_mor) if dy_far==dy_mor



forvalues i=1/2 {
	* Round birth years
	replace by`i'=round(by`i')
}


* Main wealth variables
forvalues i=1/2 {
	transprog, w(w) gen(`i')
}

* 1991 wealth
transprog, w(w_91) gen(2)

* Incomes
forvalues i=1/2{
	transprog, w(y) gen(`i')
}
drop ln_y? ihs_y?

* Schooling
forvalues i=1/2{
	transprog, w(s) gen(`i')
}
drop ln_s? ihs_s?

* Censored wealth
transprog, w(wc) gen(2)

	
* Corrected for real estate
transprog, w(wr) gen(2)

* Capitalised wealth
transprog, w(wk) gen(1)

* Estate wealth
transprog, w(wd) gen(1)

* Rank wealth with capitalized inheritances subtracted
foreach i in wi_cap_neg3 wi_cap_0 wi_cap_3 {
	transprog, w(`i') gen(2)
}

foreach i in wi_ppvr_neg3 wi_ppvr_0 wi_ppvr_3 {
	transprog, w(`i') gen(2)
}

* Rank capitalized inheritances
foreach i in inh_cap_neg3 inh_cap_0 inh_cap_3 {
	transprog, w(`i') gen(2)
}

* Rank inheritances within death year groups
rename (dy2 dy1) (dy_temp dy2)
transprog, w(inh) gen(2) b(d)
rename (dy_temp dy2) (dy2 dy1)






label variable by2 "2nd gen birth year"
label variable by1 "1st gen birth year"

label variable dy2 "2nd gen year of death"
label variable dy1 "1st gen year of death"

label variable w2 "2nd gen wealth, 1985 and 1988 tax data"
label variable w1 "1st gen wealth, 1945 and 1952 tax data"

label variable wr2 "2nd gen wealth, corrected real estate value"

label variable wk1 "1st gen wealth, capital returns, 1937, 1945 and 1952"


label variable wd1 "1st gen wealth, estate"

label variable ihs_w2 "2nd gen wealth, inverse hyperbolic sine, 1985 and 1988 tax data"
label variable ihs_w1 "1st gen wealth, inverse hyperbolic sine, 1945 tax data"
label variable ihs_wr2 "2nd gen wealth, inverse hyperbolic sine, corrected real estate value"
label variable ihs_wk1 "1st gen wealth, inverse hyperbolic sine, capital returns, 1937, 1945 and 1952"
label variable ihs_wd1 "1st gen wealth, inverse hyperbolic sine, estate"

label variable ln_w2 "2nd gen wealth, natural log, 1985 and 1988 tax data"
label variable ln_w1 "1st gen wealth, natural log, 1945 and 1952 tax data"
label variable ln_wr2 "2nd gen wealth, natural log, corrected real estate value"
label variable ln_wk1 "1st gen wealth, natural log, capital returns, 1937 and 1945"
label variable ln_wd1 "1st gen wealth, natural log, estate"

label variable rank_w2 "2nd gen wealth, rank, 1985 and 1988 tax data"
label variable rank_w1 "1st gen wealth, rank, 1945 and 1952 tax data"
label variable rank_wr2 "2nd gen wealth, rank, corrected real estate value"
label variable rank_wk1 "1st gen wealth, rank, capital returns, 1937, 1945 and 1952"
label variable rank_wd1 "1st gen wealth, rank, estate"


save "data\workdata\estimation_data_2ndGen.dta", replace
