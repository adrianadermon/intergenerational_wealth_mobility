set more off

use "data\workdata\estimation_data_2ndGen.dta", clear

eststo drop *

gen rank_wcp = rank_w1
rename (rank_w1 rank_wk1 rank_wd1 ihs_w1 ln_w1) (rank_wp rank_wkp rank_wdp ihs_wp ln_wp)

* Create top dummies
foreach i in w2 wp {
	* Top decile
	gen d_`i'=(rank_`i'>0.9 & rank_`i'!=.)
	replace d_`i'=. if rank_`i'==.

	* Top vintile
	gen v_`i'=(rank_`i'>0.95 & rank_`i'!=.)
	replace v_`i'=. if rank_`i'==.

	* Top fifteen percent
	gen f_`i'=(rank_`i'>0.85 & rank_`i'!=.)
	replace f_`i'=. if rank_`i'==.
}

* For table 3
*------------

* Regress 2nd gen wealth on 1st gen wealth
reg rank_w2 rank_wp i.bg_w2 i.bg_w1, cluster(id1)
	eststo w21, title("2nd gen")

* Top dummy regressions
foreach i in d v f {
	reg `i'_w2 `i'_wp i.bg_w2 i.bg_w1, cluster(id1)
		eststo `i'21, title("Wealth")
}

* For Table 4
*------------

* Regress 2nd gen wealth on 1st gen estate wealth
reg rank_w2 rank_wdp i.bg_w2 i.bg_wd1, cluster(id1), if rank_wp!=.
	eststo wd21, title("2nd gen")


* For Online Appendix Table 3
*----------------------------

* Regress 2nd gen wealth on 1st gen wealth
reg rank_wr2 rank_wp i.bg_wr2 i.bg_w1, cluster(id1)
	eststo wr21, title("2nd gen")

* Regress 2nd gen wealth on 1st gen wealth
reg rank_wc2 rank_wcp i.bg_wc2 i.bg_w1, cluster(id1)
	eststo wc21, title("2nd gen")

* Regress 2nd gen wealth on 1st gen capitalized wealth
reg rank_w2 rank_wkp i.bg_w2 i.bg_wk1, cluster(id1)
	eststo wk21, title("2nd gen")

preserve

* For Online Appendix Table 5
*----------------------------

merge 1:1 lopnrgems using "data\workdata\gen2ind_321sample.dta", keep(match) nogenerate

* Regress 2nd gen wealth on 1st gen wealth
reg rank_w2 rank_wp i.bg_w2 i.bg_w1, cluster(id1)
	eststo w21p, title("2nd gen")

restore

* For Online Appendix Table 6
*----------------------------

* Regress 2nd gen wealth on 1st gen wealth
reg ihs_w2 ihs_wp c.by2##c.by2 c.by1##c.by1, cluster(id1)
	eststo ihs21, title("2nd gen")

foreach i in 10 1000 {
	gen w1_`i' = w1
	replace w1_`i' = w1 + `i' if w1 == 0
	gen ihs_wp_`i' = ln(w1_`i' + sqrt(w1_`i'^2 + 1))
}

* Regress 2nd gen wealth on 1st gen wealth
foreach i in 10 1000 {
	reg ihs_w2 ihs_wp_`i' c.by2##c.by2 c.by1##c.by1, cluster(id1)
		eststo ihs21_`i', title("2nd gen")
}


* Regress 2nd gen wealth on 1st gen wealth
reg ln_w2 ln_wp c.by2##c.by2 c.by1##c.by1, cluster(id1)
	eststo ln21, title("2nd gen")


* Regress 2nd gen wealth on 1st gen wealth
reg rank_w2 rank_wp i.bg_w2 i.bg_w1 if w1>0 & w2>0, cluster(id1)
	eststo r21, title("2nd gen")

* For table 9
*------------

reg rank_w2 rank_wp rank_y2 rank_y1 rank_s2 rank_s1 i.bg_w2 i.bg_w1 i.bg_y2 i.bg_y1 i.bg_s2 i.bg_s1, cluster(id1)
	keep if e(sample)
	eststo wys21m, title("Wealth")
reg rank_w2 rank_wp i.bg_w2 i.bg_w1, cluster(id1)
	eststo w21m, title("Wealth")
reg rank_y2 rank_y1 i.bg_y2 i.bg_y1, cluster(id1)
	eststo y21m, title("Earnings")
reg rank_s2 rank_s1 i.bg_s2 i.bg_s1, cluster(id1)
	eststo s21m, title("Schooling")
reg rank_w2 rank_wp rank_y2 rank_y1 i.bg_w2 i.bg_w1 i.bg_y2 i.bg_y1, cluster(id1)
	eststo wy21m, title("Wealth")
reg rank_w2 rank_wp rank_s2 rank_s1 i.bg_w2 i.bg_w1 i.bg_s2 i.bg_s1, cluster(id1)
	eststo ws21m, title("Wealth")


* For Online Appendix Table 14
*-----------------------------

* Mediating regressions with child's wealth adjusted for inheritance
qui: reg rank_w2 rank_inh2 rank_wp rank_wi_cap_02 i.dg_inh2
	keep if e(sample)

reg rank_wi_cap_02 rank_wp i.bg_wi_cap_02 i.bg_w1, cluster(id1)
	eststo w0, title("2nd gen wealth")
reg rank_wi_cap_02 rank_wp rank_y2 rank_y1 i.bg_wi_cap_02 i.bg_w1 i.bg_y2 i.bg_y1, cluster(id1)
	eststo wy0, title("2nd gen wealth")
reg rank_wi_cap_02 rank_wp rank_s2 rank_s1 i.bg_wi_cap_02 i.bg_w1 i.bg_s2 i.bg_s1, cluster(id1)
	eststo ws0, title("2nd gen wealth")
reg rank_wi_cap_02 rank_wp rank_y2 rank_y1 rank_s2 rank_s1 i.bg_wi_cap_02 i.bg_w1 i.bg_y2 i.bg_y1 i.bg_s2 i.bg_s1, cluster(id1)
	eststo wys0, title("2nd gen wealth")



use "data\workdata\estimation_data_3rdGen.dta", clear

rename(rank_w2 rank_w1 rank_wk1 rank_wd1 rank_wr2 rank_wc2 ihs_w2 ihs_w1 ln_w2 ln_w1) (rank_wp rank_wgp rank_wkgp rank_wdgp rank_wrp rank_wcp ihs_wp ihs_wgp ln_wp ln_wgp)

* Create top dummies
foreach i in w3 wp wgp {
	* Top decile
	gen d_`i'=(rank_`i'>0.9 & rank_`i'!=.)
	replace d_`i'=. if rank_`i'==.

	* Top vintile
	gen v_`i'=(rank_`i'>0.95 & rank_`i'!=.)
	replace v_`i'=. if rank_`i'==.

	* Top fifteen percent
	gen f_`i'=(rank_`i'>0.85 & rank_`i'!=.)
	replace f_`i'=. if rank_`i'==.
}

* For table 3
*------------

qui: reg rank_w3 rank_wp rank_wgp i.bg_w3 i.bg_w2 i.bg_w1
	keep if e(sample)

* Regress 3rd gen wealth on 2nd gen wealth
reg rank_w3 rank_wp i.bg_w3 i.bg_w2, cluster(id1)
	eststo w32, title("3rd gen")

* Regress 3rd gen wealth on 2nd gen wealth, capitalized sample
reg rank_w3 rank_wp i.bg_w3 i.bg_w2, cluster(id1), if rank_wkgp != .
	eststo wk32, title("3rd gen")
	
* Regress 3rd gen wealth on 2nd gen wealth, estate sample
reg rank_w3 rank_wp i.bg_w3 i.bg_w2, cluster(id1), if rank_wdgp != .
	eststo wd32, title("3rd gen")

* Regress 3rd gen wealth on 1st gen wealth
reg rank_w3 rank_wgp i.bg_w3 i.bg_w1, cluster(id1)
	eststo w31, title("3rd gen")
	
* Regress 3rd gen wealth on 1st gen capitalized wealth
reg rank_w3 rank_wkgp i.bg_w3 i.bg_wk1, cluster(id1)
	eststo wk31, title("3rd gen")

* Regress 3rd gen wealth on 1st gen estate wealth
reg rank_w3 rank_wdgp i.bg_w3 i.bg_wd1, cluster(id1)
	eststo wd31, title("3rd gen")
	
* Regress 3rd gen wealth on 2nd and 1st gen wealth
reg rank_w3 rank_wp rank_wgp i.bg_w3 i.bg_w2 i.bg_w1, cluster(id1)
	eststo w321, title("3rd gen")
	
* Regress 3rd gen wealth on 2nd gen wealth and 1st gen capitalized wealth
reg rank_w3 rank_wp rank_wkgp i.bg_w3 i.bg_w2 i.bg_wk1, cluster(id1)
	eststo wk321, title("3rd gen")

* Regress 3rd gen wealth on 2nd gen wealth and 1st gen estate wealth
reg rank_w3 rank_wp rank_wdgp i.bg_w3 i.bg_w2 i.bg_wd1, cluster(id1)
	eststo wd321, title("3rd gen")

* Top dummy regressions
foreach i in d v f {
reg `i'_w3 `i'_wgp i.bg_w3 i.bg_w1, cluster(id1)
	eststo `i'31, title("Wealth")

reg `i'_w3 `i'_wp i.bg_w3 i.bg_w2, cluster(id1)
	eststo `i'32, title("Wealth")
	
reg `i'_w3 `i'_wp `i'_wgp i.bg_w3 i.bg_w2 i.bg_w1, cluster(id1)
	eststo `i'321, title("Wealth")
}

* For Online Appendix Table 3, panel A
*-------------------------------------

* Regress 3rd gen wealth on 2nd gen wealth
reg rank_w3 rank_wrp i.bg_w3 i.bg_wr2, cluster(id1)
	eststo wr32, title("3rd gen")
	
* Regress 3rd gen wealth on 1st gen wealth
reg rank_w3 rank_wgp i.bg_w3 i.bg_w1, cluster(id1)
	eststo wr31, title("3rd gen")
		
* Regress 3rd gen wealth on 2nd and 1st gen wealth
reg rank_w3 rank_wrp rank_wgp i.bg_w3 i.bg_wr2 i.bg_w1, cluster(id1)
	eststo wr321, title("3rd gen")

* For Online Appendix Table 3, panel B
*-------------------------------------

* Regress 3rd gen wealth on 2nd gen wealth
reg rank_wc3 rank_wcp i.bg_wc3 i.bg_wc2, cluster(id1)
	eststo wc32, title("3rd gen")
	
* Regress 3rd gen wealth on 1st gen wealth
reg rank_wc3 rank_wgp i.bg_wc3 i.bg_w1, cluster(id1)
	eststo wc31, title("3rd gen")
		
* Regress 3rd gen wealth on 2nd and 1st gen wealth
reg rank_wc3 rank_wcp rank_wgp i.bg_wc3 i.bg_wc2 i.bg_w1, cluster(id1)
	eststo wc321, title("3rd gen")


preserve

* For Online Appendix Table 5
*----------------------------

merge 1:1 lopnrgems3 using "data\workdata\gen3ind_321sample.dta", keep(match) nogenerate

gen chw=1/childcount

* Regress 3rd gen wealth on 2nd gen wealth
reg rank_w3 rank_wp i.bg_w3 i.bg_w2 [pw=chw], cluster(id1)
	eststo w32p, title("3rd gen")

* Regress 3rd gen wealth on 1st gen wealth
reg rank_w3 rank_wgp i.bg_w3 i.bg_w1 [pw=chw], cluster(id1)
	eststo w31p, title("3rd gen")

* Regress 3rd gen wealth on 2nd and 1st gen wealth
reg rank_w3 rank_wp rank_wgp i.bg_w3 i.bg_w2 i.bg_w1 [pw=chw], cluster(id1)
	eststo w321p, title("3rd gen")

restore


* For Online Appendix Table 8
*------------------------

* Regress 3rd gen wealth on 2nd gen wealth
reg rank_wy3 rank_wp i.bg_w3 i.bg_w2, cluster(id1)
	eststo w32y, title("3rd gen")

* Regress 3rd gen wealth on 1st gen wealth
reg rank_wy3 rank_wgp i.bg_w3 i.bg_w1, cluster(id1)
	eststo w31y, title("3rd gen")

* Regress 3rd gen wealth on 2nd and 1st gen wealth
reg rank_wy3 rank_wp rank_wgp i.bg_w3 i.bg_w2 i.bg_w1, cluster(id1)
	eststo w321y, title("3rd gen")


* For Online Appendix Table 6
*----------------------------

* Regress 3rd gen wealth on 2nd gen wealth
reg ihs_w3 ihs_wp c.by3##c.by3 c.by2##c.by2, cluster(id1)
	eststo ihs32, title("3rd gen")

* Regress 3rd gen wealth on 1st gen wealth
reg ihs_w3 ihs_wgp c.by3##c.by3 c.by1##c.by1, cluster(id1)
	eststo ihs31, title("3rd gen")
	
* Regress 3rd gen wealth on 2nd and 1st gen wealth
reg ihs_w3 ihs_wp ihs_wgp c.by3##c.by3 c.by2##c.by2 c.by1##c.by1, cluster(id1)
	eststo ihs321, title("3rd gen")


foreach i in 10 1000 {
	gen w2_`i' = w2
	replace w2_`i' = w2 + `i' if w2 == 0
	gen ihs_wp_`i' = ln(w2_`i' + sqrt(w2_`i'^2 + 1))

	gen w1_`i' = w1
	replace w1_`i' = w1 + `i' if w1 == 0
	gen ihs_wgp_`i' = ln(w1_`i' + sqrt(w1_`i'^2 + 1))
}

* Regress 3rd gen wealth on 2nd gen wealth
foreach i in 10 1000 {
	reg ihs_w3 ihs_wp_`i' c.by3##c.by3 c.by2##c.by2, cluster(id1)
		eststo ihs32_`i', title("3rd gen")

	* Regress 3rd gen wealth on 1st gen wealth
	reg ihs_w3 ihs_wgp_`i' c.by3##c.by3 c.by1##c.by1, cluster(id1)
		eststo ihs31_`i', title("3rd gen")

	* Regress 3rd gen wealth on 2nd and 1st gen wealth
	reg ihs_w3 ihs_wp_`i' ihs_wgp_`i' c.by3##c.by3 c.by2##c.by2 c.by1##c.by1, cluster(id1)
		eststo ihs321_`i', title("3rd gen")
}

qui: reg ln_w3 ln_wp ln_wgp by3 by2 by1
	gen sample=e(sample)

* Regress 3rd gen wealth on 2nd gen wealth
reg ln_w3 ln_wp c.by3##c.by3 c.by2##c.by2, cluster(id1), if sample==1
	eststo ln32, title("3rd gen")

* Regress 3rd gen wealth on 1st gen wealth
reg ln_w3 ln_wgp c.by3##c.by3 c.by1##c.by1, cluster(id1), if sample==1
	eststo ln31, title("3rd gen")

* Regress 3rd gen wealth on 2nd and 1st gen wealth
reg ln_w3 ln_wp ln_wgp c.by3##c.by3 c.by2##c.by2 c.by1##c.by1, cluster(id1), if sample==1
	eststo ln321, title("3rd gen")


* Regress 3rd gen wealth on 2nd gen wealth
reg rank_w3 rank_wp i.bg_w3 i.bg_w2, cluster(id1), if sample==1
	eststo r32, title("3rd gen")

* Regress 3rd gen wealth on 1st gen wealth
reg rank_w3 rank_wgp i.bg_w3 i.bg_w1, cluster(id1), if sample==1 
	eststo r31, title("3rd gen")
	
* Regress 3rd gen wealth on 2nd and 1st gen wealth
reg rank_w3 rank_wp rank_wgp i.bg_w3 i.bg_w2 i.bg_w1, cluster(id1), if sample==1
	eststo r321, title("3rd gen")


* For Online Appendix Table 15
*-----------------------------

reg rank_w3 rank_wp rank_wgp rank_y3 rank_y2 rank_y1 rank_s3 rank_s2 rank_s1 i.bg_w3 i.bg_w2 i.bg_w1 i.bg_y3 i.bg_y2 i.bg_y1 i.bg_s3 i.bg_s2 i.bg_s1, cluster(id1)
	gen sample321=e(sample)

	eststo wys321m, title("Wealth")
reg rank_w3 rank_wp rank_wgp i.bg_w3 i.bg_w2 i.bg_w1 if sample321==1, cluster(id1)
	eststo w321m, title("Wealth")
reg rank_y3 rank_y2 rank_y1 i.bg_y3 i.bg_y2 i.bg_y1 if sample321==1, cluster(id1)
	eststo y321m, title("Earnings")
reg rank_s3 rank_s2 rank_s1 i.bg_s3 i.bg_s2 i.bg_s1 if sample321==1, cluster(id1)
	eststo s321m, title("Schooling")
reg rank_w3 rank_wp rank_wgp rank_y3 rank_y2 rank_y1 i.bg_w3 i.bg_w2 i.bg_w1 i.bg_y3 i.bg_y2 i.bg_y1 if sample321==1, cluster(id1)
	eststo wy321m, title("Wealth")
reg rank_w3 rank_wp rank_wgp rank_s3 rank_s2 rank_s1 i.bg_w3 i.bg_w2 i.bg_w1 i.bg_s3 i.bg_s2 i.bg_s1 if sample321==1, cluster(id1)
	eststo ws321m, title("Wealth")


reg rank_w3 rank_wp rank_y3 rank_y2 rank_s3 rank_s2 i.bg_w3 i.bg_w2 i.bg_y3 i.bg_y2 i.bg_s3 i.bg_s2, cluster(id1)
	gen sample32=e(sample)

	eststo wys32m, title("Wealth")
reg rank_w3 rank_wp i.bg_w3 i.bg_w2 if sample32==1, cluster(id1)
	eststo w32m, title("Wealth")
reg rank_y3 rank_y2 i.bg_y3 i.bg_y2 if sample32==1, cluster(id1)
	eststo y32m, title("Earnings")
reg rank_s3 rank_s2 i.bg_s3 i.bg_s2 if sample32==1, cluster(id1)
	eststo s32m, title("Schooling")
reg rank_w3 rank_wp rank_y3 rank_y2 i.bg_w3 i.bg_w2 i.bg_y3 i.bg_y2 if sample32==1, cluster(id1)
	eststo wy32m, title("Wealth")
reg rank_w3 rank_wp rank_s3 rank_s2 i.bg_w3 i.bg_w2 i.bg_s3 i.bg_s2 if sample32==1, cluster(id1)
	eststo ws32m, title("Wealth")


reg rank_w3 rank_wgp rank_y3 rank_y1 rank_s3 rank_s1 i.bg_w3 i.bg_w1 i.bg_y3 i.bg_y1 i.bg_s3 i.bg_s1, cluster(id1)
	gen sample31=e(sample)

	eststo wys31m, title("Wealth")
reg rank_w3 rank_wgp i.bg_w3 i.bg_w1 if sample31==1, cluster(id1)
	eststo w31m, title("Wealth")
reg rank_y3 rank_y1 i.bg_y3 i.bg_y1 if sample31==1, cluster(id1)
	eststo y31m, title("Earnings")
reg rank_s3 rank_s1 i.bg_s3 i.bg_s1 if sample31==1, cluster(id1)
	eststo s31m, title("Schooling")
reg rank_w3 rank_wgp rank_y3 rank_y1 i.bg_w3 i.bg_w1 i.bg_y3 i.bg_y1 if sample31==1, cluster(id1)
	eststo wy31m, title("Wealth")
reg rank_w3 rank_wgp rank_s3 rank_s1 i.bg_w3 i.bg_w1 i.bg_s3 i.bg_s1 if sample31==1, cluster(id1)
	eststo ws31m, title("Wealth")




* Table 3, panel A
*-----------------
esttab w21 w32 w31 w321, ///
	b(3) se(3) keep(rank_wp rank_wgp) ///
	varlabel(rank_wp "Parents" rank_wgp "Grandparents") ///
	mlabels(,titles) title("Rank regressions") ///
	mgroups("2nd generation" "3rd generation", pattern(1 1 0 0)) ///
	stats(r2 N, label("R2" "N") fmt(3 0)) ///
	star(* 0.10 ** 0.05 *** 0.01)

* Table 3, panel B
*-----------------
esttab d21 d32 d31 d321, ///
	b(3) se(3) keep(d_wp d_wgp) varlabel(d_wp "Parents" d_wgp "Grandparents") ///
	mgroups("2nd generation" "3rd generation", pattern(1 1 0 0)) ///
	nomtitles title("Top decile regressions") star(* 0.10 ** 0.05 *** 0.01)  ///
	stats(r2 N, label("R2" "N") fmt(3 0))

* Table 4, panel A
*-----------------
esttab wd21 wd32 wd31 wd321, ///
	b(3) se(3) keep(rank_wdgp rank_wdp) ///
	rename(rank_wp rank_wdp) ///
	varlabel(rank_wdp "Parents" rank_wdgp "Grandparents") ///
	mlabels(,titles) title("Estate wealth for 1st generation") ///
	stats(r2 N, label("R2" "N") fmt(3 0)) ///
	star(* 0.10 ** 0.05 *** 0.01)

* Table 9
*--------
esttab w21m y21m s21m wy21m ws21m wys21m, ///
	b(3) se(3) keep(rank_wp rank_y2 rank_y1 rank_s2 rank_s1) ///
	varlabel(rank_wp "Parents' wealth" rank_y2 "Own earnings" ///
	rank_y1 "Parents' earnings" rank_s2 "Own schooling" rank_s1 "Parents' schooling") ///
	nomtitles stats(r2 N, label("R2" "N") fmt(3 0)) ///
	mgroups("Wealth" "Earnings" "Schooling" "Wealth", pattern(1 1 1 1 0 0)) ///
	title("2nd generation mediating variables regressions") ///
	star(* 0.10 ** 0.05 *** 0.01)

* Online Appendix Table 3, panel A
*---------------------------------
esttab wr21 wr32 wr31 wr321, ///
	b(3) se(3) keep(rank_wrp rank_wgp) ///
	rename(rank_wp rank_wrp) ///
	varlabel(rank_wp "Parents" rank_wgp "Grandparents") ///
	nomtitles title("Real estate at market value") ///
	mgroups("2nd generation" "3rd generation", pattern(1 1 0 0)) ///
	stats(r2 N, label("R2" "N") fmt(3 0)) ///
	star(* 0.10 ** 0.05 *** 0.01)

* Online appendix table 3, panel B
*---------------------------------
esttab wc21 wc32 wc31 wc321, ///
	b(3) se(3) keep(rank_wcp rank_wgp) ///
	varlabel(rank_wcp "Parents" rank_wgp "Grandparents") ///
	nomtitles title("Wealth left-censored at zero") ///
	stats(r2 N, label("R2" "N") fmt(3 0)) ///
	star(* 0.10 ** 0.05 *** 0.01)

* Online Appendix Table 3, panel C
*---------------------------------
esttab wk21 wk32 wk31 wk321, ///
	b(3) se(3) keep(rank_wkgp rank_wkp) ///
	rename(rank_wp rank_wkp) ///
	varlabel(rank_wkp "Parents" rank_wkgp "Grandparents") ///
	nomtitles title("Capitalised wealth for 1st generation") ///
	stats(r2 N, label("R2" "N") fmt(3 0)) ///
	star(* 0.10 ** 0.05 *** 0.01)

* Online Appendix Table 4, panel A
*---------------------------------
esttab v21 v32 v31 v321, se keep(v_wp v_wgp) varlabel(v_wp "Parents" v_wgp "Grandparents") ///
	mgroups("2nd generation" "3rd generation", pattern(1 1 0 0)) nomtitles title("Top five percent") ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(r2 N, label("R2" "N") fmt(3 0))

* Online Appendix Table 4, panel B
*---------------------------------
esttab f21 f32 f31 f321, se keep(f_wp f_wgp) varlabel(f_wp "Parents" f_wgp "Grandparents") ///
	nomtitles title("Top fifteen percent") ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(r2 N, label("R2" "N") fmt(3 0))

* Online Appendix Table 5
*------------------------
esttab w21p w32p w31p w321p, ///
	b(3) se(3) keep(rank_wp rank_wgp) varlabel(rank_wp "Parents" rank_wgp "Grandparents") ///
	nomtitles title("Wealth regressions, three-generation panel") ///
	stats(r2 N, label("R2" "N") fmt(3 0)) ///
	star(* 0.10 ** 0.05 *** 0.01)

* Online Appendix Table 6, panel A
*---------------------------------
esttab ihs21 ihs32 ihs31 ihs321, b(3) se(3) keep(ihs_wp ihs_wgp) ///
	varlabel(ihs_wp "Parents" ihs_wgp "Grandparents") nomtitles ///
	title("IHS wealth") ///
	mgroups("2nd generation" "3rd generation", pattern(1 1 0 0)) ///
	stats(r2 N, label("R2" "N") fmt(3 0)) ///
	star(* 0.10 ** 0.05 *** 0.01)

* Online Appendix Table 6, panel B
*---------------------------------
esttab ihs21_10 ihs32_10 ihs31_10 ihs321_10, ///
	b(3) se(3) keep(ihs_wp_10 ihs_wgp_10) ///
	varlabel(ihs_wp_10 "Parents" ihs_wgp_10 "Grandparents") nomtitles ///
	title("IHS wealth; Adding 10 to all with zero wealth") ///
	stats(r2 N, label("R2" "N") fmt(3 0)) star(* 0.10 ** 0.05 *** 0.01)

* Online Appendix Table 6, panel C
*---------------------------------

esttab ihs21_1000 ihs32_1000 ihs31_1000 ihs321_1000, ///
	b(3) se(3) keep(ihs_wp_1000 ihs_wgp_1000) ///
	varlabel(ihs_wp_1000 "Parents" ihs_wgp_1000 "Grandparents") nomtitles ///
	title("IHS wealth; Adding 1000 to all with zero wealth")  ///
	stats(r2 N, label("R2" "N") fmt(3 0)) star(* 0.10 ** 0.05 *** 0.01)

* Online Appendix Table 6, panel D
*---------------------------------
esttab ln21 ln32 ln31 ln321, b(3) se(3) keep(ln_wp ln_wgp) ///
	varlabel(ln_wp "Parents" ln_wgp "Grandparents") nomtitles ///
	title("Log wealth") ///
	stats(r2 N, label("R2" "N") fmt(3 0)) star(* 0.10 ** 0.05 *** 0.01)

* Online Appendix Table 6, panel E
*---------------------------------
esttab r21 r32 r31 r321, b(3) se(3) keep(rank_wp rank_wgp) ///
	varlabel(rank_wp "Parents" rank_wgp "Grandparents") nomtitles ///
	title("Ranked wealth, log sample (Panel D)") ///
	stats(r2 N, label("R2" "N") fmt(3 0)) star(* 0.10 ** 0.05 *** 0.01)


* Online Appendix Table 8
*------------------------
esttab w32y w31y w321y, ///
	b(3) se(3) keep(rank_wp rank_wgp) ///
	varlabel(rank_wp "Parents" rank_wgp "Grandparents") ///
	title("Wealth regressions at younger ages") stats(r2 N, label("R2" "N") fmt(3 0)) ///
	nomtitles star(* 0.10 ** 0.05 *** 0.01)

* Online Appendix Table 14
*-------------------------
esttab w0 wy0 ws0 wys0, ///
	b(3) se(3) keep(rank_wp rank_y2 rank_y1 rank_s2 rank_s1) ///
	varlabel(rank_wp "Parents' wealth" rank_y2 "Own income" rank_y1 "Parents' income" rank_s2 "Own schooling" rank_s1 "Parents' schooling") ///
	nomtitles stats(r2 N, label("R2" "N") fmt(3 0)) ///
	title("Mediating variables regressions, child's wealth adjusted for inheritance") ///
	star(* 0.10 ** 0.05 *** 0.01) order(rank_wp rank_y1 rank_s1 rank_y2 rank_s2) ///
	varwidth(20)


* Online Appendix Table 15, panel A
*----------------------------------
esttab w32m y32m s32m wy32m ws32m wys32m, ///
	b(3) se(3) keep(rank_wp rank_y3 rank_y2 rank_s3 rank_s2) ///
	varlabel(rank_wp "Parents' wealth" rank_y3 "Own earnings" ///
	rank_y2 "Parents' earnings" rank_s3 "Own schooling" rank_s2 "Parents' schooling") ///
	title("Regressions of 3rd generation on parents") ///
	mgroups("Wealth" "Earnings" "Schooling" "Wealth", pattern(1 1 1 1 0 0)) ///
	nomtitles stats(r2 N, label("R2" "N") fmt(3 0)) ///
	star(* 0.10 ** 0.05 *** 0.01)

* Online Appendix Table 15, panel B
*----------------------------------
esttab w31m y31m s31m wy31m ws31m wys31m, ///
	b(3) se(3) keep(rank_wgp rank_y3 rank_y1 rank_s3 rank_s1) ///
	varlabel(rank_wgp "Grandparents' wealth" rank_y3 "Own income" ///
	rank_y1 "Grandparents' earnings" rank_s3 "Own schooling" rank_s1 "Grandparents' schooling") ///
	title("Regressions of 3rd generation on grandparents") ///
	nomtitles stats(r2 N, label("R2" "N") fmt(3 0)) ///
	star(* 0.10 ** 0.05 *** 0.01)

* Online Appendix Table 15, panel C
*----------------------------------
esttab w321m y321m s321m wy321m ws321m wys321m, ///
	b(3) se(3) keep(rank_wp rank_wgp rank_y3 rank_y2 rank_y1 rank_s3 rank_s2 rank_s1) ///
	varlabel(rank_wp "Parents' wealth" rank_wgp "Grandparents' wealth" rank_y3 "Own income" ///
	rank_y2 "Parents' earnings" rank_y1 "Grandparents' earnings" rank_s3 "Own schooling" ///
	rank_s2 "Parents' schooling" rank_s1 "Grandparents' schooling") ///
	title("Regressions of 3rd generation on parents and grandparents") ///
	nomtitles stats(r2 N, label("R2" "N") fmt(3 0)) ///
	star(* 0.10 ** 0.05 *** 0.01)
		
