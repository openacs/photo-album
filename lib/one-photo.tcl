if {![info exists photo(user_url)]} {
    set photo(user_url) [acs_community_member_url -user_id $photo(user_id)]
}

