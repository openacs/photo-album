# /packages/photo-album/www/photo.tcl

ad_page_contract {

    Display page for base sized image.
    Only accessable if parameter set for package
    
    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 2/1/2000
    @cvs-id $Id$
} {
    photo_id:integer,notnull
} -validate {
    valid_photo -requires {photo_id:integer} {
	if [string equal [pa_is_photo_p $photo_id] "f"] {
	    ad_complain "[_ photo-album._The_2]"
	}
    }
} -properties {
    context:onevalue
    title:onevalue
    description:onevalue
    story:onevalue
    caption:onevalue
    path:onevalue
    height:onevalue
    width:onevalue
}

if {![string equal [ad_parameter AllowBasePhotoAccessP] "t"]} {
    ad_return_forbidden "[_ photo-album._No]"
    ad_script_abort
}

ad_require_permission $photo_id "read"

set user_id [ad_conn user_id]
set context [pa_context_bar_list -final "[_ photo-album._Full]" $photo_id]

# query all the photo and permission info with a single trip to database
if {![db_0or1row get_photo_info {}]} {
    ad_return_error "[_ photo-album.No_Photo]" "[_ photo-album.lt_No_Photo_was_found_fo]"
} else {
    set path $image_id

    # determine what album page the photo is on so page can present link back to thumbnail page
    set page_num [pa_page_of_photo_in_album $photo_id $album_id]
    
    set photo_nav_html [pa_pagination_bar $photo_id [pa_all_photos_in_album $album_id] "base-photo?photo_id="]

    ad_return_template
}
