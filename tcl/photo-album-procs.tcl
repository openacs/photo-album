# /packages/photo-album/tcl/photo-album-procs.tcl
ad_library {
    TCL library for the photo-album system

    @author Tom Baginski (bags@arsdigita.com)
    @author Jeff Davis (davis@xorch.net)

    @creation-date December 14, 2000
    @cvs-id $Id$
}

# wtem@olywa.net, 2001-09-19
# there are several procs that we may be able to replace 
# with standard cr procs now that it handles file system storage of images
# look for ### maybe redundant, replace calls?
# in front of said procs
# places to make partial changes are marked with
### probable partial change
# in front of them
# areas that have been worked on are marked
### clean
# changes that have been deferred marked
### skipped

ad_proc -public pa_get_root_folder {
    {package_id ""}
} {
    Returns the folder_id of the root folder for an instance of the photo album system.
    If no root folder exists, as when a new package instance is accessed for the first time,
    a new root folder is created automatically with appropriate permissions
    If value has be previously requested, value pulled from cache
} { 
    if [empty_string_p $package_id] {
	set package_id [ad_conn package_id]
    }
    return [util_memoize "pa_get_root_folder_internal $package_id"]
}

ad_proc -private pa_get_root_folder_internal {
    {package_id}
} {
    Returns the folder_id of the root folder for an instance of the photo album system.
    If no root folder exists, as when a new package instance is accessed for the first time,
    a new root folder is created automatically with appropriate permissions
} {
    set folder_id [db_string pa_root_folder "select photo_album.get_root_folder(:package_id) from dual"]

    if [empty_string_p $folder_id] {
	set folder_id [pa_new_root_folder $package_id]
    }
    return $folder_id
}

ad_proc -private pa_new_root_folder {
    {package_id ""}
} {
    Creates a new root folder for a package, and returns id.
    A hackish function to get around the fact that we can't run
    code automatically when a new package instance is created.

} {
    if [empty_string_p $package_id] {
	set package_id [ad_conn package_id]
    }

    # wtem@olywa.net, 2001-09-22
    # the PhotoDir parameter goes away with new CR storage scheme

    # wtem@olywa.net, 2001-09-22
    # original pl/sql wrapped up in function to simplify code and porting
    db_transaction {
	# create new root folder
    
	set new_folder_id [db_exec_plsql make_new_root {
	begin
	:1 := photo_album.new_root_folder(:package_id);
	end;
	}]
    
	# grant default permissions to new root folder

	# default permissions stored in package parmeter as a list of grantee privilege pairs
	# the grantee can be anything that is or returns a party_id such as an integer, a subquery,
	# or a function
	
	set perm_lst [split [ad_parameter DefaultRootFolderPrivileges] " "]

	foreach {party privilege}  $perm_lst {
	    # wtem@olywa.net, 2001-10-15
	    # urgh, originally the parameter had the pl/sql embedded in it
	    set grantee_id [db_string get_grantee_id "select acs.magic_object_id('$party') from dual"]
	  
	    db_exec_plsql grant_default {
		begin
		  acs_permission.grant_permission (
	            object_id  => :new_folder_id,
	            grantee_id => :grantee_id,
	            privilege  => :privilege
		  );
		end;
	    }
	}
    }
    # since this is executed the first time a package instance is accessed,
    # make sure the upload dir exists

    ### probable partial change
    # wtem@olywa.net, 2001-09-19
    # this initializes corresponding directory structure in the file-system
    # we should be able to eliminate this now that we are using CR storage
    # pa_assert_dir -check_base_path ""
    ### clean
    return $new_folder_id
}

ad_proc -public pa_get_folder_name {
    folder_id
} {
    Returns the name of a folder. 
} {
    return [db_string folder_name "
    select content_folder.get_label(:folder_id) from dual"]
}

ad_proc -public pa_get_folder_description {
    folder_id
} {
    Returns the description of a folder. 
} {
    return [db_string folder_description "
    select description from cr_folders where folder_id = :folder_id"]
}


ad_proc pa_context_bar_list {
    {-final ""}
    item_id
} {
    Constructs the list to be fed to ad_context_bar appropriate for
    item_id.  If -final is specified, that string will be the last 
    item in the context bar.  Otherwise, the name corresponding to 
    item_id will be used.

    modified from fs_context_bar
} {
    set root_folder_id [pa_get_root_folder]

    if {$item_id == $root_folder_id} {
	return
    }

    if [empty_string_p $final] {
	# set start_id and final with a single trip to the database

	db_1row get_start_and_final "select parent_id as start_id,
	  content_item.get_title(item_id,'t') as final
	  from cr_items where item_id = :item_id"

	#set start_id [db_string parent_id "
	#select parent_id from cr_items where item_id = :item_id"]
	#set final [db_string title "select content_item.get_title(:item_id,'t') from dual"]

    } else {
	set start_id $item_id
    }

    if {$start_id != $root_folder_id} {
    set context_bar [db_list_of_lists context_bar "
    select decode(
             content_item.get_content_type(i.item_id),
             'content_folder',
             'index?folder_id=',
             'pa_album',             
             'album?album_id=',
             'photo?photo_id='
           ) || i.item_id,
           content_item.get_title(i.item_id,'t')
    from   cr_items i
    connect by prior i.parent_id = i.item_id
      and i.item_id != :root_folder_id
    start with item_id = :start_id
    order by level desc"]
    }
    lappend context_bar $final

    return $context_bar
}

# wtem@olywa.net, 2001-09-24
### clean
ad_proc -public pa_make_file_name {
    {-ext ""}
    id
} { 
    constructs a filename for an image based on id and extention.
} {
    if {![empty_string_p $ext] && ![regexp {^\.} $ext foo]} {
	#add back the dot
	set ext ".${ext}"
    }
    set total_file_name "${id}${ext}"

    return $total_file_name
}

### maybe redundant, replace calls?
# wtem@olywa.net, 2001-09-22
### skipped
# will handle when we get to the places where this is called
ad_proc -private pa_assert_dir {
    {-check_base_path:boolean}
    {dir_path}
} {
    Ensures that dirname exists under the PhotoDir Directory  
    If -check_base_path flag specified, proc also checks if base path exists and adds it if necessary

    Won't cause an error if the directory is already there. Better than the stardard
    mkdir because it will make all the directories leading up to dirname
    borrowed from 3.4 download code
} {  
    ns_log Debug "Checking dir, pa_assert_dir"
    if { $check_base_path_p } {
	set dir_path "[acs_root_dir]/[ad_parameter PhotoDir]/$dir_path"
	set needed_dir ""
    } else {
	set needed_dir "[acs_root_dir]/[ad_parameter PhotoDir]"
    }
    ns_log Debug "dir_path: $dir_path \n needed_dir: $needed_dir"
    
    set dir_list [split $dir_path /]
    
    foreach dir $dir_list {
	ns_log Debug "Checking: $dir"
        if [empty_string_p $dir] {
            continue
        }
        append needed_dir "/$dir"
        if ![file exists $needed_dir] {
	    ns_log Debug "Making: $dir"
            ns_mkdir $needed_dir
        }
    }
}

ad_proc -public pa_is_folder_p {
    folder_id
    {package_id ""}
} {
    returns "t" if folder_id is a folder that is a child of the root folder for the package,
    else "f"
}  {
    return [pa_is_type_in_package $folder_id "content_folder" $package_id]
}

ad_proc -public pa_is_album_p {
    album_id
    {package_id ""}
} {
    returns "t" if album_id is a pa_album that is a child of the root folder for the package,
    else "f"
}  {
    return [pa_is_type_in_package $album_id "pa_album" $package_id]
}

ad_proc -public pa_is_photo_p {
    photo_id
    {package_id ""}
} {
    returns "t" if photo_id is a pa_photo that is a child of the root folder for the package,
    else "f"
}  {
    return [pa_is_type_in_package $photo_id "pa_photo" $package_id]
}

ad_proc -private pa_is_type_in_package {
    item_id
    content_type
    {package_id ""}
} {
    returns "t" if item_id is of the specified content_type and is a child of the root folder of the package,
    else returns "f"
} {
    set root_folder [pa_get_root_folder $package_id]

    # I check for the case that item is the root_folder first because this happens on the index page.
    # Since index page accessed often, and the root_folder is within the package this avoids an unecessary
    # trip to the database on a commonly accessed page.
 
    if {[string equal $content_type "content_folder"] && [string equal $item_id $root_folder]} {
	return "t"
    } else {
	return [db_string check_is_type_in_package "select decode((select 1 
	from dual
	where exists (select 1 
	    from cr_items 
	    where item_id = :root_folder 
	    connect by prior parent_id = item_id 
	    start with item_id = :item_id)
	  and content_item.get_content_type(:item_id) = :content_type
	), 1, 't', 'f')
	from dual" ]
    }
}

ad_proc -public pa_grant_privilege_to_creator {
    object_id
    {user_id ""}
} {
    Grants a set of default privileges stored in parameter PrivilegeForCreator
    on object id to user_id.  If user_id is not specified, uses current user.
} {
    if {[empty_string_p $user_id]} {
	set user_id [ad_conn user_id]
    }
    set grant_list [split [ad_parameter PrivilegeForCreator] ","]
    foreach privilege $grant_list {
	db_exec_plsql grant_privilege {
	    begin
	      acs_permission.grant_permission (
	        object_id  => :object_id,
	        grantee_id => :user_id,
	        privilege  => :privilege
	      );
	    end;
	}
    } 
}

ad_proc -public pa_image_width_height {
    filename
    width_var
    height_var
} {
    Uses ImageMagick program to get the width and height in pixels of filename.
    Sets height to the variable named in height_var in the calling level.
    Sets width_var to the variable named in width_var in the calling level.

    I Use ImageMagick instead of aolserver function because it can handle more than
    just gifs and jpegs.  
} {
    set identify_string [exec identify $filename]
    regexp {[ ]+([0-9]+)[x]([0-9]+)[\+]*} $identify_string x width height
    uplevel "set $width_var $width"
    uplevel "set $height_var $height"
}

ad_proc -public pa_make_new_image {
    base_image
    new_image
    geometry
} {
    Uses ImageMagick program to create a file named new_image from base_image that 
    fits within a box defined by geometry.  If geometry is just a number it will 
    be used for both width and height.

    ImageMagick will retain the aspect ratio of the base_image when creating the new_image
     
     jhead -dt is called to delete any embeded thumbnail since digital camera thumbnails
     can be quite large and imagemagick does not remove them when converting (so thumbnails
     can end up being 8k for the thumbnail + 32k for the embeded thumbnail). 

    @param base_image original image filename 
    @param new_image new image filename 
    @param geometry string as passed to convert 

} {
    # If we get an old style single number
    if {[regexp {^[0-9]+$} $geometry]} { 
        set geometry ${geometry}x${geometry}
    }
    ns_log debug "pa_make_new_image: Start convert, making $new_image geometry $geometry"
    exec convert -geometry $geometry -interlace None -sharpen 1x2 $base_image $new_image
    exec jhead -dt $new_image
    ns_log debug "pa_make_new_image: Done convert for $new_image"
}

# wtem@olywa.net, 2001-09-22
# replaced pa_delete_scheduled_files with standard cr_delete_scheduled_files


ad_proc -public pa_all_photos_in_album {
    album_id
} {
    returns a list of all the photo_ids in an album sorted in ascending order
    pull value from cache if already there, caches result and returns result if not
} {
    return [util_memoize "pa_all_photos_in_album_internal $album_id"]
}

ad_proc -private pa_all_photos_in_album_internal {
    album_id
} {
    queries and returns a list of all photo_ids in album_id in ascending order 
} {
    return [db_list get_photo_ids {}]
}

ad_proc -public pa_count_photos_in_album {
    album_id
} {
    returns count of number of photos in album_id
} {  
    return [llength [pa_all_photos_in_album $album_id]]
}

ad_proc -public pa_all_photos_on_page {
    album_id 
    page
} {
    returns a list of the photo_ids on page page of album_id
    list is in ascending order
} {
    set images_per_page [ad_parameter ThumbnailsPerPage]
    set start_index [expr $images_per_page * ($page-1)]
    set end_index [expr $start_index + ($images_per_page - 1)]
    return [lrange [pa_all_photos_in_album $album_id] $start_index $end_index]
}

ad_proc -public pa_count_pages_in_album {
    album_id
} {
    returns the number of pages in album_id
} {
    return [expr int(ceil([pa_count_photos_in_album $album_id] / [ad_parameter ThumbnailsPerPage].0))]
}

ad_proc -public pa_page_of_photo_in_album {
    photo_id
    album_id
} {
    returns the page number of a photo in an album
    If photo is not in the album returns -1
} {
    set photo_index [lsearch [pa_all_photos_in_album $album_id] $photo_id]

    if {$photo_index == -1 } {
	return -1
    }

    return [expr int(ceil(($photo_index + 1)/ [ad_parameter ThumbnailsPerPage].0))]
}

ad_proc -public pa_flush_photo_in_album_cache {
    album_id
} {
    Clears the cacheed value set by pa_all_photos_in_album for a single album
    Call proc on any page that alters the number or order of photos in an album.
} {
    util_memoize_flush "pa_all_photos_in_album_internal $album_id"
}

# pagination procs based on cms pagintion-procs.tcl
# when these procs get rolled into acs distribution, should use them directly

ad_proc -deprecated pa_pagination_paginate_query { 
    sql
    page
} {
    takes a query and returns a query that accounts for pagination
} {

    set rows_per_page [ad_parameter ThumbnailsPerPage]
    set start_row [expr $rows_per_page*[expr $page-1]+1]

    set query "
      select *
      from
        (
          select 
            x.*, rownum as row_id
	  from
	    ($sql) x
        ) ordered_sql_query_with_row_id
      where
        row_id between $start_row and $start_row + $rows_per_page - 1"
    
    return $query
}

ad_proc -deprecated pa_pagination_get_total_pages {} {
    returns the total pages in a datasource defined by $sql
    The sql var must be defined at the calling level.
    Uplevel used so that any binde vars in query are defined
} {
    uplevel {
	return [db_string get_total_pages "
	select 
	ceil(count(*) / [ad_parameter ThumbnailsPerPage])
	from
	($sql)
	"]
    }
}

ad_proc -private pa_pagination_ns_set_to_url_vars { 
    set_id
} {
    helper procedure - turns an ns_set into a list of url_vars
} {
    set url_vars {}
    set size [ns_set size $set_id]
    for { set i 0 } { $i < $size } { incr i } {
	set key [ns_set key $set_id $i]
	set value [ns_set get $set_id $key]
	lappend url_vars "$key=$value"
    }

    return [join $url_vars "&amp;"]
}


ad_proc -public pa_pagination_context_ids {
    curr 
    ids
    {context 4}
} { 
    set out {}
    set n_ids [llength $ids]

    # if the list is short enough just return it.
    if {$n_ids < 13} {
        set i 1
        foreach id $ids { 
            lappend out $id $i
            incr i
        }
        return $out
    }

    # what is the range about which to bracket
    set start [expr [lsearch -exact  $ids $curr ] - $context]
    
    if {[expr $start + 2 * $context + 1] > $n_ids} { 
        set start [expr $n_ids - 2 * $context - 1]
    } 
    if {$start < 0} { 
        set start 0
    } 

    # tack on 1
    if {$start > 0} { 
        lappend out [lindex $ids 0] 1
    }

    # context
    foreach id [lrange $ids $start [expr $start + 2 * $context]] { 
        incr start
        lappend out $id $start
    }

    # tack on last
    if {$start < $n_ids} { 
        lappend out [lrange $ids end end] $n_ids
    }

    return $out
}


ad_proc -public pa_pagination_bar { 
    cur_id
    all_ids
    link
    {what {}}
} {
    given a current photo_id and and an ordered list of all the photo_id in an album
    creates an html fragment that allows user to navigate to any photo by number 
    next/previous
} {
    if { [empty_string_p $cur_id] || [llength $all_ids] < 2 } {
	return ""
    }

    set cur_index [lsearch -exact $all_ids $cur_id]
    set prev_id [lindex $all_ids [expr $cur_index - 1]]
    set next_id [lindex $all_ids [expr $cur_index + 1]]
    set photo_nav_html ""
    if {![empty_string_p $what]} { 
        set what "&nbsp;$what"
    }
    # append the 'prev' link
    append photo_nav_html "<div class=\"photo_album_nav\">\n"
    if { ![empty_string_p $prev_id] } {
	append photo_nav_html "\t<div style=\"text-align: left; float: left; margin-right: 1em; margin-bottom: 1em\">\n\t\t<a href=\"${link}$prev_id\">&lt;&lt;&nbsp;Prev$what</a>\n\t</div>\n"
    }
    # append the 'next' link
    if { ![empty_string_p $next_id] } {
	append photo_nav_html "\t<div style=\"text-align: right; float: right; margin-left: 1em; margin-bottom: 1em\">\n\t\t<a href=\"${link}$next_id\">Next$what&nbsp;&gt;&gt;</a>\n\t</div>\n"
    }

    # append page number links for all pages except for this page
    append photo_nav_html "\t<div style=\"text-align: center\">\n"
    set i 0
    set last {}
    foreach {id i} [pa_pagination_context_ids $cur_id $all_ids 4] {
        if {![empty_string_p $last] && [expr $last + 1] != $i} {
            append photo_nav_html "&#8226;"
        } 
        set last $i
	if { $cur_id == $id } {
	    append photo_nav_html "\t\t<strong>$i</strong>\n"
	} else {
	    append photo_nav_html "\t\t<a href=\"${link}$id\">$i</a>\n"
	}
	
    }
    append photo_nav_html "\t</div>\n"

    append photo_nav_html "</div>\n"
    return $photo_nav_html
}


ad_proc -public pa_expand_archive {
    upload_file 
    tmpfile 
    {dest_dir_base "extract"} 
} { 
    Given an uploaded file in file tmpfile with original name upload_file 
    extract the archive and put in a tmp directory which is the return value 
    of the function 
} {
    set tmp_dir [file join [file dirname $tmpfile] [ns_mktemp "$dest_dir_base-XXXXXX"]]
    if [catch { ns_mkdir $tmp_dir } errMsg ] {
        ns_log Notice "expand_archive: Error creating directory $tmp_dir: $errMsg"
        return -code error "expand_archive: Error creating directory $tmp_dir: $errMsg"
    }

    set upload_file [string trim [string tolower $upload_file]]

    if {[regexp {(.tar.gz|.tgz)$} $upload_file]} { 
        set type tgz
    } elseif {[regexp {.tar.z$} $upload_file]} { 
        set type tgZ
    } elseif {[regexp {.tar$} $upload_file]} { 
        set type tar
    } elseif {[regexp {(.tar.bz2|.tbz2)$} $upload_file]} { 
        set type tbz2
    } elseif {[regexp {.zip$} $upload_file]} { 
        set type zip
    } else { 
        set type "Unknown type"
    }

    switch $type { 
        tar {
            set errp [ catch { exec tar --directory $tmp_dir -xvf $tmpfile } errMsg]
        }
        tgZ { 
            set errp [ catch { exec tar --directory $tmp_dir -xZvf $tmpfile } errMsg]
        }
        tgz { 
            set errp [ catch { exec tar --directory $tmp_dir -xzvf $tmpfile } errMsg]
        }
        tbz2 { 
            set errp [ catch { exec tar --directory $tmp_dir -xjvf $tmpfile } errMsg]
        }
        zip { 
            set errp [ catch { exec unzip -d $tmp_dir $tmpfile } errMsg]
        }
        default { 
            set errp 1 
            set errMsg "don't know how to extract $upload_file"
        }
    }
    
    if {$errp} { 
        file delete -force $tmp_dir
        ns_log Notice "expand_archive: extract type $type failed $errMsg"
        return -code error "expand_archive: extract type $type failed $errMsg"
    } 
    return $tmp_dir
}

ad_proc -public pa_walk { 
    dir
} {
    Walk starting at a given directory and return a list
    of all the plain files found
} { 
    set files [list]
    foreach f [glob -nocomplain [file join $dir *]] {
        set type [file type $f]
        switch $type { 
            directory { 
                set files [concat $files [pa_walk $f]]
            }
            file {
                lappend files $f 
            }
            default { 
                # Goofy file types -- just ignore them
            }
        }
    }
    return $files
}      

ad_proc -public  pa_file_info {
    file 
} {
    return the image information from a given file
} { 
    set info [list]
    if { [catch {set size [file size $file]} errMsg] } { 
        return -code error $errMsg
    } 
    if { [ catch {set out [exec identify -ping -format "%w %h %m %k %q %#" $file]} errMsg]} { 
        return -code error $errMsg
    }            
    
    foreach {width height type colors quantum sha256} [split $out { }] {}
    switch $type { 
        JPG - JPEG {
            set mime image/jpeg
        } 
        GIF - GIF87 { 
            set mime image/gif
        } 
        PNG { 
            set mime image/png
        } 
        TIF - TIFF { 
            set mime image/tiff
        }
        default { 
            set mime {} 
        }
    }
    
    return [list $size $width $height $type $mime $colors $quantum [string trim $sha256]]
}           


ad_proc -public pa_insert_image { 
    name
    photo_id
    item_id
    rev_id
    user_id
    peeraddr
    context_id
    title
    description
    mime_type
    relation
    is_live
    path
    height
    width
    size
} { 
    db_exec_plsql pa_insert_image {
        declare 
        dummy  integer;
        begin

        dummy := image.new (
                            name            => :name,
                            parent_id       => :photo_id,
                            item_id         => :item_id,
                            revision_id     => :rev_id,
                            creation_date   => sysdate,
                            creation_user   => :user_id,
                            creation_ip     => :peeraddr,
                            context_id      => :context_id,
                            title           => :title,
                            description     => :description,
                            mime_type       => :mime_type,
                            relation_tag    => :relation,
                            is_live         => :is_live,
                            path            => :path,
                            height          => :height,
                            width           => :width,
                            file_size       => :size
                            );
        end;
    }
}

ad_proc -public pa_load_images {
    {-remove 0}
    {-client_name {}}
    {-strip_prefix {}}
    {-description {}}
    {-story {}}
    {-caption {}}
    image_files 
    album_id 
    user_id
} { 
    load a list of files to the provided album owned by user_id

    -remove 1 to delete the file after moving to the content repository
    -client_name provide the name of the upload file (for individual uploads)
    -strip_prefix the prefix to remove from the filename (for expanded archives)
    image_files list of files to process
} { 
    set new_ids [list]
    set peeraddr [ad_conn peeraddr]

    # Create the tmp dir if needed 
    set tmp_path [ad_parameter FullTempPhotoDir]
    if ![file exists $tmp_path] {
        ns_log Debug "Making: tmp_photo_album_dir_path $tmp_path"
        ns_mkdir $tmp_path
    }

    # Fix upload name if missing
    foreach image_file $image_files {


        # Figure out what to call the file...
        if [empty_string_p $client_name] { 
            set upload_name $image_file
        } else { 
            set upload_name $client_name
        }
        if {![empty_string_p $strip_prefix]} { 
            regsub "^$strip_prefix" $upload_name {} upload_name
        }

        if ![regexp {([^/\\]+)$} $upload_name match client_filename] {
            # couldn't find a match
            set client_filename $upload_name
        }

        if {[catch {set base_info [pa_file_info $image_file]} errMsg]} {
            ns_log Warning "Error parsing file data $image_file Error: $errMsg"
            continue
        }

        foreach {base_bytes base_width base_height base_type base_mime base_colors base_quantum base_sha256} $base_info { break }
        
        # If we don't have a mime type we like we try to make a jpg or png 
        #
        if [empty_string_p $base_mime] { 
            set new_image [file join $tmp_path "tmp-[file rootname [file tail $image_file]]"]
            if {![empty_string_p $base_colors] && $base_colors < 257} { 
                # convert it to a png
                if {[catch {exec convert $image_file PNG:$new_image.png} errMsg]} { 
                    ns_log Notice "Failed convert to PNG for $image_file (magicktype $base_type)" 
                }
                if { $remove } { 
                    file delete $image_file
                } 
                set image_file $new_image.png
                set remove 1
            } elseif {![empty_string_p $base_colors] && $base_colors > 256} { 
                # convert it to a jpg
                if {[catch {exec convert $image_file JPG:$new_image.jpg} errMsg]} { 
                    ns_log Notice "Failed convert to JPG for $image_file (magicktype $base_type)" 
                }
                if { $remove } { 
                    file delete $image_file
                } 
                set image_file $new_image.jpg
                set remove 1
            } else { 
                ns_log Notice "Is it even an image: $image_file $base_type"
            }

            # get info again
            foreach {base_bytes base_width base_height base_type base_mime base_colors base_quantum base_sha256} [pa_file_info $image_file] { break }
        }
        
        if {[string equal $base_mime image/jpeg]} { 
            array set exif [pa_get_exif_data ${image_file}]
        } else { 
            array unset exif
        }

        set BaseExt [string tolower $base_type]
        
        if [empty_string_p $base_mime] { 
            ns_log Notice "Photo-Album: Invalid image type $image_file $type even after convert!"
            continue 
        } 
          
        # Get all the IDs we will need 
        #
        foreach name [list photo_id photo_rev_id base_item_id base_rev_id thumb_item_id \
                          thumb_rev_id viewer_item_id viewer_rev_id] { 
            set $name [db_nextval "acs_object_id_seq"]
        }
        
        # Set the names we use in the content repository.
        #
        set image_name "${photo_rev_id}:$client_filename"
        set base_image_name "base_$client_filename"
        set vw_image_name "vw_$client_filename"
        set th_image_name "th_$client_filename"
        
        # Handle viewer file 
        #
        set viewer_size [ad_parameter ViewerSize]
        set viewer_filename [pa_make_file_name -ext $BaseExt $viewer_rev_id]
        set full_viewer_filename [file join ${tmp_path} ${viewer_filename}]
        pa_make_new_image $image_file ${full_viewer_filename} $viewer_size
        foreach {viewer_bytes viewer_width viewer_height viewer_type viewer_mime viewer_colors viewer_quantum viewer_sha256} [pa_file_info $full_viewer_filename] {}

        # Handle thumb file 
        #
        set thumb_size [ad_parameter ThumbnailSize]
        set thumb_filename [pa_make_file_name -ext $BaseExt $thumb_rev_id]
        set full_thumb_filename [file join $tmp_path $thumb_filename]
        pa_make_new_image ${full_viewer_filename} ${full_thumb_filename} $thumb_size
        foreach {thumb_bytes thumb_width thumb_height thumb_type thumb_mime thumb_colors thumb_quantum thumb_sha256} [pa_file_info $full_thumb_filename] {}

        # copy the tmp file to the cr's file-system
        set thumb_filename_relative [cr_create_content_file -move $thumb_item_id $thumb_rev_id ${full_thumb_filename}]
        set viewer_filename_relative [cr_create_content_file -move $viewer_item_id $viewer_rev_id ${full_viewer_filename}]
        if { $remove } { 
            set base_filename_relative [cr_create_content_file -move $base_item_id $base_rev_id $image_file]
        } else { 
            set base_filename_relative [cr_create_content_file $base_item_id $base_rev_id $image_file]
        }


        # Insert the mess into the DB
        #
        db_transaction {
            db_exec_plsql new_photo {
                declare 
                dummy  integer;
                begin

                dummy := pa_photo.new (
                                       name            => :image_name,
                                       parent_id       => :album_id,
                                       item_id         => :photo_id,
                                       revision_id     => :photo_rev_id,
                                       creation_date   => sysdate,
                                       creation_user   => :user_id,
                                       creation_ip     => :peeraddr,
                                       context_id      => :album_id,
                                       title           => :client_filename,
                                       description     => :description,
                                       is_live         => 't',
                                       caption         => :caption,
                                       story           => :story,
                                       user_filename   => :upload_name
                                       );
                end;
            }
            
            if {[array size exif] > 1} { 
                foreach {key value} [array get exif] { 
                    set tmp_exif_$key $value
                }

                # Check the datetime looks valid - clock scan works pretty well...
                if {[catch {clock scan $tmp_exif_DateTime}]} { 
                    set tmp_exif_DateTime {}
                }

                db_dml update_photo_data {}
            }

            pa_insert_image $base_image_name $photo_id $base_item_id $base_rev_id $user_id $peeraddr $photo_id $base_image_name "original image" $base_mime "base" "t" $base_filename_relative $base_height $base_width $base_bytes 
            pa_insert_image $th_image_name $photo_id $thumb_item_id $thumb_rev_id $user_id $peeraddr $photo_id $th_image_name "thumbnail" $thumb_mime "thumb" "t" $thumb_filename_relative $thumb_height $thumb_width $thumb_bytes 
            pa_insert_image $vw_image_name $photo_id $viewer_item_id $viewer_rev_id $user_id $peeraddr $photo_id $vw_image_name "web image" $viewer_mime "viewer" "t" $viewer_filename_relative $viewer_height $viewer_width $viewer_bytes 
            
            pa_grant_privilege_to_creator $photo_id $user_id

            lappend new_ids $photo_id
        } 

    }

    return $new_ids
}


ad_proc -public pa_get_exif_data {
    file
} {
    Returns a array get list with the some of the exif data 
    or an empty string if the file is not a jpg file
    
    uses jhead

    Keys: Aperture Cameramake Cameramodel CCDWidth DateTime Exposurebias
    Exposuretime Filedate Filename Filesize Film Flashused Focallength
    Focallength35 FocusDist Jpegprocess MeteringMode Resolution
} { 
    # a map from jhead string to internal tags.
    array set map [list {File date} Filedate \
                       {File name} Filename \
                       {File size} Filesize \
                       {Camera make} Cameramake \
                       {Camera model} Cameramodel \
                       {Date/Time} DateTime \
                       {Resolution} Resolution \
                       {Flash used} Flashused \
                       {Focal length} Focallength \
                       {Focal length35} Focallength35 \
                       {CCD Width} CCDWidth \
                       {Exposure time} Exposuretime \
                       {Aperture} Aperture \
                       {Focus Dist.} FocusDist \
                       {Exposure bias} Exposurebias \
                       {Metering Mode} MeteringMode \
                       {Jpeg process} Jpegprocess \
                       {Film} Film ]

    # try to get the data.
    if {[catch {set results [exec jhead $file]} errmsg]} { 
        return -code error $errmsg
    } elseif {[string match {Not JPEG:*} $results]} { 
        return {}
    }

    # parse data
    foreach line [split $results "\n"] { 
        regexp {([^:]*):(.*)} $line match tag value
        set tag [string trim $tag]
        set value [string trim $value]
        if {[info exists map($tag)]} { 
            set out($map($tag)) $value
        }
    }
    
    # make sure we have a value for every tag 
    foreach {dummy tag} [array get map] { 
        if {![info exists out($tag)]} { 
            set out($tag) {}
        }
    }

    # fix the annoying ones...
    foreach tag [list  Exposuretime FocusDist] { 
        if {[regexp {([0-9.]+)} $out($tag) match new]} {
            set out($tag) $new
        }
    }

    foreach tag [list  DateTime Filedate] { 
        regsub {([0-9]+):([0-9][0-9]):} $out($tag) "\\1-\\2-" out($tag)
    }

    if {[regexp {.*35mm equivalent: ([0-9]+).*} $out(Focallength) match new]} {
        set out(Focallength35) $new
    } else { 
        set out(Focallength35) {}
    }
    regsub {([0-9.]+)mm.*} $out(Focallength) "\\1" out(Focallength)

    if {[string equal -nocase $out(Flashused) yes]} { 
        set out(Flashused) 1
    } else { 
        set out(Flashused) 0
    }
    
    if {![empty_string_p $out(Cameramake)]} { 
        set out(Film) Digital
    }
    
    regsub {([0-9]+).*} $out(Filesize) "\\1" out(Filesize)

    return [array get out]
}


ad_proc -public pa_clipboards_multirow { 
    -create_new:boolean
    -force_default:boolean
    user_id
    datasource
} { 
    creates a multirow datasource with the existing clipboards

    @param create_new add a "Create new folder" entry to list 
    @param force_default create the datasource with a default folder even if none exist
    @param user_id the owner id for the folders 
    @param datasource the datasource name to use.

    @author Jeff Davis davis@xarg.net
    @creation-date 2002-10-30
} {

    db_multirow $datasource clipboards {select collection_id, title, 0 as selected from pa_collections where owner_id = :user_id}

    if {[template::multirow size $datasource] > 0} {
        if {$create_new_p} { 
            template::multirow append $datasource -1 "Create a new clipboard" 0
        } 

    } else { 
        if { $force_default_p } { 
            template::multirow create $datasource collection_id title selected
            template::multirow append $datasource 0 "General" 0
        }
    }
    return [template::multirow size $datasource]
}

ad_proc pa_rotate {id rotation} {
    Rotate a pic

    @param id the photo_id to rotate
    @param rotation the number of degrees to rotate

    @author Jeff Davis davis@xarg.net
    @creation-date 2002-10-30

} {
    if {![empty_string_p $rotation] && ![string equal $rotation 0]} { 
        set flop [list]
        set files [list]

        # get a list of files to handle sorted by size...
        db_foreach get_image_files {} {
            ns_log Notice "pa_rotate $id $rotation [cr_fs_path] $filename $image_id $width $height"
            if {[catch {exec convert -rotate $rotation [cr_fs_path]$filename [cr_fs_path]${filename}.new } errMsg]} { 
                ns_log Notice "Failed rotation of image $image_id -- $errMsg"
            }
            lappend flop $image_id
            lappend files [cr_fs_path]$filename
        }

        # rename files in catch.
        if { [catch { 
            foreach fnm $files {
                file rename -force $fnm ${fnm}.old 
                file rename -force ${fnm}.new $fnm
            } } errMsg ] } { 
            # problem with the renaming.  Make an attempt to rename them back 
            catch { 
                foreach fnm $files {
                    file rename -force ${fnm}.old $fnm
                    file delete -force ${fnm}.new
                }
            } errMsg
        } else { 
            # flop images that need flopping.
            if {[string equal $rotation 90] || [string equal $rotation 270]} { 
                db_dml flop_image_size "update images set width = height, height = width where image_id in ([join $flop ,])"
            }
        }
    }
}

        
