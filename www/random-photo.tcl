# Includable template pair that can be used to show a random photo
# from a photo-album instance or from all instances on the server.
# 
# written by Jarkko Laine (jarkko.m.laine@tut.fi) 
#
# Usage: 
# <include src="/packages/photo-album/www/random-photo" url="/path/to/your/photo-album">
# or
# <include src="/packages/photo-album/www/random-photo" package_id="1473"> where 1473
# is the package_id of your photo-album instance.
#
# If neither package_id nor url is defined, the random photo is taken from all photos
# in the system.
#
# Expects:
#  package_id:optional
#  url:optional
#  size:optional (thumb, viewer) (thumb is default)
#




# If the caller specified a URL, then we gather the package_id from that URL
if { [info exists url] } {
    # let's add the leading/tailing slashes so the url's will always work         
    set url [string trim $url]
    if { ![string equal [string index $url 0] "/"] } {
        set url "/$url"
    }
    if { ![string equal [string index $url end] "/"] } {
        set url "$url/"
    }

    array set pa_site_node [site_node::get -url $url]
    set package_id $pa_site_node(object_id)
}

set found_p 1

# If they supplied neither url nor package_id, the random photo
# is shuffled across all the photos in the system
if { ![info exists package_id] } {
    set folder_clause ""
} else {
    set root_folder_id [pa_get_root_folder $package_id]
    set folder_clause [db_map folder_clause]
}

if { ![info exists size] } {
    set size "thumb"
}

switch -exact $size {
    viewer {
	# Get the normal size photo
	set size_clause [db_map size_clause_normal]
    }
    default {
	# Grab the thumbnail
	set size_clause [db_map size_clause_thumb]
    }
}

# Get the photo information
if {[catch {db_1row get_random_photo {}}] } {
    # No photos found
    set found_p 0
}


# if no url or package_id  were given, we have to find out
# which package the photo belongs to
if { ![info exists package_id] && ![info exists url] && $found_p == 1} {
    set url [db_string get_url ""]
}


ad_return_template 
