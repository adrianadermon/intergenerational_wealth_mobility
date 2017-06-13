* This file creates a basic dataset with all the variables we will want further on
*---------------------------------------------------------------------------------

set more off

tempfile malmext malmred ///
l85 l86 l87 l88 l89 l90 l91 l92 l93 l94 l95 l96 l97 l98 l99 l00 l01 l02 l03 l04 l05 l06 l07 l08 ///
i68 i71 i73 i76 i79 i82 i85 ///
louise85 louise90 sexL motherby mothersex parentssex parentsby 1stgenby sy09

* We're going to create an extended version of the malmo base data file

use "data\malmorelationer.dta", clear
drop v _merge
save `malmext'


* We merge on income data from louise for 1985-2008
*-----------------------------------------------------------

* 1985-1990
foreach i of numlist 85/90 {
	use "data\louise\louise_19`i'.dta", clear
	rename *, lower

	keep lopnrgems loneink fink
	rename (loneink fink) =`i'
	destring lopnrgems, replace

	save `l`i''

	use `malmext', clear
	merge m:1 lopnrgems using `l`i'', nogenerate keep(match master)
	save `malmext', replace
}

* 1991-1999
foreach i of numlist 91/99 {
	use "data\louise\louise_19`i'.dta", clear
	rename *, lower

	keep lopnrgems loneink fink pasnar
	rename (loneink fink pasnar) =`i'
	destring lopnrgems, replace

	save `l`i''

	use `malmext', clear
	merge m:1 lopnrgems using `l`i'', nogenerate keep(match master)
	save `malmext', replace
}

* 2000-2003
foreach i of numlist 0/3 {
	use "data\louise\louise_200`i'.dta", clear
	rename *, lower

	keep lopnrgems loneink fink pasnar
	rename (loneink fink pasnar) =0`i'
	destring lopnrgems, replace

	save `l0`i''

	use `malmext', clear
	merge m:1 lopnrgems using `l0`i'', nogenerate keep(match master)
	save `malmext', replace
}

*2004
use "data\louise\louise_2004.dta", clear
	rename *, lower

	keep lopnrgems loneink inkfnetto pasnar
	rename (loneink inkfnetto pasnar) =04
	destring lopnrgems, replace
save `l04'

use `malmext', clear
	merge m:1 lopnrgems using `l04', nogenerate keep(match master)
save `malmext', replace


*2005-2008
foreach i of numlist 5/8 {
	use "data\louise\louise_200`i'.dta", clear
	rename *, lower

	keep lopnrgems loneink inkfnetto
	rename (loneink inkfnetto) =0`i'
	destring lopnrgems, replace

	save `l0`i''

	use `malmext', clear
	merge m:1 lopnrgems using `l0`i'', nogenerate keep(match master)
	save `malmext', replace
}


* We merge on further income variables, along with sex, birth and death year, and intelligence from the Malmo file
*-----------------------------------------------------------------------------------------------------------------

use "data\malmobas_lopnr.dta", clear
	keep  mid_scb lopnr var2-var4 var21 var22 var34 var36 var37 var39 var41-var48 var52 var63 var81 var548 var550 var551 var554 var556-var559 var561 var562 var564 var565 var567 var688-var693
	rename lopnr lopnrgems
	destring lopnrgems, replace
save `malmred'


use `malmext', clear
	merge m:1 lopnrgems mid_scb using `malmred', nogenerate  keep(match master)
	rename var4 sexM
save `malmext', replace


* We merge on further income data for some years between 1968 and 1985
*-----------------------------------------------------------

foreach i of numlist 68 71 73 76 79 82 85 {
	use "data\incomes\iot_19`i'.dta", clear
	rename *, lower

	keep  lopnrgems *intj *inro

	rename (*intj *inro) =`i'
	destring lopnrgems, replace

	save `i`i''
	
	use `malmext', clear
	merge m:1 lopnrgems using `i`i'', nogenerate keep(match master)
	save `malmext', replace
}


* We add year of birth and years of schooling from Louise 85
*-----------------------------------------------------------

use "data\louise\louise_1985.dta", clear
	rename *, lower

	keep lopnrgems fodar hutbsun
	destring lopnrgems fodar, replace
	rename fodar byL85

	gen syear=real(substr(hutbsun,-4,1))
	recode syear (1=7) (2=9) (3=11) (4=12) (5=14) (6=15.5) (7=19) 
	replace syear=9.5 if real(hutbsun)>=2300 & real(hutbsun)<=2399
	
	label variable syear "Years of schooling, 1985"

	drop *hutbsun
save `louise85'


use `malmext', clear
	merge m:1 lopnrgems using `louise85', nogenerate keep(match master)

	/* We impute missing years of schooling using a 1964 survey question.
	This fills in 148 missing observations, all but one of which are for the index generation or their spouses. 
	The final observation is for an early-born parent of the 4th generation. */
	reg syear i.var81
	predict syearimp, xb
	replace syear=syearimp if syear==.
	drop syearimp
save `malmext', replace


* We add marital status from Louise 90
*-----------------------------------------------------------

use "data\louise\louise_1990.dta", clear
	rename *, lower

	keep lopnrgems civil
	rename civil maritalstatusL90

	destring lopnrgems, replace
save `louise90'


use `malmext', clear
	merge m:1 lopnrgems using `louise90', nogenerate keep(match master)
save `malmext', replace


* We pick out sex information from louise 1985, to fill out missing values
*-----------------------------------------------------------

use "data\louise\louise_1985.dta", clear
	rename *, lower

	keep lopnrgems kon

	destring lopnrgems kon, replace

	rename kon sexL
save `sexL'

use `malmext', clear
	merge m:1 lopnrgems using `sexL', nogenerate keep(match master)
save `malmext', replace


* We add sex information using parent identifiers in the relations file
*------------------------------------------------------------------------

* Get sex for mothers
use "data\malmorelationer.dta", clear
	keep lopnrgemsmor

	gen sexP=2

	rename lopnrgemsmor lopnrgems

	duplicates drop
save `mothersex'


* Get sex for fathers
use "data\malmorelationer.dta", clear
	keep lopnrgemsfar

	gen sexP=1

	rename lopnrgemsfar lopnrgems

	duplicates drop

* Append to get a sex file for men and women
	append using `mothersex'

	drop if missing(lopnrgems)
save `parentssex'


use `malmext', clear
	merge m:1 lopnrgems using `parentssex', nogenerate keep(match master)

	* This gives 10,495 observations
	gen sex=kon
	* This adds 1,601 observations
	replace sex=sexM if missing(sex)
	* This adds 937 observations
	replace sex=sexL if missing(sex)
	* This adds 199 observations
	replace sex=sexP if missing(sex)
	* This leaves us with 57 missing values on sex, all on children of the index generation

	drop sexM sexL sexP kon
save `malmext', replace


* We add year of birth using parent identifiers in the relations file
*-------------------------------------------------------------------- 

* Get birth year for mothers
use "data\malmorelationer.dta", clear
	keep fodelsearmor lopnrgemsmor
	rename lopnrgemsmor lopnrgems
save `motherby'


* Get birth year for fathers
use "data\malmorelationer.dta", clear
	keep fodelsearfar lopnrgemsfar
	rename lopnrgemsfar lopnrgems

	append using `motherby'

	drop if missing(lopnrgems)

	gen byP=fodelsearfar

	replace byP=fodelsearmor if missing(byP)

	drop fodelsearfar fodelsearmor

	duplicates drop
save `parentsby'


use `malmext', clear
	merge m:1 lopnrgems using `parentsby', nogenerate keep(match master)

	gen byM=var2+1920
	replace byM=1930 if byM==1920
	drop var2
	
	* This gives 10,495 observations
	gen by=fodelsear
	* This adds 2,337 observations 
	replace by=byL85 if missing(by)
	* This adds 307 observations
	replace by=byP if missing(by)
	* This adds 93 observations
	replace by=byM if missing(by)
	* This leaves us with 57 missing values, all for the children of the index generation

	drop fodelsear byP byL85 byM


* Rename some variables
rename (var3 var52 var63) (deathyear iq1938 iq1948)

save `malmext', replace


* Pick out birth year and death year for parents of the index generation
use "data\bouppteckningar.dta", clear
rename *, lower

gen fatherby = substr(far_f_dd,1,4)
gen motherby = substr(mor_f_dd,1,4)

destring fatherby motherby, replace
replace motherby=1894 if motherby==1994
replace fatherby=1908 if fatherby==801

gen fatherdy = substr(far_d_d,1,4)
gen motherdy = substr(mor_d_d,1,4)

replace fatherdy="." if fatherdy=="ev 1"
replace motherdy="." if motherdy=="(197"

destring fatherdy motherdy, replace


rename f_r_ldrar_skilda divorced

keep mid_scb fatherby motherby divorced fatherdy motherdy

sort mid_scb fatherdy motherdy

egen tag=tag(mid_scb)

keep if tag==1

drop tag

save `1stgenby'


use `malmext', clear
merge m:1 mid_scb using `1stgenby', nogenerate keep(match master)

* This leaves 115 missing values
replace fatherby=. if generation!="Indexgen"
* This leaves 53 missing values
replace motherby=. if generation!="Indexgen"

replace fatherdy=. if generation!="Indexgen"
replace motherdy=. if generation!="Indexgen"

save `malmext', replace



* Add years of schooling from 2009
use "data\ureg_sunkod_2009.dta", clear
rename *, lower

gen rhutbsun=real(sun2000niva_old)
recode rhutbsun 0=.
gen edlev=int((rhutbsun-((int(rhutbsun/10000))*10000))/1000)
gen syear=edlev
recode syear 1=7 2=9 3=11 4=12 5=14 6=15.5 7=19 
replace syear=9.5 if rhutbsun>=02300 & rhutbsun<=02399

destring sun2000niva, replace
gen sun=mod(int(sun2000niva/10), 100)
gen sy=.
replace sy=7 if sun==10
replace sy=7 if sun==00
replace sy=9 if sun==20
replace sy=10 if sun==31
replace sy=11 if sun==32
replace sy=12 if sun==33
replace sy=13 if sun==41
replace sy=14 if sun==52
replace sy=15 if sun==53
replace sy=16 if sun==54
replace sy=17 if sun==55
replace sy=18 if sun==62
replace sy=20 if sun==64
replace sy=17 if sun==60
replace sy=9.5 if sun2000niva==204
replace sy=13 if sun2000niva==336
keep lopnrgems sy
label variable sy "Years of schooling, 2009"

destring lopnrgems, replace

save `sy09'

* Years of schooling from 2009 is used where Louise 1985 data is missing
use `malmext', clear

merge m:1 lopnrgems using `sy09', nogenerate keep(match master)

* This adds 4,085 observations
replace syear=sy if syear==.
* This changes 2,486 observations
replace syear=sy if sy>syear & sy!=.
* This leaves 1,449 missing observations, mostly for the 4th gen

drop sy
label variable syear "Years of schooling, mainly 1985 with additions from 2009"


* Generate years of schooling for fathers

gen fathersyear=5 if var21==1 & fatherby<1868
replace fathersyear=5 if var21==2 & fatherby<1868
replace fathersyear=6 if var21==3 & fatherby<1868

replace fathersyear=6 if var21==1 & fatherby<1901 & fatherby>1867
replace fathersyear=6 if var21==2 & fatherby<1901 & fatherby>1867
replace fathersyear=7 if var21==3 & fatherby<1901 & fatherby>1867
replace fathersyear=9 if var21==4 & fatherby<1901 & fatherby>1867
replace fathersyear=10 if var21==5 & fatherby<1901 & fatherby>1867
replace fathersyear=14 if var21==6 & fatherby<1901 & fatherby>1867

replace fathersyear=7 if var21==1 & fatherby>1900
replace fathersyear=7 if var21==2 & fatherby>1900
replace fathersyear=8 if var21==3 & fatherby>1900
replace fathersyear=9 if var21==4 & fatherby>1900
replace fathersyear=10 if var21==5 & fatherby>1900
replace fathersyear=14 if var21==6 & fatherby>1900

replace fathersyear=6 if var21==1 & fatherby==.
replace fathersyear=6 if var21==2 & fatherby==.
replace fathersyear=7 if var21==3 & fatherby==.
label variable fathersyear "Father's years of schooling 1938"

* This leaves 62 missing observations

drop var21

save "data\workdata\malmorelationerextended.dta", replace
