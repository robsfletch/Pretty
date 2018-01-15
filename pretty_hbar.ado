program pretty_hbar
	version 13
	syntax varlist [if] [in] [, save(str) scheme(str) name(str) NODRAW ///
					  xtitle(str) calc(str) *]

	marksample touse

	local wc : word count `varlist'
	matrix Probs = J(`wc',3, 0)

	if ("`calc'" == "") {
		local calc = "mean"
	}

	local counter = 1
	foreach v of varlist `varlist' {
		qui sum `v' if `touse'
		local avg = `r(`calc')'
		matrix Probs[`counter',1] = `counter'
		matrix Probs[`counter',2] = `avg'
		local ++counter
	}

	mata : st_matrix("Probs", sort(st_matrix("Probs"), 2))

	local counter = 1
	foreach v of varlist `varlist' {
		matrix Probs[`counter',3] = `wc' - `counter' + 1
		local v_ind = Probs[`counter',1]
		local rowvar : word `v_ind' of `varlist'
		local rowname : variable label `rowvar'
		local rowname = subinstr("`rowname'", " ", "_", .)
		matrcrename Probs row `counter' "`rowname'"
		local ++counter
	}

	svmat2 Probs, rnames(Probs_gr)

	replace Probs1 = . if Probs2 == 0
	replace Probs3 = . if Probs2 == 0
	replace Probs_gr = "" if Probs2 == 0
	replace Probs2 = . if Probs2 == 0

	replace Probs_gr = subinstr(Probs_gr, "_", " ", .)
	labmask Probs3, values(Probs_gr)
	splitvallabels Probs3
	local new_label = `"`r(relabel)'"'

	******************
	** SCHEME SETUP **
	******************
	** Set up my personal scheme as the default
	if "`scheme'" == "" local scheme "s2personal"

	********************
	** PLOT THE GRAPH **
	********************
	splitvallabels Probs3
	graph twoway bar Probs2 Probs3, scheme(pretty1) ///
		horizontal ylabel(`new_label', angle(0) nogrid) ///
		xtitle("") ytitle("") xlabel(#10 0,grid) ///
		 name("`name'", replace) `nodraw' `options'


	******************
	** EXPORT GRAPH **
	******************
	if ("`save'" != "") {
		graph export "`save'", replace fontface(Helvetica-Light)
	}

	drop Probs*
end
