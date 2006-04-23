# /packages/photo-album/www/album-add.tcl

ad_page_contract {

    Export an existing album

    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 12/8/2000
    @cvs-id $Id$
} {
    album_id:integer,notnull
    {path ""}
} -validate {
} -properties {
    context_list:onevalue
}

# Create the folder
if {[empty_string_p $path]} {
    set path [ns_tmpnam]
    file mkdir $path
}

foreach photo_id [pa_all_photos_in_album $album_id] {
    
    # query all the photo and permission info with a single trip to database
    if {![db_0or1row get_photo_info {}]} {
	ad_return_error "[_ photo-album.No_Photo]" "[_ photo-album.lt_No_Photo_was_found_fo]"
    } else {
	db_1row select_object_metadata {}

	set storage_type "file"
	# Now write the file
	switch $storage_type {
	    lob {

		    # FIXME: db_blob_get_file is failing when i use bind variables

		    # DRB: you're out of luck - the driver doesn't support them and while it should
		    # be fixed it will be a long time before we'll want to require an updated
		    # driver.  I'm substituting the Tcl variable value directly in the query due to
		    # this.  It's safe because we've pulled the value ourselves from the database,
		    # don't need to worry about SQL smuggling etc.

		db_blob_get_file select_object_content {} -file [file join ${path} ${file_name}]
	    }
	    text {
		set content [db_string select_object_content {}]

		set fp [open [file join ${path} ${file_name}] w]
		    puts $fp $content
		    close $fp
	    }
	    file {
		set cr_path [cr_fs_path $storage_area_key]
		set cr_file_name [db_string select_file_name {}]

		file copy -- "${cr_path}${cr_file_name}" [file join ${path} ${file_name}]
	    }
	}
    }
}