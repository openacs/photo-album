# /packages/photo-album/www/clipboard-attach.tcl
ad_page_contract {

    Add a photo to one of your clipboards (or create a new one if either 
    asked for or none exist).  Requires registration.                                           
    
    @author Jeff Davis davis@xarg.net
    @creation-date 10/30/2002
    @cvs-id $Id$
} {
    photo_id:integer,notnull
    collection_id:integer,notnull
}

ad_maybe_redirect_for_registration

set user_id [ad_conn user_id]
set peeraddr [ad_conn peeraddr]
set context [ad_conn package_id]

if {$collection_id < 0} { 
    ad_returnredirect "clipboard-ae?photo_id=$photo_id"
    ad_script_abort
} 

# If we got collection_id 0 then we need to create a "General" clipboard 
if {$collection_id == 0} {
    set title "General"
    
    set collection_id [db_nextval acs_object_id_seq]

    if {[catch {db_1row new_collection {select pa_collection__new(:collection_id, :user_id, :title, now(), :user_id, :peeraddr, :context)}} errMsg]} { 
        ad_return_error "Clipboard Insert error" "Error putting photo into clipboard<pre>$errMsg</pre>"
    }
}

if {$collection_id > 0} { 
    if {[catch {db_dml map_photo {insert into pa_collection_photo_map (collection_id, photo_id) select :collection_id, :photo_id where 
        acs_permission__permission_p(:collection_id, :user_id, 'write') = 't'}} errMsg]} { 
        # Check if it was a pk violation (i.e. already inserted)
        # JCD: should check if this works for oracle.  Might have case problem.
        if {![string match "*pa_collection_photo_map_pk*" $errMsg]} { 
            ad_return_error "Clipboard Insert error" "Error putting photo into clipboard<pre>$errMsg</pre>"
            ad_script_abort
        }
    }
}

ad_returnredirect "photo?photo_id=$photo_id&collection_id=$collection_id"
