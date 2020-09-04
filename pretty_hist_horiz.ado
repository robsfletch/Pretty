program pretty_hist_horiz
	version 13
	syntax varlist [if] [in] [, save(str) scheme(str) ///
					  axistitle(str) name(str) angle(passthru)   ///
					  xlist(str) SORT OBSCOUNT *]

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
	if ("`obscount'" != "") {
		local sub = `"subtitle("(N = `r(N)')")"'
	}


	******************
	** SCHEME SETUP **
	******************
	** Set up my personal scheme as the default
	if "`scheme'" == "" local scheme "pretty1"

*******************************************************************************
** CLEAN VARIABLE FOR PRETTY PRINTING
*******************************************************************************
	// Generate a Recode Variable
	tempvar temp_recode
	gen `temp_recode' = `varlist'
	local lbl : value label `varlist'
	label value `temp_recode' `lbl'

	// Create binid (x_temp) and height variables (temp_val)
	tempvar temp_val x_temp
	twoway__histogram_gen `temp_recode' , discrete density gen(`temp_val' `x_temp', replace)
	return list

	// Sort by height of bins
	if ("`sort'" != "") {
		gsort + `temp_val'
	}

	// Count the number of bins generated
	qui count if `x_temp' != .
	local num_recount = `r(N)'

*******************************************************************************
** Change Values so there aren't any gaps in between numbers
*******************************************************************************
	// Find the highest bin so as not to overlap with already assigned
	// bins during recode
	qui sum `temp_recode'
	local upper = `r(max)'

	// Reassign bins one by one into the new range before moving them down
	local new = `upper' + 1
	local old = `x_temp'[1]
	local val_lbl : label (`varlist') `old'
	label define temp_lbl `new' "`val_lbl'", replace
	recode `temp_recode' (`old'=`new')

	foreach i of numlist 2/`num_recount' {
		local new = `x_temp'[`i'] + `upper' - `x_temp'[1] + 1
		local old = `x_temp'[`i']
		local val_lbl : label (`varlist') `old'
		label define temp_lbl `new' "`val_lbl'", add
		recode `temp_recode' (`old'=`new')
	}
	label values `temp_recode' temp_lbl

	// Reassign them down after sorting and removing gaps
	local old = `upper' + 1
	local val_lbl : label (`temp_recode') `old'
	label define temp_lbl2 1 "`val_lbl'", replace
	recode `temp_recode' (`old'=1)

	foreach i of numlist 2/`num_recount' {
		local old = (`x_temp'[`i'] - `x_temp'[1]) + `upper'  + 1
		local val_lbl : label (`temp_recode') `old'
		label define temp_lbl2 `i' "`val_lbl'", add
		recode `temp_recode' (`old'=`i')
	}
	label values `temp_recode' temp_lbl2

*******************************************************************************
** PLOT THE GRAPH
*******************************************************************************
	splitvallabels `temp_recode', nobreak length(25)
	local new_label = `"`r(relabel)'"'

	qui levelsof `temp_recode'
	local y_list = "`r(levels)'"

	twoway (hist `temp_recode' `if', discrete width(1) frac horizontal), ///
	scheme("`scheme'") ///
	yscale(reverse) xlabel(, grid) ///
	ylabel(`new_label', angle(0) nogrid) ///
	ytitle("`axistitle'") xtitle("") ///
	name("`name'", replace) `nodraw' ///
	`sub' `options'

*******************************************************************************
** EXPORT GRAPH
*******************************************************************************

	if ("`save'" != "") {
		graph export "`save'", replace
	}

end
