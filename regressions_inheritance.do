set more off

use "data\workdata\estimation_data_2ndGen.dta", clear

eststo drop *

qui: reg rank_w2 rank_inh2 rank_w1 rank_wi_cap_02 i.dg_inh2
	gen isample=e(sample)

gen isample_two = (isample == 1 & one == 0)


* Create a file indicating the inheritance estimation samples
preserve
	keep if isample

	rename isample_two both

	keep lopnrgems both

	save "data\workdata\inh_sample.dta", replace
restore


* Ranked inheritances
*--------------------

reg rank_w_912 rank_w1 i.bg_w_912 i.bg_w1 if isample==1, cluster(id1)
	eststo w912w1
reg rank_w_912 rank_inh2 i.bg_w_912 i.dg_inh2 if isample==1, cluster(id1)
	eststo w912i1	
reg rank_w_912 rank_w1 rank_inh2 i.bg_w_912 i.bg_w1 i.dg_inh2 if isample==1, cluster(id1)
	eststo w912wi1

reg rank_w_912 rank_w1 i.bg_w_912 i.bg_w1 if isample_two==1, cluster(id1)
	eststo w912w1t
reg rank_w_912 rank_inh2 i.bg_w_912 i.dg_inh2 if isample_two==1, cluster(id1)
	eststo w912i1t
reg rank_w_912 rank_w1 rank_inh2 i.bg_w_912 i.bg_w1 i.dg_inh2 if isample_two==1, cluster(id1)
	eststo w912wi1t


* Ranked inheritances, capitalized
*---------------------------------

reg rank_w_912 rank_w1 i.bg_w_912 i.bg_w1 if isample==1, cluster(id1)
	eststo w1
reg rank_w_912 rank_w1 i.bg_w_912 i.bg_w1 if isample_two==1, cluster(id1)
	eststo w1t

* 0 percent
reg rank_w_912 rank_inh_cap_02 i.bg_w_912 i.bg_inh_cap_02 if isample==1, cluster(id1)
	eststo c0i1	
reg rank_w_912 rank_w1 rank_inh_cap_02 i.bg_w_912 i.bg_w1 i.bg_inh_cap_02 if isample==1, cluster(id1)
	eststo c0wi1

reg rank_w_912 rank_inh_cap_02 i.bg_w_912 i.bg_inh_cap_02 if isample_two==1, cluster(id1)
	eststo c0i1t
reg rank_w_912 rank_w1 rank_inh_cap_02 i.bg_w_912 i.bg_w1 i.bg_inh_cap_02 if isample_two==1, cluster(id1)
	eststo c0wi1t

* 3 percent
reg rank_w_912 rank_inh_cap_32 i.bg_w_912 i.bg_inh_cap_32 if isample==1, cluster(id1)
	eststo c3i1	
reg rank_w_912 rank_w1 rank_inh_cap_32 i.bg_w_912 i.bg_w1 i.bg_inh_cap_32 if isample==1, cluster(id1)
	eststo c3wi1

reg rank_w_912 rank_inh_cap_32 i.bg_w_912 i.bg_inh_cap_32 if isample_two==1, cluster(id1)
	eststo c3i1t
reg rank_w_912 rank_w1 rank_inh_cap_32 i.bg_w_912 i.bg_w1 i.bg_inh_cap_32 if isample_two==1, cluster(id1)
	eststo c3wi1t

* -3 percent
reg rank_w_912 rank_inh_cap_neg32 i.bg_w_912 i.bg_inh_cap_neg32 if isample==1, cluster(id1)
	eststo cn3i1	
reg rank_w_912 rank_w1 rank_inh_cap_neg32 i.bg_w_912 i.bg_w1 i.bg_inh_cap_neg32 if isample==1, cluster(id1)
	eststo cn3wi1

reg rank_w_912 rank_inh_cap_neg32 i.bg_w_912 i.bg_inh_cap_neg32 if isample_two==1, cluster(id1)
	eststo cn3i1t
reg rank_w_912 rank_w1 rank_inh_cap_neg32 i.bg_w_912 i.bg_w1 i.bg_inh_cap_neg32 if isample_two==1, cluster(id1)
	eststo cn3wi1t


* Inheritance-adjusted wealth regressions
*----------------------------------------

* Main regressions
reg rank_w_912 rank_w1 i.bg_w_912 i.bg_w1 if isample==1, cluster(id1)
	eststo c91

qui: reg rank_wi_cap_neg32 rank_w1 i.bg_wi_cap_neg32 i.bg_w1 if isample==1, cluster(id1)
	eststo i_n3

qui: reg rank_wi_cap_02 rank_w1 i.bg_wi_cap_02 i.bg_w1 if isample==1, cluster(id1)
	eststo i_0

qui: reg rank_wi_cap_32 rank_w1 i.bg_wi_cap_32 i.bg_w1 if isample==1, cluster(id1)
	eststo i_3

* PPVR
qui: reg rank_wi_ppvr_neg32 rank_w1 i.bg_wi_ppvr_neg32 i.bg_w1 if isample==1, cluster(id1)
	eststo ip_n3

qui: reg rank_wi_ppvr_02 rank_w1 i.bg_wi_ppvr_02 i.bg_w1 if isample==1, cluster(id1)
	eststo ip_0

qui: reg rank_wi_ppvr_32 rank_w1 i.bg_wi_ppvr_32 i.bg_w1 if isample==1, cluster(id1)
	eststo ip_3


* Only those with two inheritances
reg rank_w_912 rank_w1 i.bg_w_912 i.bg_w1 if isample_two==1, cluster(id1)
	eststo c91t

qui: reg rank_wi_cap_neg32 rank_w1 i.bg_wi_cap_neg32 i.bg_w1 if isample_two==1, cluster(id1)
	eststo i_n3t

qui: reg rank_wi_cap_02 rank_w1 i.bg_wi_cap_02 i.bg_w1 if isample_two==1, cluster(id1)
	eststo i_0t

qui: reg rank_wi_cap_32 rank_w1 i.bg_wi_cap_32 i.bg_w1 if isample_two==1, cluster(id1)
	eststo i_3t

*PPVR
qui: reg rank_wi_ppvr_neg32 rank_w1 i.bg_wi_ppvr_neg32 i.bg_w1 if isample_two==1, cluster(id1)
	eststo ip_n3t

qui: reg rank_wi_ppvr_02 rank_w1 i.bg_wi_ppvr_02 i.bg_w1 if isample_two==1, cluster(id1)
	eststo ip_0t

qui: reg rank_wi_ppvr_32 rank_w1 i.bg_wi_ppvr_32 i.bg_w1 if isample_two==1, cluster(id1)
	eststo ip_3t




* Censor inheritance
*-------------------

count if w1 == 0
	local zero = r(N)
count if w1 != .
	local share = `zero'/r(N)
	display `share'

gen inh_cens2 = inh2

sort inh_cens2
count if inh_cens2 != .
local num_zero = round(r(N) * `share')
replace inh_cens2 = 0 in 1/`num_zero'


transprog, w(inh_cens) gen(2) b(d)

reg rank_w_912 rank_w1 i.bg_w_912 i.bg_w1 if isample==1, cluster(id1)
	eststo cw2w1
reg rank_w_912 rank_inh_cens2 i.bg_w_912 i.dg_inh2 if isample==1, cluster(id1)
	eststo cw2i1	
reg rank_w_912 rank_w1 rank_inh_cens2 i.bg_w_912 i.bg_w1 i.dg_inh2 if isample==1, cluster(id1)
	eststo cw2wi1

reg rank_w_912 rank_w1 i.bg_w_912 i.bg_w1 if isample_two==1, cluster(id1)
	eststo cw2w1t
reg rank_w_912 rank_inh_cens2 i.bg_w_912 i.dg_inh2 if isample_two==1, cluster(id1)
	eststo cw2i1t
reg rank_w_912 rank_w1 rank_inh_cens2 i.bg_w_912 i.bg_w1 i.dg_inh2 if isample_two==1, cluster(id1)
	eststo cw2wi1t


* Top decile regressions
*-----------------------

* Top decile
foreach i in w_912 w1 inh2 {
	gen d_`i'=(rank_`i'>0.9 & rank_`i'!=.)
	replace d_`i'=. if rank_`i'==.
}


reg d_w_912 d_w1 i.bg_w_912 i.bg_w1 if isample==1, cluster(id1)
	eststo dw2w1
reg d_w_912 d_inh2 i.bg_w_912 i.dg_inh2 if isample==1, cluster(id1)
	eststo dw2i1	
reg d_w_912 d_w1 d_inh2 i.bg_w_912 i.bg_w1 i.dg_inh2 if isample==1, cluster(id1)
	eststo dw2wi1

reg d_w_912 d_w1 i.bg_w_912 i.bg_w1 if isample_two==1, cluster(id1)
	eststo dw2w1t
reg d_w_912 d_inh2 i.bg_w_912 i.dg_inh2 if isample_two==1, cluster(id1)
	eststo dw2i1t
reg d_w_912 d_w1 d_inh2 i.bg_w_912 i.bg_w1 i.dg_inh2 if isample_two==1, cluster(id1)
	eststo dw2wi1t


* Regressions by parental status
*-------------------------------

* Main
reg rank_w_912 rank_w1 i.bg_w_912 i.bg_w1, cluster(id1)
	eststo r1

* Both dead
reg rank_w_912 rank_w1 i.bg_w_912 i.bg_w1 if dy_1st2 < 1991 & dy_2nd2 < 1991, cluster(id1)
	eststo rd2

* At least one alive
reg rank_w_912 rank_w1 i.bg_w_912 i.bg_w1 if dy_2nd2 >= 1991, cluster(id1)
	eststo rd3

gen dead = (dy_1st2 < 1991 & dy_2nd2 < 1991)

* Interaction
reg rank_w_912 c.rank_w1##i.dead i.bg_w_912 i.bg_w1, cluster(id1)
	eststo rdi


* Table 7
*--------

esttab w912w1t w912i1t w912wi1t c0i1t c0wi1t, b(3) se(3) keep(rank*) ///
	rename(rank_inh_cap_02 rank_inh2) ///
	varlabel(rank_w1 "Parents' wealth" rank_inh2 "Inheritance") ///
	mgroups("" "Year of death" "Birth year", pattern(1 1 0 1 0)) nomtitles ///
	title("Inheritance regressions") ///
	order(rank_w1 rank_inh2) star(* 0.10 ** 0.05 *** 0.01) stats(r2 N, label("R2" "N") fmt(3 0))


* Table 8, panel A
*-----------------
esttab c91t i_3t i_0t i_n3t, ///
	b(3) se(3) keep(rank_w1) ///
	mtitles("Main" "3%" "0%" "-3%") ///
	star(* 0.10 ** 0.05 *** 0.01) stats(r2 N, label("R2" "N") fmt(3 0)) ///
	title("Purged inheritance regressions, both inheritances")

* Table 8, panel B
*-----------------
esttab c91t ip_3t ip_0t ip_n3t, ///
	b(3) se(3) keep(rank_w1) ///
	mtitles("Main" "3%" "0%" "-3%") ///
	star(* 0.10 ** 0.05 *** 0.01) stats(r2 N, label("R2" "N") fmt(3 0)) ///
	title("Purged inheritance regressions, PPVR, both inheritances")


* Online Appendix Table 9
*------------------------

esttab w912w1 w912i1 w912wi1 c0i1 c0wi1, b(3) se(3) keep(rank*) ///
	rename(rank_inh_cap_02 rank_inh2) ///
	varlabel(rank_w1 "Parents' wealth" rank_inh2 "Inheritance") ///
	mgroups("" "Year of death" "Birth year", pattern(1 1 0 1 0)) nomtitles ///
	title("Inheritance regressions, at least one inheritance") ///
	order(rank_w1 rank_inh2) star(* 0.10 ** 0.05 *** 0.01) stats(r2 N, label("R2" "N") fmt(3 0))


* Online Appendix Table 10, panel A
*----------------------------------

esttab w912w1t c3i1t c3wi1t cn3i1t cn3wi1t, b(3) se(3) keep(rank*) ///
	rename(rank_inh_cap_32 rank_inh2 rank_inh_cap_neg32 rank_inh2) ///
	varlabel(rank_w1 "Parents' wealth" rank_inh2 "Inheritance") ///
	mgroups("" "3%" "-3%", pattern(1 1 0 1 0)) nomtitles ///
	title("Inheritance regressions") ///
	order(rank_w1 rank_inh2) star(* 0.10 ** 0.05 *** 0.01) stats(r2 N, label("R2" "N") fmt(3 0))


* Online Appendix Table 10, panel B
*----------------------------------

esttab w912w1 c3i1 c3wi1 cn3i1 cn3wi1, b(3) se(3) keep(rank*) ///
	rename(rank_inh_cap_32 rank_inh2 rank_inh_cap_neg32 rank_inh2) ///
	varlabel(rank_w1 "Parents' wealth" rank_inh2 "Inheritance") ///
	mgroups("" "3%" "-3%", pattern(1 1 0 1 0)) nomtitles ///
	title("Inheritance regressions, at least one inheritance") ///
	order(rank_w1 rank_inh2) star(* 0.10 ** 0.05 *** 0.01) stats(r2 N, label("R2" "N") fmt(3 0))

* Online appendix table 11, panel A
*----------------------------------
esttab cw2i1 cw2w1 cw2wi1 cw2i1t cw2w1t cw2wi1t, b(3) se(3) keep(rank*) ///
	varlabel(rank_w1 "Parents' wealth" rank_inh_cens2 "Inheritance") ///
	mgroups("One or two parents bequeathing" "Two parents bequeathing", pattern(1 0 0 1 0 0)) nomtitles ///
	title("Inheritance regressions, censored inheritance, dep. var: 2nd gen wealth") ///
	order(rank_w1 rank_inh_cens2) star(* 0.10 ** 0.05 *** 0.01) stats(r2 N, label("R2" "Obs.") fmt(3 0))


* Online appendix table 11, panel B
*----------------------------------
esttab dw2i1 dw2w1 dw2wi1 dw2i1t dw2w1t dw2wi1t, b(3) se(3) keep(d_*) ///
	varlabel(d_w1 "Parents' wealth" d_inh2 "Inheritance") ///
	mgroups("One or two parents bequeathing" "Two parents bequeathing", pattern(1 0 0 1 0 0)) nomtitles ///
	title("Top decile inheritance regressions, dep. var: 2nd gen wealth") ///
	order(d_w1 d_inh2) star(* 0.10 ** 0.05 *** 0.01) stats(r2 N, label("R2" "Obs.") fmt(3 0))


* Online appendix table 12, panel A
*----------------------------------
esttab c91 i_3 i_0 i_n3, ///
	b(3) se(3) keep(rank_w1) ///
	mtitles("Main" "3%" "0%" "-3%") ///
	star(* 0.10 ** 0.05 *** 0.01) stats(r2 N, label("R2" "N") fmt(3 0)) ///
	title("Purged inheritance regressions, at least one inheritance")

* Online appendix table 12, panel B
*----------------------------------
esttab c91 ip_3 ip_0 ip_n3, ///
	b(3) se(3) keep(rank_w1) ///
	mtitles("Main" "3%" "0%" "-3%") ///
	star(* 0.10 ** 0.05 *** 0.01) stats(r2 N, label("R2" "N") fmt(3 0)) ///
	title("Purged inheritance regressions, PPVR, at least one inheritance")


* Online appendix table 13
*-------------------------
esttab r1 rd2 rd3 rdi, ///
	b(3) se(3) keep(rank_w1 1.dead#c.rank_w1) ///
	mtitles("Main" "Both parents dead" "At least one alive" "Interaction") ///
	varlabel(rank_w1 "Parents' wealth" 1.dead#c.rank_w1 "Parents' wealth x both dead") ///
	star(* 0.10 ** 0.05 *** 0.01) stats(r2 N, label("R2" "N") fmt(3 0)) ///
	title("Wealth regressions") varwidth(30)
