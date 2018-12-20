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
			display				/// display a note
		 	xlogbase(real 1)	///
			ylogbase(real 1)	///
			\ *	///
		]

	gettoken passed_in varlist : varlist
	gettoken passed_out varlist : varlist
	gettoken passed_out2 varlist : varlist
	local varlist = strtrim("`varlist'")
	local cs_varlist = subinstr( "`varlist'", " ", ", ", .)

	marksample touse
	qui replace `passed_in' = `touse'
	tempvar passed_in_2
	gen `passed_in_2' = `passed_in'
	qui replace `passed_in_2' = 0 if inlist(`unsure', `cs_varlist')
	qui replace `passed_in_2' = 0 if inlist(`refusal', `cs_varlist')
	qui replace `passed_in_2' = 0 if inlist(`other', `cs_varlist')
	qui replace `passed_in_2' = 0 if inlist(`na', `cs_varlist')
	count if `passed_in' != `passed_in_2'
	local extras = r(N)

	if `xlogbase' == 1 {
		twoway__histogram_gen `varlist' if `passed_in_2', ///
			bin(`bin') width(`width') start(`start') ///
			`discrete' `density' `fraction' `frequency' ///
			`percent' `return' `display' return

		local start = r(start)
	    local width = r(width)
		local p_max = r(max)
		// Assign the bin number to passed_out
		tempvar dif
	    gen `dif' = `varlist' - `start' if `passed_in'
	    replace `passed_out' = int(`dif'/`width') + 1 if `passed_in'
		// If Something is right on the top edge of the highest bin,
		// put in in the highest bin
	    replace `passed_out' = `passed_out' - 1 if `varlist' == `p_max' & `passed_in'
		replace `passed_out' = (`passed_out' - 1) * `width' + `start'

		regaxis `varlist' if `passed_in_2', cycle(`width') maxticks(10)
		local xlist = r(ticks)
		* gettoken first xlist : xlist
		if `extras' != 0 {
			local xlist = strreverse("`xlist'")
			gettoken last xlist : xlist
			local xlist = strreverse("`xlist'")
		}
	}
	else {
		qui replace `passed_in_2' = 0 if inlist(0, `cs_varlist')
		auto_log_label `varlist' if `passed_in_2'
		local xlist1 = r(log_label)
		qui mylabels `xlist1', myscale(floor(ln(@)/ln(`xlogbase'))) local(xlist)

		replace `passed_out' = floor(ln(`varlist')/ln(`xlogbase'))
		local width = 1
	}

	qui sum `passed_out'
	local end = r(max)

	_add_hist_extras `passed_out' `touse' `varlist' , ///
		refusal(`refusal') ///
		na(`na') ///
		unsure(`unsure') ///
		other(`other') ///
		zeros(`zeros') ///
		end(`end') ///
		width(`width') ///
		xlist(`"`xlist'"')

	local xlist = r(xlist)
	***************************************************************************
	** SETUP PLOTTING STRING
	***************************************************************************
	if "`ymtick'" == "" {
		local ymtick = "#10"
	}

 	local Cap_Var = strproper("`varlist'")

	if (`ylogbase' == 1) {
		if ("`cdf'" == "") {
			local edited_string =  "hist `passed_out' if `passed_in', " + ///
				" `density' `fraction' `frequency' ytitle(`ytitle') ymtick(`ymtick') discrete " + ///
				`" xlabel(`xlist' , angle(45)) xtitle("`Cap_Var'") `options'"'
		}
		** Add in the option of superimposing a cdf plot on the histogram plot
		else {
			tempvar passthru
			cumul `passed_out' if `passed_in', gen(`passthru')
			replace `passed_out2' = `passthru'
			sort `passed_out2'

			local edited_string =  "hist `passed_out' if `passed_in', " + ///
				" `density' `fraction' `frequency' ytitle(`ytitle') yaxis(1) ymtick(`ymtick') discrete " + ///
				`" xlabel(`xlist' , angle(45)) xtitle("`Cap_Var'") `options') "' + ///
				"(line `passed_out2' `passed_out' if `passed_in', " + ///
				`" yaxis(2) xlabel(`xlist' , angle(45)) ymtick(`ymtick')  `options'"'
		}
	}
	else {
		tempvar passthru1 passthru2
		twoway__histogram_gen  `passed_out', ///
			gen(`passthru1' `passthru2') `discrete' `density' `fraction' `frequency'

		replace `passed_out' = `passthru1'
		replace `passed_out2' = `passthru2'

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
			local edited_string =  "bar `passed_out' `passed_out2' if `passed_in', " + ///
				" ytitle(`ytitle') yscale(log) barwidth(`new_width') " + ///
				`" xlabel(`xlist' , angle(45)) xtitle("`Cap_Var'") `options'"'
		}
		** Add in the option of superimposing a cdf plot on the histogram plot
		else {
			local edited_string =  "bar `passed_out' `passed_out2' if `passed_in', " + ///
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
