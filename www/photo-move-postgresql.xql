<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_albums">      
      <querytext>
    select r.title as name, i.item_id
    from cr_items i, cr_revisions r, cr_items i2
    where i.live_revision = r.revision_id
      and acs_permission__permission_p(i.item_id, :user_id, 'pa_create_photo') = 't'
      and i.content_type = 'pa_album'
      and i.item_id != :old_album_id
      and i.tree_sortkey between i2.tree_sortkey and tree_right(i2.tree_sortkey)
      and i2.item_id = :root_folder_id
    order by i.tree_sortkey
      </querytext>
</fullquery>

 
</queryset>
