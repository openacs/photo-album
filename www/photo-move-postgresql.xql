<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_albums">      
      <querytext>
      select r.title as name, i.item_id
    from cr_items i, cr_revisions r
    where i.live_revision = r.revision_id
      and i.parent_id = (select parent_id from cr_items where item_id = :old_album_id)
      and acs_permission__permission_p(i.item_id, :user_id, 'read') = 't'
      and i.content_type = 'pa_album'
      and i.item_id != :old_album_id
      </querytext>
</fullquery>

 
</queryset>
