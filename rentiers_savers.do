capture program drop inh_share
program inh_share, rclass
	preserve

	args rate

	scalar rate = `rate'

	* Capitalize inheritances up to 1991
	gen inh_1st_cap = inh_1st * (exp(rate*(1991 - dy_1st)))

	gen inh_2nd_cap = inh_2nd * (exp(rate*(1991 - dy_2nd)))

	* Calculate total capitalized inheritance
	egen inh_cap = rowtotal(inh_1st_cap inh_2nd_cap)


	* Merge on wealth information
	qui: merge 1:1 lopnrgems using "data\workdata\tax_wealth_2ndGen.dta", nogenerate keep(match)

	* Drop those with missing wealth
	keep if w_91 !=.

	* Censor at zero (as in Piketty et al)
	replace w_91 = 0 if w_91 < 0
	replace inh_cap = 0 if inh_cap < 0



	* See who are rentiers
	gen rentier = (inh_cap > w_91 & inh_cap != .)

	* Get share rentiers (rho)
	qui: sum rentier

	scalar share_rentiers = r(mean)

	return scalar n = r(N)

	return scalar share_rentiers = share_rentiers

	* Calculate total wealth by rentier status
	qui: total w_91, over(rentier)

	matrix tot = e(b)

	scalar w_savers = tot[1, 1]
	scalar w_rentiers = tot[1, 2]
	scalar w_tot = w_savers + w_rentiers

	* Calculate total bequests by rentier status
	qui: total inh_cap, over(rentier)

	matrix tot = e(b)

	scalar b_savers = tot[1, 1]
	scalar b_rentiers = tot[1, 2]
	scalar b_tot = b_savers + b_rentiers

	* Calculate rentier wealth share (pi)
	return scalar rentiers_wealth_share = w_rentiers / (w_rentiers + w_savers)

	
	* Calculate share of wealth that is due to inheritance (phi)
	return scalar piketty = (w_rentiers + b_savers) / w_tot


	* Calculate Modigliani and Kotlikoff-Summers inheritance shares

	qui: total(w_91)

	matrix total_wealth = e(b)
	scalar total_wealth = total_wealth[1, 1]

	qui: total(inh)

	matrix total_inheritance = e(b)
	scalar total_inheritance = total_inheritance[1, 1]

	qui: total(inh_cap)

	matrix total_inheritance_cap = e(b)
	scalar total_inheritance_cap = total_inheritance_cap[1, 1]


	return scalar modigliani = total_inheritance / total_wealth

	return scalar kotlikoff = total_inheritance_cap / total_wealth

	restore

end

use "data\workdata\inheritances_2ndGen.dta", clear

* Keep only estimation sample
merge 1:1 lopnrgems using "data\workdata\inh_sample.dta", nogenerate keep(match)

* Only those who have received both inheritances
keep if inh_2nd != .

keep if both
*-------

* Table 
inh_share -0.03
matrix results_n3 = [r(modigliani), r(kotlikoff), r(piketty)]

inh_share 0
matrix results_0 = [r(modigliani), r(kotlikoff), r(piketty)]

inh_share 0.03
matrix results_3 = [r(modigliani), r(kotlikoff), r(piketty)]

matrix n = r(n)

matrix results = [results_3 \ results_0 \ results_n3 \ n, n, n]

matrix colnames results = Modigliani "Kotlikoff-Summers" "PPVR"
matrix rownames results = "3%" "0%" "-3%" "N"

* Table 6
estout matrix(results, fmt(3)), mlabels("") modelwidth(22) title("Inheritance share of total wealth")
