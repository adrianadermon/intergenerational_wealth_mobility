capture program drop transprog
program transprog
	syntax, w(name) gen(numlist) [b(string)]
	if "`b'" == "" local b "b"
	local i=`gen' 
		gen ln_`w'`i'=ln(`w'`i')
		gen ihs_`w'`i' = ln(`w'`i' + sqrt(`w'`i'^2 + 1))

		* Rank wealth within groups with at least 100 observations
		count if `w'`i'!=.
		if r(N)>=100 {
			local groups=round(r(N)/100)
			egen `b'g_`w'`i'=cut(`b'y`i') if `w'`i'!=., group(`groups') icodes
			bysort `b'g_`w'`i': egen rank`i'=rank(`w'`i')
			bysort `b'g_`w'`i': egen n`i'=count(`w'`i')
			gen rank_`w'`i'=(rank`i'-0.5)/n`i'
		}
		else {
			gen rank_`w'`i'=.
		}

		capture drop rank`i' n`i'
end
