ad_library {
    Photo Album - Search Service Contracts

    @creation-date 2004-06-01
    @author Jeff Davis davis@xarg.net
    @cvs-id $Id$
}

namespace eval photo_album::search {}
namespace eval photo_album::search::album {}
namespace eval photo_album::search::photo {}

ad_proc -private photo_album::search::album::datasource { album_id } {
    return the indexable content for an album.
    can index a revision_id or a cr_item.item_id for photo_album

    @param album_id the item_id or revision id to index.

    @creation-date 2004-06-01
    @author Jeff Davis davis@xarg.net
} {
    # get the best revision to show if it's an item_id otherwise assume we got a pa_album revision.
    set revision_id [db_string best_revision {select coalesce(live_revision, latest_revision) from cr_items where item_id = :album_id} -default $album_id]

    db_0or1row album_datasource {
        select r.title,
          r.title || ' ' || r.description || ' ' || a.story || ' photographer: ' || a.photographer as content,
          'text/html' as mime, 
          '' as keywords,
          'text' as storage_type
        from cr_revisions r, pa_albums a
        where r.revision_id = :revision_id 
          and a.pa_album_id = r.revision_id
    } -column_array datasource

    set datasource(object_id) $album_id

    return [array get datasource]
}

ad_proc -private  photo_album::search::album::url { album_id } {
    returns a url for a message to the search package

    @param album_id - either a revision_id or an item_id for an album

    @creation-date 2004-06-01
    @author Jeff Davis davis@xarg.net
} {
    set node [db_string package {
        SELECT n.node_id
        FROM cr_items i1, cr_items i2, pa_package_root_folder_map m, site_nodes n
        WHERE m.folder_id = i2.item_id
          and i1.item_id = :album_id
          and n.object_id = m.package_id
          and i1.tree_sortkey between i2.tree_sortkey and tree_right(i2.tree_sortkey)
    }]

    return "[ad_url][site_node::get_element -node_id $node -element url]album?album_id=$album_id"
}


ad_proc -private photo_album::search::register_implementations {} {
    Register the forum_forum and forum_message content type fts contract
} {
    db_transaction {
        photo_album::search::register_album_fts_impl
        photo_album::search::register_photo_fts_impl
    }
}



ad_proc -private photo_album::search::photo::datasource { photo_id } {
    return the indexable content for an album.
    can index a revision_id or a cr_item.item_id for photo_album

    @param photo_id the item_id or revision id to index.

    @creation-date 2004-06-01
    @author Jeff Davis davis@xarg.net
} {
    # get the best revision to show if it's an item_id otherwise assume we got a pa_album revision.
    set revision_id [db_string best_revision {select coalesce(live_revision, latest_revision) from cr_items where item_id = :photo_id} -default $photo_id]

    db_0or1row album_datasource {
        select r.title,
        r.title || ' ' || r.description || ' caption: ' || p.caption || ' story: ' || p.story || ' filename: ' || p.user_filename as content,
          'text/html' as mime, 
          '' as keywords,
          'text' as storage_type
        from cr_revisions r, pa_photos p
        where r.revision_id = :revision_id 
          and p.pa_photo_id = r.revision_id
    } -column_array datasource

    set datasource(object_id) $photo_id

    return [array get datasource]
}

ad_proc -private  photo_album::search::photo::url { photo_id } {
    returns a url for a message to the search package

    @param photo_id - either a revision_id or an item_id for an album

    @creation-date 2004-06-01
    @author Jeff Davis davis@xarg.net
} {
    set node [db_string package {
        SELECT n.node_id
        FROM cr_items i1, cr_items i2, pa_package_root_folder_map m, site_nodes n
        WHERE m.folder_id = i2.item_id
          and i1.item_id = :photo_id
          and n.object_id = m.package_id
          and i1.tree_sortkey between i2.tree_sortkey and tree_right(i2.tree_sortkey)
    }]

    return "[ad_url][site_node::get_element -node_id $node -element url]photo?photo_id=$photo_id"
}


ad_proc -private photo_album::search::unregister_implementations {} {
    db_transaction { 
        acs_sc::impl::delete -contract_name FtsContentProvider -impl_name pa_album
        acs_sc::impl::delete -contract_name FtsContentProvider -impl_name pa_photo
    }
}

ad_proc -private photo_album::search::album::register_fts_impl {} {
    set spec {
        name "pa_album"
        aliases {
            datasource photo_album::search::album::datasource
            url photo_album::search::album::url
        }
        contract_name FtsContentProvider
        owner photo-album
    }

    acs_sc::impl::new_from_spec -spec $spec
}


ad_proc -private photo_album::search::photo::register_fts_impl {} {
    set spec {
        name "pa_photo"
        aliases {
            datasource photo_album::search::photo::datasource
            url photo_album::search::photo::url
        }
        contract_name FtsContentProvider
        owner photo-album
    }

    acs_sc::impl::new_from_spec -spec $spec
}
