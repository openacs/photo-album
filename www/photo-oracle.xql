<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_photo_info">      
      <querytext>

select
 pp.caption,
 pp.story,
 cr.title,
 cr.description,
 i.height as height,
 i.width as width,
 i.image_id as image_id,
 ci.parent_id as album_id,
 case when acs_permission.permission_p(ci.item_id, :user_id, 'admin') ='t' then 1 else 0 end as admin_p,
 case when acs_permission.permission_p(ci.item_id, :user_id, 'write') = 't' then 1 else 0 end as write_p,
 case when acs_permission.permission_p(ci.parent_id, :user_id, 'write') = 't' then 1 else 0 end as album_write_p,
 case when acs_permission.permission_p(ci.item_id, :user_id, 'delete') = 't' then 1 else 0 end as photo_delete_p
from cr_items ci,
  cr_revisions cr,
  pa_photos pp,
  cr_items ci2,
  cr_child_rels ccr2,
  images i
where cr.revision_id = pp.pa_photo_id
  and ci.live_revision = cr.revision_id
  and ci.item_id = ccr2.parent_id
  and ccr2.child_id = ci2.item_id
  and ccr2.relation_tag = 'viewer'
  and ci2.live_revision = i.image_id
  and ci.item_id = :photo_id

      </querytext>
</fullquery>

 
</queryset>
