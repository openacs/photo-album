# /packages/photo-album/www/folder-edit.tcl

ad_page_contract {

    Edit a folder's attributes

    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 12/8/2000
    @cvs-id $Id$
} {
    folder_id:integer,notnull
} -validate {
    valid_folder -requires {folder_id:integer} {
	if [string equal [pa_is_folder_p $folder_id] "f"] {
	    ad_complain "The specified folder is not valid."
	}
    }
} -properties {
    context_list:onevalue
}

# check for permission
ad_require_permission $folder_id write

set context_list [pa_context_bar_list -final "Edit Folder Attributes" $folder_id]

template::form create folder_edit

template::element create folder_edit folder_id -label "Folder ID" \
  -datatype integer -widget hidden

template::element create folder_edit label -html { size 30 } \
  -label "Folder Name" -datatype text

template::element create folder_edit description -html { size 50 } \
  -label "Folder Description" -optional -datatype text 

set title [pa_get_folder_name $folder_id]

if { [template::form is_request folder_edit] } {
    template::element set_properties folder_edit folder_id -value $folder_id
    template::element set_properties folder_edit label -value $title
    template::element set_properties folder_edit description -value [pa_get_folder_description $folder_id]
}

if { [template::form is_valid folder_edit] } {
    # vaild new sub-folder submission so create new subfolder

    set folder_id [template::element::get_value folder_edit folder_id]
    set label [template::element::get_value folder_edit label]
    set description [template::element::get_value folder_edit description]

    # edit the folder
    db_transaction {

	db_exec_plsql edit_folder {
	    begin
	    content_folder.rename (
            folder_id  => :folder_id,
            label => :label,
            description  => :description
	    );
	    end;
	}
    
    } on_error {
	ad_return_complaint 1 "An error occurred while processing your input. Please let the system owner know about this.
	  <pre>$errmsg</pre>"
	
	ad_script_abort
    }
    #redirect back to index page with parent_id

    ad_returnredirect "?folder_id=$folder_id"

    ad_script_abort
}

ad_return_template
