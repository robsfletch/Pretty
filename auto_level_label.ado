program auto_level_label, rclass
    version 14

    syntax varlist(min=1 max=1 numeric) [if]

    marksample touse

    qui regaxis `varlist' if `touse'
    local num_ticks = r(ntick)
    local min = r(rmin)
    local max = r(rmax)
    local cycle = (`max' - `min')/(`num_ticks' - 1)

    while (`num_ticks' >= 8) {
        local cycle = 2 * `cycle'
        qui regaxis `varlist' if `touse', cycle(`cycle')
        local num_ticks = r(ntick)
    }
    local level_label = r(ticks)

    return local level_label = "`level_label'"

end
