# /packages/photo-album/tcl/photo-album-callbacks-procs.tcl
ad_library {
    TCL library for the photo-album callbacks implementations

    @author Enrique Catalan (quio@galileo.edu)

    @creation-date July 19, 2005
    @cvs-id $Id$
}


ad_proc -callback merge::MergeShowUserInfo -impl photo_album {
    -user_id:required
} {
    Show the items of user_id
} {
    set result [list "photo_album items of $user_id"]
    set user_items [db_list_of_lists sel_collections { *SQL* }]
    lappend result $user_items
    return $result
}

ad_proc -callback merge::MergePackageUser -impl photo_album {
    -from_user_id:required
    -to_user_id:required
} {
    Merge the photo_album items of two users.
} {
    set msg "Merging photo album"
    set result [list $msg]
    ns_log Notice $msg
    
    db_transaction {
	db_dml upd_collections { *SQL* }
	lappend result "Photo album merge is done"
    } 
    return $result
}