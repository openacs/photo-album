#/packages/photo-album/www/photo-move.tcl

ad_page_contract {
    Allows user to move a photo from one album to another album in the same folder

    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 12/20/2000
    @cvs-id $Id$
} {
    photo_id:integer,notnull
} -validate {
    valid_photo -requires {photo_id:integer} {
	if [string equal [pa_is_photo_p $photo_id] "f"] {
	    ad_complain "The specified photo is not valid."
	}
    }
}
set context_list [pa_context_bar_list -final "Move Photo" $photo_id]
set user_id [ad_conn user_id]
set root_folder_id [pa_get_root_folder]

# to move a photo need write on photo, and old parent album
# and pa_create_photo on new parent album (which is check in the is_valid block)

set old_album_id [db_string get_parent_album "select parent_id from cr_items where item_id = :photo_id"]
ad_require_permission $photo_id write


ad_require_permission $old_album_id write

db_1row get_photo_info {} 

set path $image_id

# build form

template::form create move_photo

template::element create move_photo photo_id -label "photo ID" \
  -datatype integer -widget hidden

template::element create move_photo new_album_id -label "Choose New Album for Photo" \
  -datatype integer -widget select \
    -options [db_list_of_lists get_albums {}]

if { [template::form is_request move_photo] } {
    template::element set_properties move_photo photo_id -value $photo_id
}

if { [template::form is_valid move_photo] } {
    set new_album_id [template::element::get_value move_photo new_album_id]

    ad_require_permission $new_album_id "pa_create_photo"

    if [string equal [pa_is_album_p $new_album_id] "f"] {
	# may add some sort of error message
	# but this case only happens due to url hacking
	# (or coding errors, which never happen)
	ad_script_abort
    }

    db_transaction {
        
        # not using content_item move because is only accepts 
        # a folder_id as target not another content_item

	set rel_id [db_string photo_rel_id {}]

	db_dml photo_move {}
	
	db_dml photo_move2 {}
	
	db_dml context_update {}
	
    } on_error {
	# most likely a duplicate name or a double click
	
	set filename [db_string filename "
	select name from cr_items where item_id = :photo_id"]
	
	if [db_string duplicate_check "
	select count(*)
	from   cr_items
	where  name = :filename
	and    parent_id = :new_album_id"] {
	    ad_return_complaint 1 "Either there is already a photo in the specified albumr with the name \"$filename\" or you clicked on the button more than once.  You can <a href=\"album?album_id=$new_album_id\">return to the new album</a> to see if your photo is there."
	} else {
	    ad_return_complaint 1 "We got an error that we couldn't readily identify.  Please let the system owner know about this.

	    <pre>$errmsg</pre>"
	}
	
	ad_script_abort
    }

    pa_flush_photo_in_album_cache $old_album_id
    pa_flush_photo_in_album_cache $new_album_id
    
    #page used to redirect user to the page of new album containing moved photos
    set page [pa_page_of_photo_in_album $photo_id $new_album_id]
    
    ad_returnredirect "album?album_id=$new_album_id&page=$page"
    ad_script_abort
}

ad_return_template




