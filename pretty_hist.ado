program pretty_hist
	version 13
	syntax varlist [if] [in] [, save(str) scheme(str) ///
					  axistitle(str) name(str) angle(passthru)   ///
					  xlist(str) HORIZONTAL ALT CDF *]



	***********************
	** Observation Count **
	***********************
	** Include the number of observations as a subtitle on
	** the graphs
	if ("`if'" == "") {
		qui count if (`varlist' != .)
	}
	else {
		qui count `if' & (`varlist' != .)
	}
	local sub = "(N = `r(N)')"

	******************
	** SCHEME SETUP **
	******************
	** Set up my personal scheme as the default
	if "`scheme'" == "" local scheme "s2personal"

	********************
	** PLOT THE GRAPH **
	********************

	if ("`cdf'" == "") {
		twoway hist `varlist' `if', frac scheme("`scheme'") ///
			xtitle("`axistitle'") ytitle("") ///
			ymtick(#10) name("`name'", replace) `nodraw' ///
			subtitle("`sub'") `options'
	}
	else {
		capture su cum_`varlist', meanonly
		if _rc == 0 {
			drop cum_`varlist'
		}

		cumul `varlist' `if', gen(cum_`varlist')
		sort cum_`varlist'

		twoway (hist `varlist' `if', frac yaxis(1)) ///
			(line cum_`varlist' `varlist' `if', yaxis(2)),  ///
			scheme("`scheme'") ///
			xlabel(`xlist', valuelabel `alt' `angle') ///
			xtitle("`axistitle'") ytitle("" , axis(1)) ytitle("" , axis(2)) ///
			ymtick(#10) name("`name'", replace) `nodraw' ///
			subtitle("`sub'") `options'
	}

	******************
	** EXPORT GRAPH **
	******************
	if ("`save'" != "") {
		graph export "`save'", replace fontface(Helvetica-Light)
	}

end
