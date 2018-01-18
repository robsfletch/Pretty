program pretty
    version 14
    syntax anything [if] [in], [*]

    local ii = 1
    local plot_count = 0
    local plot_str = ""
    while "`anything'" != "" {
        gettoken `ii' anything : anything ,  parse("()") match(out)

        gettoken plot_type `ii': `ii'

        tempvar tmp_in_`plot_count' tmp_out_`plot_count' tmp_out_`plot_count'_2
        gen `tmp_in_`plot_count'' = .
        gen `tmp_out_`plot_count'' = .
        gen `tmp_out_`plot_count'_2' = .

        if inlist("`plot_type'", "scatter", "hist") {
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
