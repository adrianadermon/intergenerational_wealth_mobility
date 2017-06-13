tempfile main_incomes spouse_incomes

use "data\workdata\malmorelationerextended.dta", clear


* We rescale and sum income data from Louise and the tax register

rename (inro* intj*) (ainro* aintj*)

* Rescale incomes for 1979-1985
foreach i of numlist 79 82 85 {
	replace aintj`i' = aintj`i'*100
	replace ainro`i' = ainro`i'*100
	label variable aintj`i' ""
	label variable ainro`i' ""
}

* Calculate total incomes for 1968-1985
foreach i of numlist 68 71 73 76 79 82 85 {
	gen y19`i' = aintj`i' + ainro`i'
}


* Rescale labor incomes for 1990-1999
foreach i of numlist 90/99 {
	replace loneink`i' = loneink`i'*100
	label variable loneink`i' "Kontant bruttolön, Louise"
}

* Rescale labor incomes for 2000-2008
foreach i of numlist 0/8 {
	replace loneink0`i' = loneink0`i'*100
	label variable loneink0`i' "Kontant bruttolön, Louise"
}


* Rescale active business incomes for 1990-1999
foreach i of numlist 90/99 {
	replace fink`i' = fink`i'*100
	label variable fink`i' "Inkomst av aktiv näringsverksamhet, Louise"
}

* Rescale active business incomes for 2000-2003
foreach i of numlist 0/3 {
	replace fink0`i' = fink0`i'*100
	label variable fink0`i' "Inkomst av aktiv näringsverksamhet, Louise"
}


* Rescale passive business incomes for 1991-1999
foreach i of numlist 91/99 {
	replace pasnar`i' = pasnar`i'*100
	label variable pasnar`i' "Inkomst av passiv näringsverksamhet, Louise"
}

* Rescale passive business incomes for 2000-2004
foreach i of numlist 0/4 {
	replace pasnar0`i' = pasnar0`i'*100
	label variable pasnar0`i' "Inkomst av passiv näringsverksamhet, Louise"
}


* Rescale business incomes for 2004-2008
foreach i of numlist 4/8 {
	replace inkfnetto0`i' = inkfnetto0`i'*100
	label variable inkfnetto0`i' "Nettoinkomst av näringsverksamhet, Louise"
}

* We skip Louise incomes for 1985, since we have that data from the tax register
gen y1985L = loneink85 + fink85

* Calculate total incomes for 1986-1990
foreach i of numlist 86/90 {
	gen y19`i' = loneink`i' + fink`i'
}

* Calculate total incomes for 1991-1999
foreach i of numlist 91/99 {
	gen y19`i' = loneink`i' + fink`i' + pasnar`i'
}

* Calculate total incomes for 2000-2003
foreach i of numlist 0/3 {
	gen y200`i' = loneink0`i' + fink0`i' + pasnar0`i'
}

* Calculate total incomes for 2004
gen y2004 =  loneink04 +  pasnar04 +  inkfnetto04

* Calculate total incomes for 2005-2008
foreach i of numlist 5/8 {
	gen y200`i' = loneink0`i' + inkfnetto0`i'
}


* Drop negative incomes (should we really drop them rather than setting them as missing values?)
drop if y2004<0
drop if y2005<0
drop if y2006<0
drop if y2007<0
drop if y2008<0

drop aintj* ainro* loneink* fink* pasnar* inkfnetto*


* We rename and rescale the Malmo data income variables
*------------------------------------------------------
rename var34 fathery1929
rename var36 mothery1929
rename var37 famy1929
replace fathery1929=fathery1929*10
replace mothery1929=mothery1929*10
replace famy1929=famy1929*10

rename var39 fathery1933
rename var41 mothery1933
rename var42 famy1933
replace fathery1933=fathery1933*10
replace mothery1933=mothery1933*10
replace famy1933=famy1933*10

rename var43 famy1937
rename var44 fathery1937
rename var45 mothery1937
replace fathery1937=fathery1937*1000
replace mothery1937=mothery1937*1000

rename var46 fathery1938
rename var47 mothery1938
rename var48 famy1938

rename var688 fathery1937b
rename var689 mothery1937b
rename var690 famy1937b
replace fathery1937b=fathery1937b*10
replace mothery1937b=mothery1937b*10
replace famy1937b=famy1937b*10

rename var691 fathery1942
rename var692 mothery1942
rename var693 famy1942
replace fathery1942=fathery1942*10
replace mothery1942=mothery1942*10
replace famy1942=famy1942*10

replace fathery1937=fathery1937b if fathery1937==.
replace fathery1937=fathery1937b if fathery1937==0

* We use family income to back out spouse's incomes for the index generation
*---------------------------------------------------------------------------
rename var548 y1948M
rename var550 famy1948M
rename var551 y1953M
rename var554 y1958M
rename var556 famy1958M
rename var557 y1963M
rename var558 famy1963M
rename var559 y1968M
rename var561 famy1968M
rename var562 y1969M
rename var564 famy1969M
rename var565 y1971M
rename var567 famy1971M

foreach i of varlist y*M famy*M {
	replace `i'=`i'*1000
}

save `main_incomes'


* We subtract the index persons income from family income to get spouse's income
foreach i of numlist 48 58 63 68 69 71 {
	gen spousey19`i'M = famy19`i'M - y19`i'M if famy19`i'M>0 & generation=="Indexgen"
	replace spousey19`i'M = . if spousey19`i'M<0
}

* Pick out spouse incomes for the index generation
keep if generation=="Indexgen"
keep mid_scb spousey*

save `spouse_incomes'


use `main_incomes', clear

* Merge spouse incomes back on using the family identifier
merge m:1 mid_scb using `spouse_incomes', nogenerate keep(match master)

* Fill in income for spouses of the index generation
foreach i of numlist 48 58 63 68 69 71 {
	replace y19`i'M = spousey19`i'M if y19`i'M==. & generation=="Ejindexgen"
}

drop spousey*M famy*M


/* We fill in missing observations in the tax register income data with data from the Malmö data.
The values for the overlapping set of observations are not the same, with correlations of .75 for 1968 and 
.90 for 1971, but it is not the case that one measure is always higher than the other. 
This is probably because they are defined in slightly different ways. 
 */
* This adds 1,015 observations
replace y1968=y1968M if missing(y1968)
* This adds 35 observations
replace y1971=y1971M if missing(y1971)

drop y1968M y1971M

rename y*M y*

save "data\workdata\malmorelationerextended_incomes.dta", replace
