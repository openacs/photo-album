<?xml version="1.0"?>

<queryset>

<fullquery name="get_child_photos">      
      <querytext>
      select ci.item_id as photo_id,
      (select pp.caption from pa_photos pp where pp.pa_photo_id = ci.live_revision) as caption,
      i.image_id as thumb_path,
      i.height as thumb_height,
      i.width as thumb_width
    from cr_items ci,
      cr_items ci2,
      cr_child_rels ccr2,
      images i
    where ccr2.relation_tag = 'thumb'
      and ci.item_id = ccr2.parent_id
      and ccr2.child_id = ci2.item_id
      and ci2.live_revision = i.image_id
      and ci.live_revision is not null
      and ci.item_id in ([join $photos_on_page ","])
      </querytext>
</fullquery>

<fullquery name="get_album_info">      
      <querytext>
select cr.title,
  cr.description,
  pa.story,
  ci.parent_id as parent_folder_id,
  case when acs_permission__permission_p(ci.item_id, :user_id, 'admin') = 't' then 1 else 0 end as admin_p,
  case when acs_permission__permission_p(ci.item_id, :user_id, 'pa_create_photo') = 't' then 1 else 0 end as photo_p,
  case when acs_permission__permission_p(ci.item_id, :user_id, 'write') ='t' then 1 else 0 end as write_p,
  case when acs_permission__permission_p(ci.parent_id, :user_id, 'write') = 't' then 1 else 0 end as folder_write_p,
  case when acs_permission__permission_p(ci.item_id, :user_id, 'delete') = 't' then 1 else 0 end as album_delete_p
from cr_items ci,
  cr_revisions cr,
  pa_albums pa
where ci.live_revision = cr.revision_id
  and ci.live_revision = pa_album_id
  and ci.item_id = :album_id
      </querytext>
</fullquery>

</queryset>

