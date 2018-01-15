program pretty_scatter
	version 13
	syntax varlist(min=2 max=2 numeric) [if] [in] [, unsure(int -888) refusal(int -555) ///
					other(int -999) na(int -777) ///
					xlist(str) name(str) ///
					save(str) *]			

	marksample touse
	qui tab `touse'
	
	***************************
	** AUTOMATIC LABEL SETUP **
	***************************
	qui sum `2' if `touse' & !inlist(`2', `unsure', `refusal', ///
								 `other', `na', 0)
			
	local max = `r(max)'
	local min = `r(min)'
	local obs_count = `r(N)'
	
	local sub = "(N = `obs_count')"
	
	graph twoway scatter `1' `2' `if', scheme(s2personal) /// 
	subtitle("`sub'", size(medsmall)) ///
	xlabel(`xlist' , angle(45)) ///
	name("`name'", replace) `nodraw' `options'
	
	
	******************
	** EXPORT GRAPH **
	******************		
	if ("`save'" != "") {
		graph export "`save'", replace fontface(Helvetica-Light)
	}
end
