set more off

use "data\workdata\estimation_data_4thGen.dta", clear

eststo drop *

* For table 5
*------------

qui: reg rank_w4 rank_w3 rank_w2 rank_w1 i.bg_w4 i.bg_w3 i.bg_w2 i.bg_w1
	keep if e(sample)

* Regress 4th gen wealth on 3rd gen wealth
reg rank_w4 rank_w3 i.bg_w4 i.bg_w3, cluster(id1)
	eststo w43, title("4th gen")

* Regress 4th gen wealth on 2nd gen wealth
reg rank_w4 rank_w2 i.bg_w4 i.bg_w2, cluster(id1)
	eststo w42, title("4th gen")

* Regress 4th gen wealth on 1st gen wealth
reg rank_w4 rank_w1 i.bg_w4 i.bg_w1, cluster(id1)
	eststo w41, title("4th gen")

* Regress 4th gen wealth on 3rd and 2nd gen wealth
reg rank_w4 rank_w3 rank_w2 i.bg_w4 i.bg_w3 i.bg_w2, cluster(id1)
	eststo w432, title("4th gen")

* Regress 4th gen wealth on 3rd, 2nd and 1st gen wealth
reg rank_w4 rank_w3 rank_w2 rank_w1 i.bg_w4 i.bg_w3 i.bg_w2 i.bg_w1, cluster(id1)
	eststo w4321, title("4th gen")
	

* Older

qui: reg rank_w4 rank_w3 rank_w2 rank_w1 i.bg_w4 i.bg_w3 i.bg_w2 i.bg_w1 if by4<1988
	gen sample_older = e(sample)
	
* Regress 4th gen wealth on 3rd gen wealth
reg rank_w4 rank_w3 i.bg_w4 i.bg_w3 if sample_older==1, cluster(id1)
	eststo w43o, title("4th gen")

* Regress 4th gen wealth on 2nd gen wealth
reg rank_w4 rank_w2 i.bg_w4 i.bg_w2 if sample_older==1, cluster(id1)
	eststo w42o, title("4th gen")

* Regress 4th gen wealth on 1st gen wealth
reg rank_w4 rank_w1 i.bg_w4 i.bg_w1 if sample_older==1, cluster(id1)
	eststo w41o, title("4th gen")

* Regress 4th gen wealth on 3rd and 2nd gen wealth
reg rank_w4 rank_w3 rank_w2 i.bg_w4 i.bg_w3 i.bg_w2 if sample_older==1, cluster(id1)
	eststo w432o, title("4th gen")

* Regress 4th gen wealth on 3rd, 2nd and 1st gen wealth
reg rank_w4 rank_w3 rank_w2 rank_w1 i.bg_w4 i.bg_w3 i.bg_w2 i.bg_w1 if sample_older==1, cluster(id1)
	eststo w4321o, title("4th gen")

* Younger

qui: reg rank_w4 rank_w3 rank_w2 rank_w1 i.bg_w4 i.bg_w3 i.bg_w2 i.bg_w1 if by4>=1988
	gen sample_younger = e(sample)

* Regress 4th gen wealth on 3rd gen wealth
reg rank_w4 rank_w3 i.bg_w4 i.bg_w3 if sample_younger==1, cluster(id1)
	eststo w43y, title("4th gen")

* Regress 4th gen wealth on 2nd gen wealth
reg rank_w4 rank_w2 i.bg_w4 i.bg_w2 if sample_younger==1, cluster(id1)
	eststo w42y, title("4th gen")

* Regress 4th gen wealth on 1st gen wealth
reg rank_w4 rank_w1 i.bg_w4 i.bg_w1 if sample_younger==1, cluster(id1)
	eststo w41y, title("4th gen")

* Regress 4th gen wealth on 3rd and 2nd gen wealth
reg rank_w4 rank_w3 rank_w2 i.bg_w4 i.bg_w3 i.bg_w2 if sample_younger==1, cluster(id1)
	eststo w432y, title("4th gen")

* Regress 4th gen wealth on 3rd, 2nd and 1st gen wealth
reg rank_w4 rank_w3 rank_w2 rank_w1 i.bg_w4 i.bg_w3 i.bg_w2 i.bg_w1 if sample_younger==1, cluster(id1)
	eststo w4321y, title("4th gen")

	
* Table 5, panel A	
esttab w43 w42 w41 w432 w4321, ///
	b(3) se(3) keep(rank_w3 rank_w2 rank_w1) ///
	varlabel(rank_w1 "Great grandparents" rank_w2 "Grandparents" rank_w3 "Parents") ///
	nomtitles title("4th generation wealth regressions") ///
	stats(r2 N, label("R2" "N") fmt(3 0)) ///
	star(* 0.10 ** 0.05 *** 0.01)

* Table 5, panel B
esttab w43y w42y w41y w432y w4321y, ///
	b(3) se(3) keep(rank_w3 rank_w2 rank_w1) ///
	varlabel(rank_w1 "Great grandparents" ///
	rank_w2 "Grandparents" rank_w3 "Parents") ///
	nomtitles title("Age 18 and younger") ///
	stats(r2 N, label("R2" "N") fmt(3 0)) ///
	star(* 0.10 ** 0.05 *** 0.01)
	
* Table 5, panel C
esttab w43o w42o w41o w432o w4321o, ///
	b(3) se(3) keep(rank_w3 rank_w2 rank_w1) ///
	varlabel(rank_w1 "Great grandparents" rank_w2 "Grandparents" rank_w3 "Parents") ///
	nomtitles title("Older than 18") ///
	stats(r2 N, label("R2" "N") fmt(3 0)) ///
	star(* 0.10 ** 0.05 *** 0.01)
