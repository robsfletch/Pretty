program pretty_wraper
	version 14
	syntax anything(name=plot) [if] [in] [, name(str) save(str) scheme(str) *]

	/*
	marksample touse

	qui sum `touse' if `touse'

	local max = `r(max)'
	local min = `r(min)'
	local obs_count = `r(N)'

	local sub = "(N = `obs_count')"
	*/

	******************
	** SCHEME SETUP **
	******************
	** Set up my personal scheme as the default
	if "`scheme'" == "" local scheme "pretty1"

    graph twoway `plot' `if' `in' , scheme(`scheme') ///
    	name("`name'", replace) `options'

	*subtitle("`sub'", size(medsmall)) ///

	******************
	** EXPORT GRAPH **
	******************
	if ("`save'" != "") {
		graph export "`save'", replace
	}
end
