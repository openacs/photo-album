<?xml version="1.0"?>
<queryset>

<fullquery name="pa_get_folder_description.folder_description">      
      <querytext>
      
    select description from cr_folders where folder_id = :folder_id
      </querytext>
</fullquery>

<fullquery name="pa_all_photos_in_album_internal.get_photo_ids">      
      <querytext>
      select 
  ci.item_id
from cr_items ci,
  cr_child_rels ccr
where ci.latest_revision is not null
  and ci.content_type = 'pa_photo'
  and ccr.parent_id = :album_id
  and ci.item_id = ccr.child_id
order by ccr.order_n
      </querytext>
</fullquery>

 
<fullquery name="pa_pagination_get_total_pages.get_total_pages">      
      <querytext>
      
	select 
	ceil(count(*) / [ad_parameter ThumbnailsPerPage])
	from
	($sql)
	
      </querytext>
</fullquery>

<fullquery name="photo_album::photo::get.images">      
     <querytext>
    SELECT ccr.relation_tag, image_items.name, image_items.live_revision, image_items.latest_revision, i.*, image_revs.content, image_revs.content_length
      FROM cr_items photo,
           cr_items image_items,
           cr_revisions image_revs,
           cr_child_rels ccr,
           images i
     WHERE ccr.parent_id = photo.item_id
       and image_items.item_id = ccr.child_id
       and image_items.live_revision = i.image_id
       and image_revs.revision_id = image_items.live_revision
       and photo.item_id = :photo_id;
     </querytext>
</fullquery>

</queryset>
