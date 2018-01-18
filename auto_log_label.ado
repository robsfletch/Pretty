program auto_log_label, rclass
    version 14

    syntax varlist(min=1 max=1 numeric) [if]

    marksample touse

    qui niceloglabels `varlist' if `touse', local(log_label) style(1)
    local list_count : word count "`log_label'"

    if (`list_count' <= 6) {
        qui niceloglabels `varlist' if `touse', local(log_label) style(13)
    }
    local xlist = "`log_label'"

    local list_count : word count "`log_label'"

    if (`list_count' <= 3) {
        qui niceloglabels `varlist' if `touse', local(log_label) style(125)
    }

    return local log_label = "`log_label'"

end
