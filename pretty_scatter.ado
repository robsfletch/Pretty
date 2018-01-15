program pretty_scatter
	version 13
	syntax varlist(min=2 max=2 numeric) [if] [in] [, unsure(int -888) ///
		refusal(int -555) other(int -999) na(int -777) name(str) save(str) *]

	marksample touse
	qui tab `touse'

	pretty_wraper scatter `1' `2' if `touse' ///
		& !inlist(`2', `unsure', `refusal', `other', `na', 0), ///
		name("`name'") save("`save'") `options'

end
