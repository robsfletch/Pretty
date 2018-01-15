program pretty_parse
    version 14
    syntax anything [if] [in], [*]

    local ii = 1
    local plot_count = 0
    local plot_str = ""
    while "`anything'" != "" {
        gettoken `ii' anything : anything ,  parse("()") match(out)
        local plot_str = "`plot_str'" + "(``ii'') "
        local ++ii
        local ++plot_count
    }

    pretty_wraper `plot_str' `if' `in', `options'

end
