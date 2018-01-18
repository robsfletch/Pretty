program pretty_hist_horiz
	version 13
	syntax varlist [if] [in] [, save(str) scheme(str) ///
					  axistitle(str) name(str) angle(passthru)   ///
					  xlist(str) SORT *]

	***********************
	** Label Points List **
	***********************
	if ("`xlist'" == "" ) {
		qui levelsof `varlist' `if'
		local xlist = "`r(levels)'"
	}


	***********************
	** Observation Count **
	***********************
	** Onclude the number of observations as a subtitle on
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


	*******************************************
	** CLEAN VARIABLE FOR PRETTY PRINTING **
	*******************************************

	tempvar temp_recode
	gen `temp_recode' = `varlist'
	local lbl : value label `varlist'
	label value `temp_recode' `lbl'

	tempvar temp_val x_temp
	twoway__histogram_gen `temp_recode' , discrete density gen(`temp_val' `x_temp', replace)
	if ("`sort'" != "") {
		gsort + `temp_val'
	}
	qui count if `x_temp' != .
	local num_recount = `r(N)'


	************************
	** Change base values **
	************************

	qui sum `temp_recode'
	local upper = `r(max)'

	local new = `x_temp'[1] + `upper'
	local old = `x_temp'[1]
	local val_lbl : label (`varlist') `old'
	label define temp_lbl `new' "`val_lbl'", replace
	recode `temp_recode' (`old'=`new')

	foreach i of numlist 2/`num_recount' {
		local new = `x_temp'[`i'] + `upper'
		local old = `x_temp'[`i']
		local val_lbl : label (`varlist') `old'
		label define temp_lbl `new' "`val_lbl'", add
		recode `temp_recode' (`old'=`new')
	}

	label values `temp_recode' temp_lbl

	local old = `x_temp'[1] + `upper'
	local val_lbl : label (`temp_recode') `old'
	label define temp_lbl2 1 "`val_lbl'", replace
	recode `temp_recode' (`old'=1)

	foreach i of numlist 2/`num_recount' {
		local old = `x_temp'[`i'] + `upper'
		local val_lbl : label (`temp_recode') `old'
		label define temp_lbl2 `i' "`val_lbl'", add
		recode `temp_recode' (`old'=`i')
	}
	label values `temp_recode' temp_lbl2

	splitvallabels `temp_recode', nobreak length(25)
	local new_label = `"`r(relabel)'"'

	********************
	** PLOT THE GRAPH **
	********************

	qui levelsof `temp_recode'
	local y_list = "`r(levels)'"

	twoway (hist `temp_recode' `if', discrete frac horizontal), ///
	scheme("`scheme'") ///
	yscale(reverse) xlabel(, grid) ///
	ylabel(`new_label', angle(0) nogrid) ///
	ytitle("`axistitle'") xtitle("") ///
	xmtick(#10) name("`name'", replace) `nodraw' ///
	subtitle("`sub'") `options'

	******************
	** EXPORT GRAPH **
	******************
	if ("`save'" != "") {
		graph export "`save'", replace fontface(Helvetica-Light)
	}

end
