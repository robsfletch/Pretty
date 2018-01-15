program pretty_scatter, rclass
	version 14
	syntax varlist(min=3 numeric) [if] [in] [, unsure(int -888) ///
		refusal(int -555) other(int -999) na(int -777) *]

	gettoken passed_temp varlist : varlist

	marksample touse
	qui replace `passed_temp' = `touse'

	local cs_varlist = subinstr( strtrim("`varlist'"), " ", ", ", .)

	local edited_string =  "scatter `varlist' if `passed_temp' " + ///
		"& !inlist(`unsure', `cs_varlist')" + ///
		"& !inlist(`refusal', `cs_varlist')" + ///
		"& !inlist(`other', `cs_varlist')" + ///
		"& !inlist(`na', `cs_varlist') , `options'"

	return local edited_string = "`edited_string'"
	return local drop_var = "`new_temp'"
end
