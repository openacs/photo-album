# /packages/photo-album/www/photos-add.tcl

ad_page_contract {
    Upload a collection of photos from a tar or zip file.
    Initial form data

    @author Jeff Davis (davis@xorch.net)
    @creation-date 6/28/2002
    @cvs_id $Id$
} {
    album_id:integer,notnull
} -validate {
    valid_album -requires {album_id:integer} {
	if [string equal [pa_is_album_p $album_id] "f"] {
	    ad_complain "[_ photo-album._The_1]"
	}
    }
} -properties {
    album_id:onevalue
    context:onevalue
}

# check for read permission on folder
ad_require_permission $album_id pa_create_photo

set context [pa_context_bar_list -final "[_ photo-album._Upload]" $album_id]

set photo_id [db_string get_next_object_id "select acs_object_id_seq.nextval from dual"]

form create photos_upload -action photos-add-2 -html {enctype multipart/form-data}

element create photos_upload album_id  \
  -label "album_id" -datatype integer -widget hidden

form::section photos_upload Either

element create photos_upload upload_file  \
  -label "[_ photo-album._Choose_3]" -help_text "[_ photo-album._Use_1]" -datatype text -widget file -optional

form::section photos_upload Or

element create photos_upload directory -html { size 50} \
    -label "Upload photos from the server directory" -help_text "[_ photo-album._the]" -datatype text -value "[parameter::get -parameter FullTempPhotoDir -package_id [ad_conn package_id]]" -widget text -mode display

element set_properties photos_upload album_id -value $album_id

ad_return_template


