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

proc pa_rotate {id rotation} {
    if {![empty_string_p $rotation] && ![string equal $rotation 0]} { 
        set flop [list]
        set files [list]

        # get a list of files to handle sorted by size...
        db_foreach get_image_files { 
            select i.image_id, crr.content, i.width, i.height
            from cr_items cri, cr_revisions crr, images i
            where cri.parent_id = :id
              and crr.revision_id = cri.latest_revision
              and i.image_id = cri.latest_revision
            order by crr.content_length desc
        } {
            ns_log Notice "pa_rotate $id $rotation [cr_fs_path] $content $image_id $width $height"
            if {[catch {exec convert -rotate $rotation [cr_fs_path]$content [cr_fs_path]${content}.new } errMsg]} { 
                ns_log Notice "Failed rotation of image $image_id -- $errMsg"
            }
            lappend flop $image_id
            lappend files [cr_fs_path]$content
        }

        # rename files in catch.
        if { [catch { 
            foreach fnm $files {
                file rename -force $fnm ${fnm}.old 
                file rename -force ${fnm}.new $fnm
            } } errMsg ] } { 
            # problem with the renaming.  Make an attempt to rename them back 
            catch { 
                foreach fnm $files {
                    file rename -force ${fnm}.old $fnm
                    file delete -force ${fnm}.new
                }
            } errMsg
        } else { 
            # flop images that need flopping.
            if {[string equal $rotation 90] || [string equal $rotation 270]} { 
                db_dml flop_image_size "update images set width = height, height = width where image_id in ([join $flop ,])"
            }
        }
    }
}

        
foreach id [array names d] { 
    if { $d($id) > 0 } { 
        pa_rotate $id $d($id)
    }
}
        
ad_script_abort
