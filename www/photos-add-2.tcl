# /packages/photo-album/www/photos-add-2.tcl
ad_page_contract {
    Upload a collection of photos from a tar or zip file.
    
    Process and insert photos.

    @author Jeff Davis (davis@xarg.net)
    @creation-date 6/28/2002
    @cvs_id $Id$
} {
    upload_file:trim,optional
    upload_file.tmpfile:optional,tmpfile
    directory:trim,optional
    album_id:integer,notnull
} -validate {
    valid_album -requires {album_id:integer} {
	if [string equal [pa_is_album_p $album_id] "f"] {
	    ad_complain "The specified album is not valid."
	}
    }
    non_empty -requires {upload_file.tmpfile:notnull} {
	if {![empty_string_p $upload_file] && (![file exists ${upload_file.tmpfile}] || [file size ${upload_file.tmpfile}] < 4)} {
	    ad_complain "The upload failed or the file was empty"
	}
    }
    directory_exists -requires {directory:notnull} {
        if {![empty_string_p $directory] && ![file isdirectory $directory]} { 
	    ad_complain "The directory file does not exist"
        }
    }
    directory_tmp -requires {directory:notnull} {
        if {![empty_string_p $directory] 
	    && !([ad_conn user_id] == 2599 || [ad_conn user_id] == 2601) 
	    && ( ![string match "/tmp/pa-tmp" $directory ] || [string match ".." $directory]) } { 
            ad_complain "You can currently only load images from /tmp/pa-tmp for security"
        }
    }
} 

#check permission
set user_id [ad_conn user_id]

ad_require_permission $album_id "pa_create_photo"

if { ![empty_string_p $upload_file] && 
     [ catch {set tmp_dir [pa_expand_archive $upload_file ${upload_file.tmpfile} pa-$album_id] } errMsg] } { 
    ad_return_complaint 1 "Unable to expand your archive file"
    ad_script_abort
} 
ReturnHeaders text/html
ns_write "<html><head><title>Upload Log</title></head><body><h1>Upload log</h1><hr>\n"


if {![empty_string_p $upload_file]} { 
    if {[info exists directory] && ![empty_string_p $directory]} { 
	ns_write "Uploading file only...please submit your directory based upload seperately<br>"
    }
    ns_write "starting to load images from file $upload_file<br>\n"
    ns_log Debug "made directory $tmp_dir to extract from ${upload_file.tmpfile} ($upload_file)\n"
    set allfiles [pa_walk $tmp_dir]
    set remove 1
} else { 
    ns_write "starting to load images from directory $directory<br>\n"
    set allfiles [pa_walk $directory]
    set remove 0
}     

set new_photo_ids [pa_load_images -remove $remove $allfiles $album_id $user_id]

pa_flush_photo_in_album_cache $album_id 

set page [pa_page_of_photo_in_album [lindex $new_photo_ids 0] $album_id]
ns_write "<a href=\"album?album_id=$album_id&page=$page\">View the images</a>"
ns_write "</body></html>"

# Now that we are done working on the upload we delete the tmp file
if [info exists tmp_dir] { 
    file delete -force $tmp_dir
}
