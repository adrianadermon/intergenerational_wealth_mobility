
* Imputations for 21 regressions
*-------------------------------

set seed 856023

* Set number of bootstrap replications
local reps = 1000

* IHS
set more off

use "data\workdata\estimation_data_2ndGen.dta", clear

keep ihs_w1 ihs_wk1 w1 w2 wk1 rank_w1 rank_w2 bg_w1 bg_w2 rank_wk1 y1 s1 rank_y1 rank_s1 id1 by1

keep if w1!=. & w2!=. & (y1!=. | s1!=.)

capture program drop impreg21
program impreg21, eclass
	syntax, censor(real)
	* Impute data

	tobit ihs_w1 c.y1##c.y1 c.s1##c.s1 c.by1##c.by1, ll(`censor')
		predict wimp, xb
	
	* Make sure all imputed values are lower than observed values
	sum ihs_w1 if ihs_w1 > 0
		local min = r(min)
	sum wimp
		local max = r(max)
		
	replace wimp = wimp - (`max' - `min') - 1
	
	gen wimp1=ihs_w1
	replace wimp1=wimp if ihs_w1==0
		
	transprog, w(wimp) gen(1) 

	rename rank_wimp1 rank_wp
	
	reg rank_w2 i.bg_w2 i.bg_wimp1
		predict r2, res
	reg rank_wp i.bg_w2 i.bg_wimp1
		predict rp, res
	
	reg r2 rp

	drop wimp wimp1 rank_wp ihs_wimp1 ln_wimp1 bg_wimp1 r2 rp
end

* Censoring limit set to lowest non-zero value rather than to zero
sum ihs_w1 if ihs_w1>0
local c=r(min)

bootstrap _b[rp], reps(`reps') cluster(id1): impreg21, censor(`c')
	eststo imp21


* Imputations for 321 and 31 regressions
*--------------------------------

* IHS, 3rd gen

use "data\workdata\estimation_data_3rdGen.dta", clear

keep ihs_w1 ihs_wk1 w1 w2 w3 wk1 rank_w1 rank_w2 rank_w3 bg_w1 bg_w2 bg_w3 rank_wk1 y1 s1 rank_y1 rank_s1 id1 by1

keep if w1!=. & w2!=. & w3!=. & (y1!=. | s1!=.)

rename rank_w2 rank_wp

capture program drop impreg321
program impreg321, eclass
	syntax, censor(real)
	* Impute data
	tobit ihs_w1 c.y1##c.y1 c.s1##c.s1 c.by1##c.by1, ll(`censor')
		predict wimp, xb
	
	* Make sure all imputed values are lower than observed values
	sum ihs_w1 if ihs_w1 > 0
		local min = r(min)
	sum wimp
		local max = r(max)
		
	replace wimp = wimp - (`max' - `min') - 1
	
	
	gen wimp1=ihs_w1
	replace wimp1=wimp if ihs_w1==0
		
	transprog, w(wimp) gen(1) 

	rename rank_wimp1 rank_wgp

	
	reg rank_w3 rank_wp rank_wgp i.bg_w3 i.bg_w2 i.bg_wimp1, cluster(id1)
	
	reg rank_w3 i.bg_w3 i.bg_w2 i.bg_wimp1
		predict r3, res
	reg rank_wp i.bg_w3 i.bg_w2 i.bg_wimp1
		predict rp, res
	reg rank_wgp i.bg_w3 i.bg_w2 i.bg_wimp1
		predict rgp, res
	
	reg r3 rp rgp

	drop wimp wimp1 rank_wgp ihs_wimp1 ln_wimp1 bg_wimp1 r3 rp rgp
end

capture program drop impreg31
program impreg31, eclass
	syntax, censor(real)
	* Impute data
	tobit ihs_w1 c.y1##c.y1 c.s1##c.s1 c.by1##c.by1, ll(`censor')
		predict wimp, xb
	
	* Make sure all imputed values are lower than observed values
	sum ihs_w1 if ihs_w1 > 0
		local min = r(min)
	sum wimp
		local max = r(max)
		
	replace wimp = wimp - (`max' - `min') - 1
	
	
	gen wimp1=ihs_w1
	replace wimp1=wimp if ihs_w1==0
		
	transprog, w(wimp) gen(1) 

	rename rank_wimp1 rank_wgp

	reg rank_w3 i.bg_w3 i.bg_wimp1
		predict r3, res
	reg rank_wgp i.bg_w3 i.bg_wimp1
		predict rgp, res
	
	reg r3 rgp
	
	drop wimp wimp1 rank_wgp ihs_wimp1 ln_wimp1 bg_wimp1 r3 rgp
end

* Censoring limit set to lowest non-zero value rather than to zero
sum ihs_w1 if ihs_w1>0
local c=r(min)


bootstrap _b[rp] _b[rgp], reps(`reps') cluster(id1): impreg321, censor(`c')
	eststo imp321

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

bootstrap _b[rgp], reps(`reps') cluster(id1): impreg31, censor(`c')
	ren_b
	eststo imp31

* Regress 3rd on 2nd gen wealth using imputation sample
reg rank_w3 rank_wp i.bg_w3 i.bg_w2, cluster(id1), if (s1!=. & y1 != .) | ihs_w1 > 0
	eststo w32


* Imputations for 32 regressions, with artificially censored 2nd gen
*-------------------------------------------------------------------


set more off

* Calculate share of w1 obs that are zero
use "data\workdata\estimation_data_2ndGen.dta", clear

count if w1!=.
	local N = r(N)	
count if w1==0
	local n = r(N)
	
local share =  `n'/`N'

* Censor w2 to look like w1
use "data\workdata\estimation_data_3rdGen.dta", clear

sort w2

count if w2!=.

local zero = round(r(N)*`share')

gen wcens2 = w2
replace wcens2 = 0 in 1/`zero'

transprog, w(wcens) gen(2)

* IHS
keep wcens2 ihs_w2 w1 w2 w3 rank_w2 rank_w3 rank_wcens2 bg_wcens2 ihs_wcens2 bg_w2 bg_w3 y2 s2 rank_y2 rank_s2 id1 by2

keep if w3!=. & w2!=. & w1!=. & (y2!=. | s2!=.)


capture program drop impreg32
program impreg32, eclass
	syntax, censor(real)

	* Impute data
	tobit ihs_wcens2 c.y2##c.y2 c.s2##c.s2 c.by2##c.by2, ll(`censor')
		predict wimp, xb
	
	* Make sure all imputed values are lower than observed values
	sum ihs_wcens2 if ihs_wcens2 > 0
		local min = r(min)
	sum wimp
		local max = r(max)
		
	replace wimp = wimp - (`max' - `min') - 1
	
	
	gen wimp2=ihs_wcens2
	replace wimp2=wimp if ihs_wcens2==0
		
	transprog, w(wimp) gen(2) 

	reg rank_w3 i.bg_w3 i.bg_wimp2
		predict r3, res
	reg rank_wimp2 i.bg_w3 i.bg_wimp2
		predict rp, res
	
	reg r3 rp
	
	drop wimp wimp2 rank_wimp2 ihs_wimp2 ln_wimp2 bg_wimp2 r3 rp
end

reg rank_w3 rank_wcens2 i.bg_w3 i.bg_wcens2
	eststo cens32

* Censoring limit set to lowest non-zero value rather than to zero
sum ihs_w2 if ihs_w2>0
local c=r(min)
	
bootstrap _b[rp], reps(`reps') cluster(id1): impreg32, censor(`c')
	eststo imp32





* Table 4, panel B
*-----------------
esttab imp21 w32 imp31 imp321, keep(_bs*) b(3) se(3) ///
	rename(rank_wp _bs_1) varlabel(_bs_1 "Parents" _bs_2 "Grandparents") ///
 	nomtitles ///
	star(* 0.10 ** 0.05 *** 0.01) title("Imputed regressions")

* Online appendix table 7
*------------------------
esttab cens32 imp32, b(3) se(3) keep(rank_w2) ///
	rename(_bs_1 rank_w2 rank_wcens2 rank_w2) ///
	varlabels(rank_w2 "Parents") ///
	mtitles("Censored" "Imputed") ///
	star(* 0.10 ** 0.05 *** 0.01)

