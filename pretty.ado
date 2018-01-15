prog define pretty

	syntax anything

    tokenize `anything'
    local anything "`2'"

    ** Basic
    else if "`1'" == "test" {
        pretty_test `2'
        exit
    }

end
