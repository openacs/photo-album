ad_page_contract {

    Photo album front page.  List the albums and subfolders in the folder specified
    Uses package root folder if none specified

    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 12/7/2000
    @cvs-id $Id$
} {
    {folder_id:integer [pa_get_root_folder]}
} -validate {
    valid_folder -requires {folder_id:integer} {
	if [string equal [pa_is_folder_p $folder_id] "f"] {
	    ad_complain "The specified folder is not valid."
	}
    }
} -properties {
    context:onevalue
    folder_name:onevalue
    folder_description:onevalue
    folder_id:onevalue
    admin_p:onevalue
    subfolder_p:onevalue
    album_p:onevalue
    write_p:onevalue
    move_p:onevalue
    delete_p:onevalue
    child:multirow
}


# check for read permission on folder
ad_require_permission $folder_id read

set user_id [ad_conn user_id]
set context [pa_context_bar_list $folder_id]

# get all the info about the current folder and permissions with a single trip to database
db_1row get_folder_info {}

set root_folder_id [pa_get_root_folder]

# to move an album need write on album and write on parent folder
set move_p [expr $write_p && !($folder_id == $root_folder_id) && $parent_folder_write_p]

# to delete an album, album must be empty, need delete on album, and write on parent folder
set delete_p [expr !($has_children_p) && !($folder_id == $root_folder_id) && $folder_delete_p && $parent_folder_write_p]

if $has_children_p {
    db_multirow child get_children {}
} else {
    set child:rowcount 0
}

set collections [db_string collections {select count(*) from pa_collections where owner_id = :user_id}]

