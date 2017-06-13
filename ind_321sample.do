use "data\workdata\malmorelationerextended.dta", clear

keep lopnrgems* generation *by

drop if by==.

drop by

tempfile all
save `all'


* Create 321 panel indicator file

* Restrict gen2
use `all', clear
keep if generation=="Indexgen"
drop generation

drop if fatherby==. & motherby==.

drop lopnrgemsmor lopnrgemsfar

duplicates drop


merge 1:1 lopnrgems using "data\workdata\estimation_data_2ndGen.dta", nogenerate keep(match)

keep if w2!=. & w1!=.

keep lopnrgems

tempfile gen2
save `gen2'


use `all', clear
keep if generation=="Barn"
drop generation

duplicates drop

rename lopnrgems lopnrgems3

* Keep only those with wealth observations
merge 1:1 lopnrgems3 using "data\workdata\estimation_data_3rdGen.dta", nogenerate keep(match)
drop if w3==.

rename lopnrgems3 lopnrgems

drop *3

keep lopnrgems*

tempfile gen3
save `gen3'



use `gen2', clear

rename lopnrgems lopnrgemsmor

merge 1:m lopnrgemsmor using `gen3', keepusing(lopnrgems) keep(match) nogenerate

rename lopnrgems lopnrgemsbarn

rename lopnrgemsmor lopnrgems

tempfile gen3m
save `gen3m'


use `gen2', clear

rename lopnrgems lopnrgemsfar

merge 1:m lopnrgemsfar using `gen3', keepusing(lopnrgems) keep(match) nogenerate

rename lopnrgems lopnrgemsbarn

rename lopnrgemsfar lopnrgems

tempfile gen3f
save `gen3f'

append using `gen3m'

duplicates drop

tempfile g32
save `g32'

keep lopnrgems
duplicates drop

save "data\workdata\gen2ind_321sample.dta", replace

use `g32', clear

bysort lopnrgems: egen count=count(lopnrgemsbarn)

keep lopnrgemsbarn count
rename lopnrgemsbarn lopnrgems3
duplicates drop

bysort lopnrgems3: egen childcount=mean(count)
drop count

duplicates drop

save "data\workdata\gen3ind_321sample.dta", replace
