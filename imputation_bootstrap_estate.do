
* Imputations for 21 regressions
*-------------------------------

set seed 856023

* Set number of bootstrap replications
local reps = 1000

* IHS
set more off

use "data\workdata\estimation_data_2ndGen.dta", clear

keep w1 w2 wk1 wd1 rank_w1 rank_w2 bg_w1 bg_w2 rank_wk1 y1 s1 rank_y1 rank_s1 id1 by1

keep if w1!=. & w2!=. & wd1!=.

capture program drop imprege21
program imprege21, eclass	
	* Make sure all imputed values are lower than observed values
	sum w1 if w1 > 0
		local min = r(min)
	sum wd1 if w1==0
		local max = r(max)
		
	gen wd1rescale = wd1 - (`max' - `min') - 1

	gen wimp1 = w1 if w1>0
	replace wimp1 = wd1rescale if wimp1==.

	transprog, w(wimp) gen(1) 

	rename rank_wimp1 rank_wp
	
	reg rank_w2 i.bg_w2 i.bg_wimp1
		predict r2, res
	reg rank_wp i.bg_w2 i.bg_wimp1
		predict rp, res
	
	reg r2 rp

	drop wd1rescale wimp wimp1 rank_wp ihs_wimp1 ln_wimp1 bg_wimp1 r2 rp
end

bootstrap _b[rp], reps(`reps') cluster(id1): imprege21
	eststo impe21


* Imputations for 321 and 31 regressions
*--------------------------------

* IHS, 3rd gen

use "data\workdata\estimation_data_3rdGen.dta", clear

keep w1 w2 w3 wd1 wk1 rank_w1 rank_w2 rank_w3 bg_w1 bg_w2 bg_w3 rank_wk1 y1 s1 rank_y1 rank_s1 id1 by1

keep if w1!=. & w2!=. & w3!=. & wd1!=.

rename rank_w2 rank_wp

capture program drop imprege321
program imprege321, eclass

	* Make sure all imputed values are lower than observed values
	sum w1 if w1 > 0
		local min = r(min)
	sum wd1 if w1==0
		local max = r(max)
		
	gen wd1rescale = wd1 - (`max' - `min') - 1

	gen wimp1 = w1 if w1>0
	replace wimp1 = wd1rescale if wimp1==.

	transprog, w(wimp) gen(1) 

	rename rank_wimp1 rank_wgp
	
	reg rank_w3 i.bg_w3 i.bg_w2 i.bg_wimp1
		predict r3, res
	reg rank_wp i.bg_w3 i.bg_w2 i.bg_wimp1
		predict rp, res
	reg rank_wgp i.bg_w3 i.bg_w2 i.bg_wimp1
		predict rgp, res
	
	reg r3 rp rgp

	drop wd1rescale wimp wimp1 rank_wgp ihs_wimp1 ln_wimp1 bg_wimp1 r3 rp rgp
end

capture program drop imprege31
program imprege31, eclass

	* Make sure all imputed values are lower than observed values
	sum w1 if w1 > 0
		local min = r(min)
	sum wd1 if w1==0
		local max = r(max)
		
	gen wd1rescale = wd1 - (`max' - `min') - 1

	gen wimp1 = w1 if w1>0
	replace wimp1 = wd1rescale if wimp1==.

	transprog, w(wimp) gen(1) 
	rename rank_wimp1 rank_wgp

	reg rank_w3 i.bg_w3 i.bg_wimp1
		predict r3, res
	reg rank_wgp i.bg_w3 i.bg_wimp1
		predict rgp, res
	
	reg r3 rgp
	
	drop wd1rescale wimp wimp1 rank_wgp ihs_wimp1 ln_wimp1 bg_wimp1 r3 rgp
end


bootstrap _b[rp] _b[rgp], reps(`reps') cluster(id1): imprege321
	eststo impe321

* Need to rename estimates to get correct table
capture program drop ren_b
program ren_b, eclass
	matrix b2 = e(b)
	matrix se2 = e(se)
    matrix colnames b2 = "_bs_2"
    matrix colnames se2 = "_bs_2"
    ereturn repost b = b2, rename
    ereturn matrix se = se2
end

bootstrap _b[rgp], reps(`reps') cluster(id1): imprege31
	ren_b
	eststo impe31


* Regress 3rd gen wealth on 2nd gen wealth using imputation sample
reg rank_w3 rank_wp i.bg_w3 i.bg_w2, cluster(id1)
	eststo w32, title("3rd gen")


* Online Appendix Table 3, panel D
 esttab impe21 w32 impe31 impe321, keep(_bs*) b(3) se(3) ///
 	rename(rank_wp _bs_2) varlabel(_bs_1 "Parents" _bs_2 "Grandparents") ///
 	nomtitles stats(r2 N, label("R2" "N") fmt(3 0)) ///
	star(* 0.10 ** 0.05 *** 0.01) title("Imputed regressions, estate")
