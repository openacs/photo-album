\i photo-album-clip.sql 

create view all_photo_images as select i.item_id, ccr.relation_tag, im.*, p.*
      from cr_items i,
           cr_items i2,
           pa_photos p,
           cr_child_rels ccr,
           images im
 where i.item_id = ccr.parent_id 
   and p.pa_photo_id = i.live_revision
   and ccr.child_id = i2.item_id
   and i2.live_revision = im.image_id;

