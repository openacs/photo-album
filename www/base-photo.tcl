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
}

if {![string equal [ad_parameter AllowBasePhotoAccessP] "t"]} {
    ad_return_forbidden "No Access" "The Administrator of this sub-site has restricted access base photos."
    ad_script_abort
}

ad_require_permission $photo_id "read"

set user_id [ad_conn user_id]
set context [pa_context_bar_list -final "Full Size Image" $photo_id]

# query all the photo and permission info with a single trip to database
db_1row get_photo_info {select
 pp.caption,
 pp.story,
 cr.title,
 cr.description,
 i.height as height,
 i.width as width,
 i.image_id as image_id,
 ci.parent_id as album_id
from cr_items ci,
  cr_revisions cr,
  pa_photos pp,
  cr_items ci2,
  cr_child_rels ccr2,
  images i
where cr.revision_id = pp.pa_photo_id
  and ci.live_revision = cr.revision_id
  and ci.item_id = ccr2.parent_id
  and ccr2.child_id = ci2.item_id
  and ccr2.relation_tag = 'base'
  and ci2.live_revision = i.image_id
  and ci.item_id = :photo_id
}
set path $image_id

# determine what album page the photo is on so page can present link back to thumbnail page
set page_num [pa_page_of_photo_in_album $photo_id $album_id]

set photo_nav_html [pa_pagination_bar $photo_id [pa_all_photos_in_album $album_id] "base-photo?photo_id="]

ad_return_template

