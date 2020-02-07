program pretty_histogram, rclass
	version 14
	syntax varlist(min=4 max=4 numeric) [if] [in] ///
		[,					///
			refusal(int -555) ///
			na(int -777) ///
			unsure(int -888) ///
			other(int -999) ///
			zeros(int 0) ///
			CDF ///
			ytitle(str) ///
			ymtick(str) ///
			DISCrete			///
			BIN(numlist max=1 >0 integer)	/// number of bins
			Width(numlist max=1 >0)		/// width of bins
			START(numlist max=1)		/// first bin position
			DENsity FRACtion FREQuency	/// height type
			PERCENT				///
			RETurn				/// save results in r()
		 	xlogbase(real 1)	///
			ylogbase(real 1)	///
			\ *	///
		]


*******************************************************************************
** Map incoming variables and mark observation to include
*******************************************************************************
	// Map the incoming vars to their appropraite use
	gettoken use_flag varlist : varlist
	gettoken new_yvar varlist : varlist
	gettoken new_xvar varlist : varlist
	gettoken xvar varlist : varlist

	// Set the use_flag using the touse conditions from any if statements
	marksample touse
	qui replace `use_flag' = `touse'

	// Create a flag for variables to use in making hist bins that ignores
	// coded values such as unsure, refusal, other, or NA
	tempvar use_flag_2
	gen `use_flag_2' = `use_flag'
	qui replace `use_flag_2' = 0 if inlist(`unsure', `xvar')
	qui replace `use_flag_2' = 0 if inlist(`refusal', `xvar')
	qui replace `use_flag_2' = 0 if inlist(`other', `xvar')
	qui replace `use_flag_2' = 0 if inlist(`na', `xvar')

*******************************************************************************
** X Variable Clean-Up
*******************************************************************************
	if `xlogbase' == 1 {
		_linear_axis `xvar' `new_yvar' `use_flag' `use_flag_2' , ///
			bin(`bin') width(`width') start(`start') `discrete' ///
			`density' `fraction' `frequency'

		local xlabel = r(list)
		local width = r(width)
	}
	else {
		_log_axis `xvar' `new_yvar' `use_flag_2'  , logbase(`xlogbase')

		local xlabel = r(list)
		local width = 1
	}

	qui sum `new_yvar'
	local end = r(max)

	_add_hist_extras `new_yvar' `touse' `xvar' , ///
		refusal(`refusal') ///
		na(`na') ///
		unsure(`unsure') ///
		other(`other') ///
		zeros(`zeros') ///
		end(`end') ///
		width(`width') ///
		xlist(`"`xlabel'"')

	local xlist = r(xlist)
********************************************************************************
** SETUP PLOTTING STRING
********************************************************************************
	if "`ymtick'" == "" {
		local ymtick = "#10"
	}

 	local Cap_Var = strproper("`xvar'")

	if (`ylogbase' == 1) {
		if ("`cdf'" == "") {
			local edited_string =  "hist `new_yvar' if `use_flag', " + ///
				" `density' `fraction' `frequency' ytitle(`ytitle') ymtick(`ymtick') discrete " + ///
				`" xlabel(`xlist' , angle(45)) xtitle("`Cap_Var'") `options'"'
		}
		** Add in the option of superimposing a cdf plot on the histogram plot
		else {
			tempvar passthru
			cumul `new_yvar' if `use_flag', gen(`passthru')
			replace `new_xvar' = `passthru'
			sort `new_xvar'

			local edited_string =  "hist `new_yvar' if `use_flag', " + ///
				" `density' `fraction' `frequency' ytitle(`ytitle') yaxis(1) ymtick(`ymtick') discrete " + ///
				`" xlabel(`xlist' , angle(45)) xtitle("`Cap_Var'") `options') "' + ///
				"(line `new_xvar' `new_yvar' if `use_flag', " + ///
				`" yaxis(2) xlabel(`xlist' , angle(45)) ymtick(`ymtick')  `options'"'
		}
	}
	else {
		tempvar passthru1 passthru2
		twoway__histogram_gen  `new_yvar', ///
			gen(`passthru1' `passthru2') `discrete' `density' `fraction' `frequency'

		replace `new_yvar' = `passthru1'
		replace `new_xvar' = `passthru2'

		if ("`ytitle'" == "") {
			if ("`fraction'" != "") {
				local ytitle = "Fraction"
			}
			else if ("`frequency'" != "") {
				local ytitle = "Frequency"
			}
			else if ("`percent'" != "") {
				local ytitle = "Percent"
			}
			else {
				local ytitle = "Density"
			}
		}

		local new_width = `width'*.9
		if ("`cdf'" == "") {
			local edited_string =  "bar `new_yvar' `new_xvar' if `use_flag', " + ///
				" ytitle(`ytitle') yscale(log) barwidth(`new_width') " + ///
				`" xlabel(`xlist' , angle(45)) xtitle("`Cap_Var'") `options'"'
		}
		** Add in the option of superimposing a cdf plot on the histogram plot
		else {
			local edited_string =  "bar `new_yvar' `new_xvar' if `use_flag', " + ///
				" ytitle(`ytitle') yscale(log) barwidth(`new_width') " + ///
				`" xlabel(`xlist' , angle(45)) xtitle("`Cap_Var'") `options'"'
		}
	}

	return local edited_string = `"`edited_string'"'
end



program _add_hist_extras, rclass
    version 14
    syntax varlist , end(real) width(real) xlist(str) ///
		refusal(int) na(int) unsure(int) other(int) zeros(int)

	gettoken bin_var varlist : varlist
    gettoken touse varlist : varlist
    local varlist = strtrim("`varlist'")

	local include_refusal = 0
	local include_unsure = 0
	local include_na = 0
	local include_other = 0
	local include_zero = 0

    if (`refusal' != 0) {
        qui count if `touse' & (`varlist' == `refusal')
        local refusal_count = `r(N)'
        local include_refusal = (`refusal_count' != 0)
    }

    if (`unsure' != 0) {
        qui count if `touse' & (`varlist' == `unsure')
        local unsure_count = `r(N)'
        local include_unsure = (`unsure_count' != 0)
    }

    if (`na' != 0) {
        qui count if `touse' & (`varlist' == `na')
        local na_count = `r(N)'
        local include_na = (`na_count' != 0)
    }

    if (`other' != 0) {
        qui count if `touse' & (`varlist' == `other')
        local other_count = `r(N)'
        local include_other = (`other_count' != 0)
    }

	if (`zeros' == 1) {
		qui count if `touse' & (`varlist' == 0)
		local zero_count = `r(N)'
		local include_zero = (`zero_count' != 0)
	}

    if  `include_unsure' | `include_refusal' | `include_other' | ///
		`include_na' | `include_zero' {

        local add_val = `end' + 3 * `width'

        if `include_unsure' {
            replace `bin_var' = `add_val' if `varlist' == `unsure'
			local xlist = `"`xlist' `add_val' "Unsure" "'
            local add_val = `add_val' + `width'
        }

        if `include_refusal' {
            replace `bin_var' = `add_val' if `varlist' == `refusal'
			local xlist = `"`xlist' `add_val' "Refusal" "'
            local add_val = `add_val' + `width'
        }

        if `include_other' {
            replace `bin_var' = `add_val' if `varlist' == `other'
			local xlist = `"`xlist' `add_val' "Other" "'
            local add_val = `add_val' + `width'

        }

        if `include_na' {
            replace `bin_var' = `add_val' if `varlist' == `na'
			local xlist = `"`xlist' `add_val' "NA" "'
            local add_val = `add_val' + `width'
        }

		if `include_zero' {
            replace `bin_var' = `add_val' if `varlist' == 0
			local xlist = `"`xlist' `add_val' "None" "'
            local add_val = `add_val' + `width'
        }
    }

	return local xlist = `"`xlist'"'

end

program _linear_axis, rclass
	version 14
	syntax varlist(min=4 max=4 numeric) [ , ///
				DISCrete			///
				BIN(numlist max=1 >0 integer)	/// number of bins
				Width(numlist max=1 >0)		/// width of bins
				START(numlist max=1)		/// first bin position
				DENsity FRACtion FREQuency	/// height type
			]

	gettoken bin_var varlist : varlist
	gettoken new_yvar varlist : varlist
	gettoken use_flag varlist : varlist
	gettoken use_flag_2 varlist : varlist

	twoway__histogram_gen `bin_var' if `use_flag_2', ///
		bin(`bin') width(`width') start(`start') `discrete' ///
		`density' `fraction' `frequency' return

	local start = r(start)
	local width = r(width)
	local p_max = r(max)
	// Assign the bin number to new_yvar
	tempvar dif
	gen `dif' = `bin_var' - `start' if `use_flag'
	replace `new_yvar' = int(`dif'/`width') + 1 if `use_flag'

	// If Something is on the top edge of the highest bin, put in highest bin
	replace `new_yvar' = `new_yvar' - 1 if `bin_var' == `p_max' & `use_flag'

	// TODO : Take this sort of thing out so that it just works with bin #s
	replace `new_yvar' = (`new_yvar' - 1) * `width' + `start'

	auto_level_label `bin_var' if `use_flag_2'
	local list = r(level_label)

	// Identify how many of these coded values there are
	qui count if `use_flag' != `use_flag_2'
	local num_coded_values = r(N)

	// If there are coded values, remove the last label so labels dont overlap
	if `num_coded_values' != 0 {
		local list = strreverse("`list'")
		gettoken last list : list
		local list = strreverse("`list'")
	}

	return local list = `"`list'"'
	return local width = `width'
end

program _log_axis, rclass
    version 14
    syntax varlist, logbase(real)

	gettoken level_var varlist : varlist
	gettoken log_var varlist : varlist
    gettoken use_flag varlist : varlist

	qui replace `use_flag' = 0 if inlist(0, `level_var')
	auto_log_label `level_var' if `use_flag'
	local list_vals = r(log_label)
	qui mylabels `list_vals', myscale(floor(ln(@)/ln(`logbase'))) local(list)

	replace `log_var' = floor(ln(`level_var')/ln(`logbase'))

	return local list = `"`list'"'
end



*******************************************************************************
