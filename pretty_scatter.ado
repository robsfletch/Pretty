program pretty_scatter, rclass
	version 14
	syntax varlist(min=4 numeric) [if] [in] [, unsure(int -888) ///
		refusal(int -555) other(int -999) na(int -777) xlog ylog *]

	gettoken passed_in varlist : varlist
	gettoken passed_out varlist : varlist
	local varlist = strtrim("`varlist'")
	local xvar = word("`varlist'",-1)
	local cs_varlist = subinstr( "`varlist'", " ", ", ", .)

	marksample touse
	qui replace `passed_in' = `touse'
	qui replace `passed_in' = 0 if inlist(`unsure', `cs_varlist')
	qui replace `passed_in' = 0 if inlist(`refusal', `cs_varlist')
	qui replace `passed_in' = 0 if inlist(`other', `cs_varlist')
	qui replace `passed_in' = 0 if inlist(`na', `cs_varlist')

	if "`xlog'" != "" {
		auto_log_label `xvar' if `passed_in'
		local xlist = r(log_label)
	}

	/* Haven't actually written this yet, so I need to
	if `ylog' != "" {
		auto_log_label `varlist' if `passed_in'
		local ylist = r(log_label)
	}
	*/

	local edited_string =  "scatter `varlist' if `passed_in', "  + ///
		" xlabel(`xlist') `options'"

	return local edited_string = "`edited_string'"
end
