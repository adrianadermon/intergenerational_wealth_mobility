set more off

use "data\workdata\estimation_data_2ndGen.dta", clear

qui: reg rank_w2 rank_w1 i.bg_w2 i.bg_w1
	gen sample = e(sample)

estpost sum rank_w1 rank_wk1 rank_wd1 rank_w2 rank_y1 rank_y2 rank_s1 rank_s2 if sample==1
	eststo sum2r

foreach i in w1 wk1 wd1 w2 inh2 {
	replace `i' = `i' / 1000
}
	
* Make sure inheritance observations match sample in inheritance regressions
qui: reg rank_w2 rank_inh2 rank_w1 rank_wi_cap_02 i.dg_inh2
replace inh2 = . if e(sample) == 0

	
estpost sum w1 wk1 wd1 w2 inh2 if sample==1, d
	eststo sum2w

estpost sum y1 y2 s1 s2 by1 by2 dy1 if sample==1
	eststo sum2c

estpost sum y1 y2 s1 s2 by1 by2 dy1
 eststo sum2c_full



* Check how many have at least one parent in the 1st generation (section 1.2)
gen far = (by_far !=. | dy_far !=.)
gen mor = (by_mor !=. | dy_mor !=.)

tab far mor



use "data\workdata\estimation_data_3rdGen.dta", clear

qui: reg rank_w3 rank_w2 rank_w1 i.bg_w3 i.bg_w2 i.bg_w1
	gen sample = e(sample)

estpost sum rank_w1 rank_wk1 rank_wd1 rank_w2 rank_w3 rank_y1 rank_y2 rank_y3 rank_s1 rank_s2 rank_s3 if sample==1
	eststo sum3r
	
foreach i in w1 wk1 wd1 w2 w3 {
	replace `i' = `i' / 1000
}
	
estpost sum w1 wk1 wd1 w2 w3 if sample==1, d
	eststo sum3w

estpost sum y1 y2 y3 s1 s2 s3 by1 by2 by3 dy1 if sample==1
	eststo sum3c

estpost sum y1 y2 y3 s1 s2 s3 by1 by2 by3 dy1
	eststo sum3c_full

	
use "data\workdata\estimation_data_4thGen.dta", clear

qui: reg rank_w4 rank_w3 rank_w2 rank_w1 i.bg_w4 i.bg_w3 i.bg_w2 i.bg_w1
	gen sample = e(sample)

estpost sum rank_w1 rank_wk1 rank_wd1 rank_w2 rank_w3 rank_w4 rank_y1 rank_y2 rank_y3 rank_s1 rank_s2 rank_s3 rank_s4 if sample==1
	eststo sum4r
	
foreach i in w1 wk1 wd1 w2 w3 w4 {
	replace `i' = `i' / 1000
}

estpost sum w1 wk1 wd1 w2 w3 w4 if sample==1, d
	eststo sum4w
	
estpost sum y1 y2 y3 s1 s2 s3 s4 by1 by2 by3 by4 dy1 if sample==1
	eststo sum4c

estpost sum y1 y2 y3 s1 s2 s3 s4 by1 by2 by3 by4 dy1
	eststo sum4c_full

* Table 1, panel A
*-----------------
esttab sum2w, noobs ///
	cells("mean(fmt(1)) p10(fmt(1)) p25(fmt(1)) p50(fmt(1)) p75(fmt(1)) p90(fmt(1)) count(fmt(0))" "sd(par(( )))") ///
	collabels("Mean (s.d.)" "p10" "p25" "p50" "p75" "p90" "Obs.") ///
	varlabels(w1 "1st gen" wk1 "1st gen, capitalised" wd1 "1st gen, estate" w2 "2nd gen" inh2 "Inheritance") ///
	nomtitles nonumbers title("Wealth distribution, 2nd gen sample")

* Table 1, panel B
*-----------------
esttab sum3w, noobs ///
	cells("mean(fmt(1)) p10(fmt(1)) p25(fmt(1)) p50(fmt(1)) p75(fmt(1)) p90(fmt(1)) count(fmt(0))" "sd(par(( )))") ///
	collabels("Mean (s.d.)" "p10" "p25" "p50" "p75" "p90" "Obs.") ///
	varlabels(w1 "1st gen" wk1 "1st gen, capitalised" wd1 "1st gen, estate" w2 "2nd gen" w3 "3rd gen") ///
	nomtitles nonumbers title("Wealth distribution, 3rd gen sample")
	
* Table 1, panel C
*-----------------
esttab sum4w, noobs ///
	cells("mean(fmt(1)) p10(fmt(1)) p25(fmt(1)) p50(fmt(1)) p75(fmt(1)) p90(fmt(1)) count(fmt(0))" "sd(par(( )))") ///
	collabels("Mean (s.d.)" "p10" "p25" "p50" "p75" "p90" "Obs.") ///
	varlabels(w1 "1st gen" wk1 "1st gen, capitalised" wd1 "1st gen, estate" w2 "2nd gen" w3 "3rd gen" w4 "4th gen") ///
	nomtitles nonumbers title("Wealth distribution, 4th gen sample")
	

* Table 2
*--------
esttab sum2c sum3c sum4c, noobs ///
	cells("mean(fmt(3)) count(fmt(0))" "sd(par(( )))") ///
	varlabels(y1 "1st" y2 "2nd" y3 "3rd" s1 "1st" s2 "2nd" s3 "3rd" s4 "4th" by1 "1st" by2 "2nd" by3 "3rd" by4 "4th" dy1 "1st") ///
	collabels("Mean (s.d.)" "Obs." "Mean (s.d.)" "Obs." "Mean (s.d.)" "Obs.") ///
	mtitles("2nd gen sample" "3rd gen sample" "4th gen sample") ///	
	order(y1 y2 y3 s1 s2 s3 s4 by1 by2 by3 by4 dy1) ///
	refcat(y1 "Earnings" s1 "Schooling" by1 "Year of birth" dy1 "Year of death", nolabel) ///
	title("Summary statistics: covariates")

* Online Appendix Table 1
*------------------------
esttab sum2c_full sum3c_full sum4c_full, noobs ///
	cells("mean(fmt(3)) count(fmt(0))" "sd(par(( )))") ///
	varlabels(y1 "1st" y2 "2nd" y3 "3rd" s1 "1st" s2 "2nd" s3 "3rd" s4 "4th" by1 "1st" by2 "2nd" by3 "3rd" by4 "4th" dy1 "1st") ///
	collabels("Mean (s.d.)" "Obs." "Mean (s.d.)" "Obs." "Mean (s.d.)" "Obs.") ///
	mtitles("2nd gen sample" "3rd gen sample" "4th gen sample") ///	
	order(y1 y2 y3 s1 s2 s3 s4 by1 by2 by3 by4 dy1) ///
	refcat(y1 "Earnings" s1 "Schooling" by1 "Year of birth" dy1 "Year of death", nolabel) ///
	title("Summary statistics, full sample")

	
	
* Online Appendix Table 2
*------------------------
esttab sum2r sum3r sum4r, noobs ///
	cells("mean(fmt(3)) min count(fmt(0))" "sd(par(( ))) max") ///
	varlabels(rank_w1 "1st" rank_wk1 "1st, capitalised" rank_wd1 "1st, estate" rank_w2 "2nd" rank_w3 "3rd" rank_w4 "4th" rank_y1 "1st" rank_y2 "2nd" rank_y3 "3rd" rank_s1 "1st" rank_s2 "2nd" rank_s3 "3rd" rank_s4 "4th") ///
	collabels("Mean (s.d.)" "Min Max" "Obs." "Mean (s.d.)" "Min Max" "Obs." "Mean (s.d.)" "Min Max" "Obs.") ///
	mtitles("2nd gen sample" "3rd gen sample" "4th gen sample") ///
	order(rank_w1 rank_wk1 rank_wd1 rank_w2 rank_w3 rank_w4 rank_y1 rank_y2 rank_y3 rank_s1 rank_s2 rank_s3 rank_s4) ///
	refcat(rank_w1 "Wealth" rank_y1 "Earnings" rank_s1 "Schooling", nolabel) ///
	title("Summary statistics: ranked variables")

