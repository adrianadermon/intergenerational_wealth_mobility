* Create family indicator for clustering

* This file requires the a2group command from the a2reg package by Amine Ouazad

set more off

* Prepare data on siblings in the index generatione
use "data\familjindikator_ut.dta", clear
rename Lopnrgems lopnrgems
destring lopnrgems, replace
tempfile famind
save `famind', replace


use "data\Malmorelationer.dta", clear

keep lopnrgems mid_scb generation

keep if generation=="Indexgen"

* This creates an id variable for the first generation parents
gen id=mid_scb

* There are some siblings in the index generation, who consequently have the same parents - this makes sure we put them in the same family
merge 1:1 lopnrgems using `famind', nogenerate keep(match master)

bysort fam: egen id1=min(id) if fam!=.
replace id1=id if id1==.
drop id

keep mid_scb id1

tempfile id
save `id'


use "data\Malmorelationer.dta", clear

keep if generation=="Indexgen" | generation=="Ejindexgen"

keep lopnrgems* mid_scb

tempfile gen2
save `gen2'

use "data\Malmorelationer.dta", clear

keep if generation=="Barn" | generation=="Forald_bb"

keep lopnrgems* mid_scb

tempfile gen3
save `gen3'


use "data\Malmorelationer.dta", clear

keep if generation=="Barnbarn"

keep lopnrgems* mid_scb

tempfile gen4
save `gen4'

*----------------------

* Create 4th gen key
rename (lopnrgems* mid_scb) =4

* Add 3rd gen
rename lopnrgemsmor4 lopnrgems

joinby lopnrgems using `gen3', unmatched(master) update
drop _merge

rename (mid_scb lopnrgemsmor lopnrgemsfar) =_mor_3

rename lopnrgems lopnrgemsmor4
rename lopnrgemsfar4 lopnrgems

joinby lopnrgems using `gen3', unmatched(master) update
drop _merge

rename (mid_scb lopnrgemsmor lopnrgemsfar) =_far_3

rename lopnrgems lopnrgemsfar4

* Add 2nd gen
rename lopnrgemsmor_mor_3 lopnrgems

joinby lopnrgems using `gen2', unmatched(master) update
drop _merge

rename mid_scb =_mormor_2

rename lopnrgems lopnrgemsmor_mor_3
rename lopnrgemsmor_far_3 lopnrgems

joinby lopnrgems using `gen2', unmatched(master) update
drop _merge

rename mid_scb =_morfar_2

rename lopnrgems lopnrgemsmor_far_3
rename lopnrgemsfar_mor_3 lopnrgems

joinby lopnrgems using `gen2', unmatched(master) update
drop _merge

rename mid_scb mid_scb_farmor_2

rename lopnrgems lopnrgemsfar_mor_3
rename lopnrgemsfar_far_3 lopnrgems

joinby lopnrgems using `gen2', unmatched(master) update
drop _merge

rename mid_scb mid_scb_farfar_2

rename lopnrgems lopnrgemsfar_far_3

keep lopnrgems4 mid_scb*


rename mid_scb* mid_scb#, renumber

tempfile midfile
save `midfile'

forvalues i = 1/7 {
	use `midfile'
	keep lopnrgems4 mid_scb`i'
	rename mid_scb`i' mid_scb
	tempfile midfile`i'
	save `midfile`i''
}

use `midfile1'
forvalues i = 2/7 {
	append using `midfile`i''
}

drop if mid_scb==.
duplicates drop

sort lopnrgems4 mid_scb

rename lopnrgems4 lopnrgems

tempfile group4
save `group4'


*-------------

* Create 3rd gen key
use `gen3', clear

rename (lopnrgems* mid_scb) =3

* Add 2nd gen
rename lopnrgemsmor lopnrgems

joinby lopnrgems using `gen2', unmatched(master) update
drop _merge

rename mid_scb =_mor_2

rename lopnrgems lopnrgemsmor_3
rename lopnrgemsmor_3 lopnrgems

joinby lopnrgems using `gen2', unmatched(master) update
drop _merge

rename mid_scb =_far_2

rename lopnrgems lopnrgemsmor_3

keep lopnrgems3 mid_scb*


rename mid_scb* mid_scb#, renumber

tempfile midfile
save `midfile'

forvalues i = 1/3 {
	use `midfile'
	keep lopnrgems3 mid_scb`i'
	rename mid_scb`i' mid_scb
	tempfile midfile`i'
	save `midfile`i''
}

use `midfile1'
forvalues i = 2/3 {
	append using `midfile`i''
}

drop if mid_scb==.
duplicates drop

sort lopnrgems3 mid_scb

rename lopnrgems3 lopnrgems

tempfile group3
save `group3'


*-------------

* Create 2nd gen key
use `gen2', clear

keep lopnrgems mid_scb

sort lopnrgems mid_scb

tempfile group2
save `group2'

*-----------

append using `group3'

append using `group4'

duplicates drop

merge m:1 mid_scb using `id', nogenerate

a2group, individual(lopnrgems) unit(id1) groupvar(group)

drop lopnrgems id1 

duplicates drop

rename group id1

save "data\workdata\cluster_id.dta", replace

clear
