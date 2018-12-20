program pretty_scatter, rclass
	version 14
	syntax varlist(min=5 max=5 numeric) [if] [in] ///
		[,					///
			refusal(int -555) ///
			na(int -777) ///
			unsure(int -888) ///
			other(int -999) ///
			zeros(int 0) ///
			ytitle(str) ///
			ymtick(str) ///
			PERCENT				///
			RETurn				/// save results in r()
			display				/// display a note
		 	xlogbase(real 1)	///
			ylogbase(real 1)	///
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
	local cs_varlist = "`yvar', `xvar'"

	marksample touse
	qui replace `use_flag' = `touse'
	qui replace `use_flag' = 0 if inlist(`unsure', `cs_varlist')
	qui replace `use_flag' = 0 if inlist(`refusal', `cs_varlist')
	qui replace `use_flag' = 0 if inlist(`other', `cs_varlist')
	qui replace `use_flag' = 0 if inlist(`na', `cs_varlist')

*******************************************************************************
** X Variable Clean-Up
*******************************************************************************
	if `xlogbase' != 1 {
		_log_axis `xvar' `use_flag' `new_xvar' , logbase(`xlogbase')
		local xlist = r(list)
	}
	else{
		replace `new_xvar' = `xvar'
	}

*******************************************************************************
** Y Variable Clean-UP
*******************************************************************************
	if `ylogbase' != 1 {
		_log_axis `yvar' `use_flag' `new_yvar' , logbase(`ylogbase')
		local ylist = r(list)
	}
	else{
		replace `new_yvar' = `yvar'
	}

*******************************************************************************
** Prep And Return Graphing String
*******************************************************************************
	local edited_string =  `"scatter `new_yvar' `new_xvar' if `use_flag', "'  + ///
		`" xlabel(`xlist', angle(45)) ylabel(`ylist', angle(0)) `options'"'

	return local edited_string = `"`edited_string'"'
end

program _log_axis, rclass
    version 14
    syntax varlist, logbase(real)


	gettoken level_var varlist : varlist
    gettoken use_flag varlist : varlist
	gettoken log_var varlist : varlist

	qui replace `use_flag' = 0 if inlist(0, `level_var')
	auto_log_label `level_var' if `use_flag'
	local list_vals = r(log_label)
	qui mylabels `list_vals', myscale(floor(ln(@)/ln(`logbase'))) local(list)

	replace `log_var' = floor(ln(`level_var')/ln(`logbase'))

	return local list = `"`list'"'
end
