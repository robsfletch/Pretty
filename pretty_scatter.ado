program pretty_scatter, rclass
	version 14
	syntax varlist(min=5 max=5 numeric) [if] [in] ///
		[,					///
			refusal(int -555) ///
			na(int -777) ///
			unsure(int -888) ///
			other(int -999) ///
		 	xlogbase(real 1)	///
			ylogbase(real 1)	///
			ylabel(str) ///
			xlabel(str) ///
			\ *	///
		]

*******************************************************************************
** Map incoming variables and mark observation to include
*******************************************************************************
	gettoken use_flag varlist : varlist
	gettoken new_yvar varlist : varlist
	gettoken new_xvar varlist : varlist
	gettoken yvar varlist : varlist
	gettoken xvar varlist : varlist

	marksample touse
	qui replace `use_flag' = `touse'

	// Don't include observations with unsure, refusal, other, or na values
	local cs_varlist = "`yvar', `xvar'"
	qui replace `use_flag' = 0 if inlist(`unsure', `cs_varlist')
	qui replace `use_flag' = 0 if inlist(`refusal', `cs_varlist')
	qui replace `use_flag' = 0 if inlist(`other', `cs_varlist')
	qui replace `use_flag' = 0 if inlist(`na', `cs_varlist')

*******************************************************************************
** X Variable Clean-Up
*******************************************************************************
	if `xlogbase' != 1 {
		_log_axis `xvar' `use_flag' `new_xvar' , logbase(`xlogbase')
		local xlabel = r(list)
		local xlabel = `"`xlabel', angle(45)"'
	}
	else{
		replace `new_xvar' = `xvar'
		if "`xlabel'" != "" {
			label value `new_xvar' `xvar'
		}
	}

*******************************************************************************
** Y Variable Clean-UP
*******************************************************************************
	if `ylogbase' != 1 {
		_log_axis `yvar' `use_flag' `new_yvar' , logbase(`ylogbase')
		local ylabel = r(list)
		local ylabel = `"`ylabel', angle(0)"'
	}
	else{
		replace `new_yvar' = `yvar'
		if "`ylabel'" != "" {
			label value `new_yvar' `yvar'
		}
	}

*******************************************************************************
** Prep And Return Graphing String
*******************************************************************************
	local edited_string =  `"scatter `new_yvar' `new_xvar' if `use_flag', "'  + ///
		`" xlabel(`xlabel') ylabel(`ylabel') `options'"'

	return local edited_string = `"`edited_string'"'
end

program _log_axis, rclass
    version 14
    syntax varlist, logbase(real)

	gettoken level_var varlist : varlist
    gettoken use_flag varlist : varlist
	gettoken log_var varlist : varlist

	auto_log_label `level_var' if `use_flag' & !inlist(0, `level_var')
	local list_vals = r(log_label)

	qui count if inlist(0, `level_var')
	if `r(N)' > 0 {
		local list_vals = `"0 `list_vals'"'
		qui mylabels `list_vals', myscale(ln(@ + 1)/ln(`logbase')) local(list)
		replace `log_var' = ln(`level_var' + 1) / ln(`logbase')
	}
	else {
		qui mylabels `list_vals', myscale(ln(@)/ln(`logbase')) local(list)
		replace `log_var' = ln(`level_var') / ln(`logbase')
	}

	return local list = `"`list'"'
end
