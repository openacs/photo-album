# /packages/photo-album/www/photo.tcl

ad_page_contract {

    Photo display page.
    
    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 12/10/2000
    @cvs-id $Id$
} {
    photo_id:integer,notnull
    {collection_id:integer,optional {}}
} -validate {
    valid_photo -requires {photo_id:integer} {
	if [string equal [pa_is_photo_p $photo_id] "f"] {
	    ad_complain "The specified photo is not valid."
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
    photo_nav_html:onevalue
    admin_p:onevalue
    write_p:onevalue
    album_id:onevalue
    page_num:onevalue
    show_base_link:onevalue
    clipboards:multirow
}

ad_require_permission $photo_id "read"

set user_id [ad_conn user_id]
set context [pa_context_bar_list $photo_id]

# this is handled with a parameter rather than a permission on the 
# individual photo so admin can turn access on and off for entire
# subsite at once.   A permission would allow greater flexability, but
# to shut down access to base photos an admin would need to search through
# database and revoke all such permissions.
set show_base_link [ad_parameter AllowBasePhotoAccessP]

# query all the photo and permission info with a single trip to database
if {![db_0or1row get_photo_info {}]} { 
    ad_return_complaint 1 "<li> photo not found"
}

set path $image_id

# to move a photo need write on photo and write on parent album
set move_p [expr $write_p && $album_write_p]

# to delete a photo need delete on photo and write on parent album
set delete_p [expr $photo_delete_p && $album_write_p]

# determine what album page the photo is on so page can present link back to thumbnail page
set page_num [pa_page_of_photo_in_album $photo_id $album_id]

set photo_nav_html [pa_pagination_bar $photo_id [pa_all_photos_in_album $album_id] "photo?photo_id=" photo]

pa_clipboards_multirow -create_new -force_default $user_id clipboards

#proc pa_clipboards_get -photo_id $photo_id -multirow clipped

db_multirow clipped get_clips { 
SELECT c.collection_id, c.title 
  FROM pa_collections c, pa_collection_photo_map m 
 WHERE m.photo_id = :photo_id 
   and m.collection_id = c.collection_id 
   and owner_id = :user_id
 ORDER BY c.title
}
