use "data\workdata\estimation_data_2ndGen.dta", clear

drop rank_w1
rename rank_wd1 rank_w1

* Keep only estimation sample
qui: reg rank_w2 rank_w1 i.bg_w2 i.bg_w1
	keep if e(sample) == 1
forvalues i = 1/2 {
	* Regress out birth cohorts for dependent variable
	qui: reg rank_w`i' i.bg_w2 i.bg_w1
		predict r_w`i', residual

		* Rescale residuals
		sum rank_w`i'
			local maxo=r(max)
			local mino=r(min)
		sum r_w`i'
			local maxr=r(max)
			local minr=r(min)
			
		replace r_w`i' = (r_w`i' - `minr') / ((`maxr' - `minr')/(`maxo' - `mino')) + `mino'
}
		

keep r_w2 r_w1

rename r_w2 outcome

gen i=_n

reshape long r_w, i(i) j(gen)

recode gen (1=21)

tempfile g2
save `g2'

use "data\workdata\estimation_data_3rdGen.dta", clear

drop rank_w1
rename rank_wd1 rank_w1

* Keep only estimation sample
qui: reg rank_w3 rank_w2 rank_w1 i.bg_w3 i.bg_w2 i.bg_w1
	keep if e(sample) == 1
forvalues i = 1/3 {
	* Regress out birth cohorts for dependent variable
	qui: reg rank_w`i' i.bg_w3 i.bg_w2 i.bg_w1
		predict r_w`i', residual

		* Rescale residuals
		sum rank_w`i'
			local maxo=r(max)
			local mino=r(min)
		sum r_w`i'
			local maxr=r(max)
			local minr=r(min)
			
		replace r_w`i' = (r_w`i' - `minr') / ((`maxr' - `minr')/(`maxo' - `mino')) + `mino'
}

keep r_w3 r_w2 r_w1

rename r_w3 outcome

gen i=_n

reshape long r_w, i(i) j(gen)

recode gen (2=32) (1=31)

tempfile g3
save `g3'


use "data\workdata\estimation_data_4thGen.dta", clear

drop rank_w1
rename rank_wd1 rank_w1

* Keep only estimation sample
qui: reg rank_w4 rank_w3 rank_w2 rank_w1 i.bg_w4 i.bg_w3 i.bg_w2 i.bg_w1
	keep if e(sample) == 1
forvalues i = 1/4 {
	* Regress out birth cohorts for dependent variable
	qui: reg rank_w`i' i.bg_w3 i.bg_w2 i.bg_w1
		predict r_w`i', residual

		* Rescale residuals
		sum rank_w`i'
			local maxo=r(max)
			local mino=r(min)
		sum r_w`i'
			local maxr=r(max)
			local minr=r(min)
			
		replace r_w`i' = (r_w`i' - `minr') / ((`maxr' - `minr')/(`maxo' - `mino')) + `mino'
}


keep r_w4 r_w3 r_w2 r_w1

rename r_w4 outcome

gen i=_n
reshape long r_w, i(i) j(gen)
drop i

recode gen (3=43) (2=42) (1=41)

tempfile g4
save `g4'

use `g2', clear
append using `g3'
append using `g4'

recode gen (21=1) (32=2) (31=3) (43=4) (42=5) (41=6)

drop if gen==2 | gen==4 | gen== 5

label define intgraph 1 "a) 2nd on parents" 3 "b) 3rd on grandparents" 6 "c) 4th on great grandparents"
label values gen intgraph

* Save data for plotting in external program
saveold "data\workdata\plot_data_estate.dta", version(13) replace
