# /packages/photo-album/www/photo-edit.tcl

ad_page_contract {

    Edit Photo Properties

    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 12/11/2000
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
    path:onevalue
    height:onevalue
    width:onevalue
}

ad_require_permission $photo_id "write"

set user_id [ad_conn user_id]
set context_list [pa_context_bar_list -final "Edit Photo Attributes" $photo_id]

template::form create edit_photo

template::element create edit_photo photo_id -label "photo ID" \
  -datatype integer -widget hidden

template::element create edit_photo revision_id -label "revision ID" \
  -datatype integer -widget hidden

template::element create edit_photo previous_revision -label "previous_revision" \
  -datatype integer -widget hidden

template::element create edit_photo title -html { size 30 } \
  -label "Photo Title" -optional -datatype text

template::element create edit_photo caption -html { size 30 } \
  -label "Caption" -help_text "Displayed on the thumbnail page" -optional -datatype text

template::element create edit_photo description -html { size 50} \
  -label "Photo Description" -help_text "Displayed when viewing the photo" -optional -datatype text

template::element create edit_photo story -html { cols 50 rows 4 wrap soft } \
  -label "Photo Story" -optional -datatype text  -help_text "Displayed when viewing the photo" -widget textarea

# moved outside is_request_block so that vars exist during form error reply

db_1row get_photo_info {}

set path $image_id

if { [template::form is_request edit_photo] } {
    set revision_id [db_string get_next_object_id "select acs_object_id_seq.nextval from dual"]
    template::element set_properties edit_photo revision_id -value $revision_id
    template::element set_properties edit_photo photo_id -value $photo_id
    template::element set_properties edit_photo previous_revision -value $previous_revision
    template::element set_properties edit_photo title -value $title
    template::element set_properties edit_photo description -value $description
    template::element set_properties edit_photo story -value $story
    template::element set_properties edit_photo caption -value $caption
}

if { [template::form is_valid edit_photo] } {
    set photo_id [template::element::get_value edit_photo photo_id]
    set revision_id [template::element::get_value edit_photo revision_id]
    set new_title [template::element::get_value edit_photo title]
    set new_desc [template::element::get_value edit_photo description]
    set new_story [template::element::get_value edit_photo story]
    set new_caption [template::element::get_value edit_photo caption]
    set previous_revision [template::element::get_value edit_photo previous_revision]
    set peeraddr [ad_conn peeraddr]
    
    db_transaction {
	db_exec_plsql update_photo_attributes {} 

	db_dml insert_photo_attributes {}
	
	# for now all the attributes about the specific binary file stay the same
	# not allowing users to modify the binary yet
	# will need to modify thumb and view binaries when photo binary is changed 

	db_dml update_photo_user_filename {} 

	db_exec_plsql set_live_revision {} 
    
    } on_error {
	ad_return_complaint 1 "An error occurred while processing your input. Please let the system owner know about this.
	  <pre>$errmsg</pre>"
	
	ad_script_abort
    }

    ad_returnredirect "photo?photo_id=$photo_id"
    ad_abort_script
}

ad_return_template
