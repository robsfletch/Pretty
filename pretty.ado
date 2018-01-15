program pretty
    version 14
    syntax anything [if] [in], [*]

    local ii = 1
    local plot_count = 0
    local plot_str = ""
    while "`anything'" != "" {
        gettoken `ii' anything : anything ,  parse("()") match(out)

        gettoken plot_type `ii': `ii'

        tempvar temp`plot_count'
        qui gen `temp`plot_count'' = .

        pretty_`plot_type' `temp`plot_count''  ``ii''
        local new_plot =  "`r(edited_string)'"

        ** Update the revised plotting command string
        local plot_str = "`plot_str'" + "(`new_plot') "

        local ++ii
        local ++plot_count
    }

    pretty_wraper `plot_str' `if' `in', `options'


end
