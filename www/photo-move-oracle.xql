<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_albums">      
      <querytext>
    select r.title as name, i.item_id
    from cr_items i, cr_revisions r
    where i.live_revision = r.revision_id
      and acs_permission.permission_p(i.item_id, :user_id, 'pa_create_photo') = 't'
      and i.content_type = 'pa_album'
      and i.item_id != :old_album_id
    connect by prior i.item_id = i.parent_id
    start with i.item_id = :root_folder_id
      </querytext>
</fullquery>

 
</queryset>
