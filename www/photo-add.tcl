# /packages/photo-album/www/photo-add.tcl

ad_page_contract {

    Upload a photo to an existing album

    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 12/10/2000
    @cvs-id $Id$
} {
    album_id:integer,notnull
} -validate {
    valid_album -requires {album_id:integer} {
	if [string equal [pa_is_album_p $album_id] "f"] {
	    ad_complain "[_ photo-album._The_4]"
	}
    }
} -properties {
    album_id:onevalue
    context_list:onevalue
}

# check for read permission on folder
ad_require_permission $album_id pa_create_photo

set context_list [pa_context_bar_list -final "[_ photo-album._Upload]" $album_id]

set photo_id [db_string get_next_object_id "select acs_object_id_seq.nextval from dual"]

template::form create photo_upload -action photo-add-2 -html {enctype multipart/form-data}

template::element create photo_upload album_id  \
  -label "album_id" -datatype integer -widget hidden

template::element create photo_upload photo_id  \
  -label "photo_id" -datatype integer -widget hidden

template::element create photo_upload upload_file  \
  -label "[_ photo-album._Choose_2]" -help_text "[_ photo-album._Use]" -datatype text -widget file 

template::element create photo_upload caption -html { size 30 } \
  -label "<#_Caption#>" -optional -help_text "[_ photo-album.lt_OPTIONAL_Displayed_on]" -datatype text 

template::element create photo_upload description -html { size 50} \
  -label "[_ photo-album._Photo]" -optional -help_text "[_ photo-album.lt_OPTIONAL_Displayed_wh]" -datatype text

template::element create photo_upload story -html { cols 50 rows 4 wrap soft } \
  -label "[_ photo-album._Photo_1]" -optional -help_text "[_ photo-album.OPTIONAL]" -datatype text -widget textarea

template::element set_properties photo_upload album_id -value $album_id
template::element set_properties photo_upload photo_id -value $photo_id

ad_return_template


