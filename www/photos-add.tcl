# /packages/photo-album/www/photos-add.tcl

ad_page_contract {
    Upload a collection of photos from a tar or zip file.
    Initial form data

    @author Jeff Davis (davis@xarg.net)
    @creation-date 6/28/2002
    @cvs_id $Id$
} {
    album_id:integer,notnull
} -validate {
    valid_album -requires {album_id:integer} {
	if [string equal [pa_is_album_p $album_id] "f"] {
	    ad_complain "The specified album is not valid."
	}
    }
} -properties {
    album_id:onevalue
    context:onevalue
}

# check for read permission on folder
ad_require_permission $album_id pa_create_photo

set context [pa_context_bar_list -final "Upload photos" $album_id]

set photo_id [db_string get_next_object_id "select acs_object_id_seq.nextval from dual"]

template::form create photos_upload -action photos-add-2 -html {enctype multipart/form-data}

template::element create photos_upload album_id  \
  -label "album_id" -datatype integer -widget hidden

template::form::section photos_upload Either

template::element create photos_upload upload_file  \
  -label "Choose a tar or zip file to upload" -help_text "Use the \"Browse...\" button to locate your file, then click \"Open\"" -datatype text -widget file

template::form::section photos_upload Or

template::element create photos_upload directory -html { size 50} \
  -label "Or choose a server directory to upload" -help_text "the directory must exist on server and be readable by the server process" -datatype text -widget text

template::element set_properties photos_upload album_id -value $album_id

ad_return_template


