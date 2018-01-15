program pretty_logscatter
	version 13
	syntax varlist(min=2 max=2 numeric) [if] [in] [, unsure(int -888) refusal(int -555) ///
					other(int -999) na(int -777) ///
					logbase(real 1.5) gen(str) xlist(str) name(str) ///
					save(str) *]			

	marksample touse
	qui tab `touse'
	
	drop if `2' == 0
	***************************
	** AUTOMATIC LABEL SETUP **
	***************************
	qui sum `2' if `touse' & !inlist(`2', `unsure', `refusal', ///
								 `other', `na', 0)
			
	local max = `r(max)'
	local min = `r(min)'
	local obs_count = `r(N)'
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
	
	local sub = "(N = `obs_count')"
	
	graph twoway scatter `1' `2' `if', scheme(s2personal) /// 
	xscale(log) subtitle("`sub'", size(medsmall)) ///
	xlabel(`xlist' , angle(45)) ///
	name("`name'", replace) `nodraw' `options'
	
	
	******************
	** EXPORT GRAPH **
	******************		
	if ("`save'" != "") {
		graph export "`save'", replace fontface(Helvetica-Light)
	}
end
