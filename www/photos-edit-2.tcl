ad_page_contract { 
    Bulk edit a set of images.
} { 
    album_id:integer,notnull
    {page:integer,notnull "1"}
    d:array,integer,optional
    hide:array,optional
    caption:array
    story:array
} -validate {
    valid_album -requires {album_id:integer} {
	if [string equal [pa_is_album_p $album_id] "f"] {
	    ad_complain "The specified album is not valid."
	}
    }
}

set context_list [pa_context_bar_list -final "Edit page $page" $album_id]

set hides [list]
set shows [list]
foreach id [array names caption] { 
    # create a list of hide and show images.
    if {[info exists hide($id)]} { 
        lappend hides $id
    } else { 
        lappend shows $id
    }
        
    set acaption $caption($id)
    set astory $story($id)

    db_dml update_photo { 
        update pa_photos
        set caption = :acaption, 
        story = :astory
        where pa_photo_id = (select latest_revision from cr_items where item_id = :id)
    }

    if {[llength $hides]} { 
        db_dml update_hides "update cr_items set live_revision = null where item_id in ([join $hides ,])"
    } 
    if {[llength $shows]} { 
        db_dml update_shows "update cr_items set live_revision = latest_revision where item_id in ([join $shows ,])"
    }
        
}

pa_flush_photo_in_album_cache $album_id

ad_returnredirect "album?album_id=$album_id&page=$page&msg=1"

foreach id [array names d] { 
    if { $d($id) > 0 } { 
        pa_rotate $id $d($id)
    }
}
        
ad_script_abort
