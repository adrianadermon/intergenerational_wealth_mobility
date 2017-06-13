use "data\arvsstegar_final_ut.dta", clear

* Fix a data entry error
replace lott_barn2=lott_barn1 if Lopnrgems=="00011309"

replace typ="Far" if typ=="far"
replace typ="Mor" if typ=="mor"

* Create variable with number of heirs for children and grandchildren separately
egen antal_lotter_barn=rownonmiss(lott_barn?)
egen antal_lotter_barnbarn=rownonmiss(lott_barnbarn*)

* We drop zero and missing inheritances (might want to use this information)
drop if antal_lotter_barn==0 & antal_lotter_barnbarn==0 & (lott_barnen==. | lott_barnen==0)

* Start with those where only a total sum is listed
gen cat=1 if lott_barnen!=. & antal_lotter_barn==0 & antal_lotter_barnbarn==0

replace skatt_barnen=0 if skatt_barnen==. & cat==1
* Calculate inflation-adjusted net inheritance per child
gen inheritance=((lott_barnen-skatt_barnen)/antal_barn) if cat==1



* Next, we work with those who have equal sharing among their children

* Create indicators for families with unequal sharing of the inheritance
gen unequal2=(lott_barn1!=lott_barn2 & antal_lotter_barn==2)
gen unequal3=((lott_barn1!=lott_barn2 | lott_barn1!=lott_barn3) & antal_lotter_barn==3)
gen unequal4=((lott_barn1!=lott_barn2 | lott_barn1!=lott_barn3 | lott_barn1!=lott_barn4) & antal_lotter_barn==4)

replace cat=2 if unequal2==0 & unequal3==0 & unequal4==0 & cat==.

replace skatt_barn1=0 if skatt_barn1==. & cat==2
* Calculate inflation-adjusted net inheritance for first child (which is equal to that for the other children)
replace inheritance=(lott_barn1-skatt_barn1) if cat==2



* Next, we work with those where we have an ID for the child
gen id_barn=1 if Lopnrgems_barn1!=""
replace id_barn=2 if Lopnrgems_barn2!=""
replace id_barn=3 if Lopnrgems_barn3!=""

replace cat=3 if id_barn!=. & cat==.
replace id_barn=. if cat!=3

forvalues i=1/3 {
	replace skatt_barn`i'=0 if skatt_barn`i'==. & cat==3
	replace inheritance=(lott_barn`i'-skatt_barn`i') if id_barn==`i' & cat==3
}

drop Lopnrgems_barn?


* Now, we take care of the grandchildren

* Calculate inheritance per grandchild for each child
forvalues i=1/4 {
	gen inheritance_gc`i'=((lott_barnbarn_barn`i'-min(0,skatt_barnbarn_barn`i'))/antalbarnbarn_barn`i')
}

forvalues i=5/6 {
	gen inheritance_gc`i'=(lott_barnbarn_barn`i'/antalbarnbarn_barn`i')
}

* Mark unequal 
gen unequal2gc=(lott_barnbarn_barn1/antalbarnbarn_barn1!=lott_barnbarn_barn2/antalbarnbarn_barn2 & antal_lotter_barnbarn==2)
replace unequal2gc=. if antal_lotter_barnbarn!=2
gen unequal3gc=((lott_barnbarn_barn1/antalbarnbarn_barn1!=lott_barnbarn_barn2/antalbarnbarn_barn2 | lott_barnbarn_barn1/antalbarnbarn_barn1!=lott_barnbarn_barn3/antalbarnbarn_barn3) & antal_lotter_barnbarn==3)
replace unequal3gc=. if antal_lotter_barnbarn!=3


tempfile bequests
save `bequests'



* Prepare file 
use "data\workdata\malmorelationerextended.dta", clear
keep if generation=="Indexgen" | generation=="EjIndexgen"
keep lopnrgems sex

tempfile 2ndgensex
save `2ndgensex'


* Create inheritance file for 2nd generation
use `bequests', clear

drop if typ=="Index" | typ=="Annan"

destring Lopnrgems_barn, gen(lopnrgems)
joinby lopnrgems using `2ndgensex', unmatched(master)


* Work with those where two children of different sex get different amounts
replace cat=4 if antal_lotter_barn==2 & kon_barn1!=kon_barn2 & cat==.
replace inheritance=(lott_barn1-skatt_barn1) if kon_barn1=="man" & sex==1 & cat==4


* For those with three children of two different sexes, we can assign the inheritance in one case
replace cat=5 if antal_lotter_barn==3 & (kon_barn1=="kvinna" & kon_barn2=="man" & kon_barn3=="kvinna") & cat==.
replace inheritance=(lott_barn2-skatt_barn2) if kon_barn2=="man" & sex==1 & cat==5



keep Lopnrgems_barn dy inheritance

destring Lopnrgems_barn, replace
rename Lopnrgems_barn lopnrgems

drop if inheritance==.

bysort lopnrgems (dy): gen order=_n

* There's one strange observation that has two dead fathers. The second and third inheritances are only one year apart, so we treat them as one and set the timing to the first (and bigger) of the two.
egen inh_tot=total(inheritance) if lopnrgems==11252 & order>1
replace inheritance=inh_tot if lopnrgems==11252 & order==2
drop if lopnrgems==11252 & order==3
drop inh_tot

rename inheritance inh

drop order

* Adjust for inflation
rename dy year
merge m:1 year using "data\cpi.dta", keep(match master) nogenerate
rename year dy

replace inh=inh*(4434/cpi)

tempfile inh2
save `inh2'

preserve

	keep lopnrgems dy inh
	save "data\workdata\inheritances_2ndGen_ind.dta", replace

restore

* Drop inheritances received after we observe wealth
drop if dy>1991

duplicates tag lopnrgems, gen(dups)
gen one=(dups==0)
drop dups

* Create death order variable
sort lopnrgems dy
by lopnrgems: egen do = seq()

drop cpi

reshape wide inh dy one, i(lopnrgems) j(do)
drop one2
rename one1 one

egen inh=rowtotal(inh1 inh2)
egen dy=rowmean(dy1 dy2)

rename (*1 *2) (*_1st *_2nd)


save "data\workdata\inheritances_2ndGen.dta", replace

clear
