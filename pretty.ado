program pretty
    version 14
    syntax anything [if] [in], [*]

    local ii = 1
    local plot_count = 0
    local plot_str = ""

    gettoken check : anything ,  parse("()") match(out)

    ** In the case that there is only one plot being made, make sure
    ** There are parentheses around it so the options are passed to the
    ** subroutine
    if "`check'" == "`anything'" {
        local anything = `"(`anything' `if' `in', `options')"'
        local if = ""
        local in = ""
        local options = ""
    }

    while "`anything'" != "" {

        gettoken `ii' anything : anything ,  parse("()") match(out)
        gettoken plot_type `ii': `ii'

        tempvar tmp_in_`plot_count' tmp_out_`plot_count' tmp_out_`plot_count'_2
        gen `tmp_in_`plot_count'' = .
        gen `tmp_out_`plot_count'' = .
        gen `tmp_out_`plot_count'_2' = .

        if inlist("`plot_type'", "hist", "histo", "histog", "histogr", ///
            "histogra", "histogram") {
                local plot_type = "histogram"
        }

        if inlist("`plot_type'", "sc", "sca", "scat", "scatt", ///
            "scatte", "scatter") {
                local plot_type = "scatter"
        }

        if inlist("`plot_type'", "scatter", "histogram") {
            pretty_`plot_type' `tmp_in_`plot_count'' `tmp_out_`plot_count'' ///
                `tmp_out_`plot_count'_2' ``ii''
            local new_plot =  `"`r(edited_string)'"'
        }
        else {
            local new_plot =  "`plot_type' ``ii''"
        }

        ** Update the revised plotting command string
        local plot_str = `"`plot_str'"' + `"(`new_plot') "'

        local ++ii
        local ++plot_count
    }

    * disp `"`plot_str'"'
    pretty_wraper `plot_str' `if' `in', `options'

end
