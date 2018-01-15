program pretty_wraper
	version 13
	syntax anything(name=plot) [if] [in] [, name(str) save(str) *]

	marksample touse

	qui sum `2' if `touse'

	local max = `r(max)'
	local min = `r(min)'
	local obs_count = `r(N)'

	local sub = "(N = `obs_count')"

    graph twoway `plot' `if' `in' , scheme(s2personal) ///
        subtitle("`sub'", size(medsmall)) ///
    	name("`name'", replace) `options'


	******************
	** EXPORT GRAPH **
	******************
	if ("`save'" != "") {
		graph export "`save'", replace fontface(Helvetica-Light)
	}
end
