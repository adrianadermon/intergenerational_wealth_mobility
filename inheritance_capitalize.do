set more off

* Purge second generation wealth from capitalized inheritances
use "data\workdata\inheritances_2ndGen.dta", clear


* Merge on wealth
merge 1:1 lopnrgems using "data\workdata\tax_wealth_2ndGen.dta", nogenerate

foreach i of numlist -3 0 3 {
	local rate = `i'*0.01
	scalar rate = `rate'
	
	local j = abs(`i')

	if `i' < 0 {
		local neg "neg"
	} 
	else {
		local neg ""
	}

	tempvar cap1 cap2
	
	if `i' < 0 {
		display abs(`i')
	}

	* Capitalize inheritances up to 1991
	gen `cap1' = inh_1st * (exp(rate*(1991 - dy_1st)))

	gen `cap2' = inh_2nd * (exp(rate*(1991 - dy_2nd)))

	* Calculate total capitalized inheritance
	tempvar capsum w_91c
	egen `capsum' = rowtotal(`cap1' `cap2')
	gen inh_cap_`neg'`j' = max(`capsum', 0)

	* Censor wealth for PPVR analysis
	gen `w_91c' = max(w_91, 0)

	* See who are rentiers
	gen rentier_`neg'`j' = (inh_cap_`neg'`j' > `w_91c' & inh_cap_`neg'`j' != .)

	* Calculate PPVR bequest
	gen inh_ppvr_`neg'`j' = inh_cap_`neg'`j'
	replace inh_ppvr_`neg'`j' = `w_91c' if rentier_`neg'`j' == 1
	
	* Generate purged child wealth by subtracting capitalized inheritance
	gen wi_cap_`neg'`j' = w_91 - inh_cap_`neg'`j'
	gen wi_ppvr_`neg'`j' = w_91 - inh_ppvr_`neg'`j'
}

keep lopnrgems inh_cap* wi_cap* wi_ppvr* one


save "data\workdata\inheritances_cap_purged.dta", replace

clear
