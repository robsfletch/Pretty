program pretty_loghist
	version 13
	syntax varlist(min=2 max=2 numeric) [if] [in] [, unsure(int -888) refusal(int -555) ///
					other(int -999) na(int -777) ///
					logbase(real 1.5) gen(str) xlist(str) name(str) ///
					save(str) *]			

	marksample touse
	tab `touse'
	local obs_count = 0

	/*
	***************************
	** AUTOMATIC LABEL SETUP **
	***************************
	qui sum `2' if `touse' & !inlist(`varlist', `unsure', `refusal', ///
								 `other', `na', 0)
	local max = `r(max)'
	local min = `r(min)'
	local bin_count = ceil(log10(`max') / log10(`logbase'))
	if ("`xlist'" == "" ) {
		local xlist = `""'
		local x_list_count = 1

		local low = floor(log10(`min'))		
		local dif = log10(`min') - floor(log10(`min'))

		local x = 10^`low'

		local l = log10(`min')
		
		while `x' < `logbase'^(`bin_count') {
			if (`dif' >= .477) & (`x_list_count' == 1) {
				local x_list_count = `x_list_count' + 1
				local x = `x' * 10
				continue
			}
			local xlist = `"`xlist' `x' "`x'" "'
			local x_list_count = `x_list_count' + 1
			local x = `x' * 10
		}
		
		if (`dif' >= .4771213) {
			local x_list_count = `x_list_count' - 1
		}
		
		if (`x_list_count' <= 3) {
			local x = 2 * 10^`low' 
			while `x' < `logbase'^(`bin_count')  {
				local xlist = `"`xlist' `x' "`x'" "'
				local x_list_count = `x_list_count' + 1
				local x = `x' * 10
			}
			local x = 4 * 10^`low' 
			while `x' < `logbase'^(`bin_count')  {
				local xlist = `"`xlist' `x' "`x'" "'
				local x_list_count = `x_list_count' + 1
				local x = `x' * 10
			}
		}
		
		if (`x_list_count' <= 6) {
			local x = 3 * 10^`low' 
			while `x' < `logbase'^(`bin_count')  {
				local xlist = `"`xlist' `x' "`x'" "'
				local x_list_count = `x_list_count' + 1
				local x = `x' * 10
			}
		}		

	}
	
	**********************
	** LOG SCALE LABELS **
	**********************
	** Stata's implementation of this is terrible, so redo it
	local mat_length = `bin_count' + 1
	
	if (`refusal' != 0) {
		qui count if `touse' & (`varlist' == `refusal')
		local refusal_count = `r(N)'
		if (`refusal_count' != 0) local mat_length = `mat_length' + 1
	}
	
	if (`unsure' != 0) {
		qui count if `touse' & (`varlist' == `unsure')
		local unsure_count = `r(N)'
		if (`unsure_count' != 0) local mat_length = `mat_length' + 1
	}

	if (`na' != 0) {
		qui count if `touse' & (`varlist' == `na')
		local na_count = `r(N)'
		if (`na_count' != 0) local mat_length = `mat_length' + 1
	}

	if (`other' != 0) {
		qui count if `touse' & (`varlist' == `other')
		local other_count = `r(N)'
		if (`other_count' != 0) local mat_length = `mat_length' + 1
	}
	
	qui count if `touse' & (`varlist' == 0)
	local zero_count = `r(N)'
	if (`zero_count' != 0) local mat_length = `mat_length' + 1
	
	local for_max = `bin_count'
	if ((`unsure' != 0) & (`unsure_count' != 0)) | /// 
	   ((`refusal' != 0) & (`refusal_count' != 0)) | ///
	   ((`other' != 0) & (`other_count' != 0)) | ///
	   ((`na' != 0) & (`na_count' != 0)) | ///
	   (`zero_count' != 0) {
		local mat_length = `mat_length' + 2
		local for_max = `bin_count' + 2
	}
	
	matrix Probs = J(`mat_length',4, 0)

	
	*******************************
	** CALCULATE THE BIN HEIGHTS **
	*******************************
	** Check how many times to iterate (possibly leave two blank bins at end
	** If including extra info on the right
	
	foreach dig of numlist 1/`for_max' {
		
		local bin_min = `logbase'^(`dig'-1)
		local bin_max = `logbase'^(`dig')
		local bin_mean = (`bin_min' * `bin_max')^(0.5)
		
		qui count if `touse' & (`varlist' >= `bin_min') & ///
				(`varlist' < `bin_max')
		local bin_obs = `r(N)'
				
		matrix Probs[`dig',1] = `bin_min'
		matrix Probs[`dig',2] = `bin_mean'
		matrix Probs[`dig',3] = `bin_max'
		matrix Probs[`dig',4] = `bin_obs'
		
		local obs_count = `obs_count' + `bin_obs'
				
	}		
		
	local dig = `for_max'
	
	if (`zero_count' != 0) {
		local dig = `dig' + 1
		local zero_min = `logbase'^(`dig' - 1)
		local zero_max = `logbase'^(`dig')
		local zero_mean = (`zero_min' * `zero_max')^(0.5)

		matrix Probs[`dig', 1] = `zero_min'
		matrix Probs[`dig', 2] = `zero_mean'
		matrix Probs[`dig', 3] = `zero_max'
		matrix Probs[`dig', 4] = `zero_count'
		local xlist = `"`xlist' `zero_mean' "None" "'
		
		local obs_count = `obs_count' + `zero_count'
	}
	
	
	
	if (`unsure' != 0) & (`unsure_count' != 0) {
		local dig = `dig' + 1
		local unsure_min = `logbase'^(`dig' - 1)
		local unsure_max = `logbase'^(`dig')
		local unsure_mean = (`unsure_min' * `unsure_max')^(0.5)

		matrix Probs[`dig', 1] = `unsure_min'
		matrix Probs[`dig', 2] = `unsure_mean'
		matrix Probs[`dig', 3] = `unsure_max'
		matrix Probs[`dig', 4] = `unsure_count'
		local xlist = `"`xlist' `unsure_mean' "unsure" "'
		
		local obs_count = `obs_count' + `unsure_count'
	}
	
	if (`refusal' != 0) & (`refusal_count' != 0) {
		local dig = `dig' + 1
		local refusal_min = `logbase'^(`dig' - 1)
		local refusal_max = `logbase'^(`dig')
		local refusal_mean = (`refusal_min' * `refusal_max')^(0.5)

		matrix Probs[`dig', 1] = `refusal_min'
		matrix Probs[`dig', 2] = `refusal_mean'
		matrix Probs[`dig', 3] = `refusal_max'
		matrix Probs[`dig', 4] = `refusal_count'
		
		local xlist = `"`xlist' `refusal_mean' "refusal" "'
		
		local obs_count = `obs_count' + `refusal_count'
	}
	
	if (`na' != 0) & (`na_count' != 0) {
		local dig = `dig' + 1
		local na_min = `logbase'^(`dig' - 1)
		local na_max = `logbase'^(`dig')
		local na_mean = (`na_min' * `na_max')^(0.5)

		matrix Probs[`dig', 1] = `na_min'
		matrix Probs[`dig', 2] = `na_mean'
		matrix Probs[`dig', 3] = `na_max'
		matrix Probs[`dig', 4] = `na_count'
		
		local xlist = `"`xlist' `na_mean' "N/A" "'
		
		local obs_count = `obs_count' + `na_count'
	}

	if (`other' != 0) & (`other_count' != 0) {
		local dig = `dig' + 1
		local other_min = `logbase'^(`dig' - 1)
		local other_max = `logbase'^(`dig')
		local other_mean = (`other_min' * `other_max')^(0.5)

		matrix Probs[`dig', 1] = `other_min'
		matrix Probs[`dig', 2] = `other_mean'
		matrix Probs[`dig', 3] = `other_max'
		matrix Probs[`dig', 4] = `other_count'
		
		local xlist = `"`xlist' `other_mean' "other" "'
		
		local obs_count = `obs_count' + `other_count'
	}

	local dig = `dig' + 1
	local last_min = `logbase'^(`dig' - 1)
	local last_max = `logbase'^(`dig')
	local last_mean = (`last_min' * `last_max')^(0.5)
	matrix Probs[`dig', 1] = `last_min'
	matrix Probs[`dig', 2] = `last_mean'
	matrix Probs[`dig', 3] = `last_max'
	matrix Probs[`dig', 4] = 0
	
	
	capture su Probs1, meanonly 
	if _rc == 0 { 
		drop Probs*
	}
	
	svmat2 Probs
	
	/*
	replace Probs2 = . if Probs1 < `min'
	replace Probs1 = . if Probs1 < `min'
	*/
	
	replace Probs4 = Probs4 / `obs_count'
	local sub = "(N = `obs_count')"
	
	graph twoway bar Probs4 Probs1 if Probs3 >= `min', scheme(s2personal) /// 
	base(0) bartype(spanning) xscale(log) subtitle("`sub'", size(medsmall)) ///
	xtitle("") ytitle("") xlabel(`xlist' , angle(45)) ///
	name("`name'", replace) `nodraw' `options'
	
	******************
	** EXPORT GRAPH **
	******************		
	if ("`save'" != "") {
		graph export "`save'", replace fontface(Helvetica-Light)
	}
	*/
end
