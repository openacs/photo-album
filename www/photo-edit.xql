<?xml version="1.0"?>
<queryset>

<fullquery name="get_photo_info">      
      <querytext>
      select 
      ci.live_revision as previous_revision,
      pp.caption,
      pp.story,
      cr.title,
      cr.description,
      i.height as height,
      i.width as width,
      i.image_id as image_id
    from cr_items ci,
      cr_revisions cr,
      pa_photos pp,
      cr_items ci2,
      cr_child_rels ccr2,
      images i
    where ci.live_revision = pp.pa_photo_id
      and ci.live_revision = cr.revision_id
      and ci.item_id = ccr2.parent_id
      and ccr2.child_id = ci2.item_id
      and ccr2.relation_tag = 'viewer'
      and ci2.live_revision = i.image_id
      and ci.item_id = :photo_id

      </querytext>
</fullquery>

<fullquery name="insert_photo_attributes">      
      <querytext>
	    insert into pa_photos (pa_photo_id, story, caption)
	    values 
	    (:revision_id, :new_story, :new_caption)
      </querytext>
</fullquery>
 
<fullquery name="update_photo_user_filename">      
      <querytext>
	 UPDATE pa_photos
 	    SET user_filename = prev.user_filename,
                camera_model = prev.camera_model,
                date_taken   = prev.date_taken,
                flash        = prev.flash, 
                aperture     = prev.aperture,
                metering     = prev.metering,   
                focal_length = prev.focal_length,
                exposure_time  = prev.exposure_time,
                focus_distance = prev.focus_distance,
                sha256         = prev.sha256,
                photographer   = prev.photographer
           FROM (
             SELECT user_filename,camera_model,date_taken,flash, 
                    aperture,metering,focal_length,exposure_time,
                    focus_distance,sha256,photographer
               FROM pa_photos prev
              WHERE prev.pa_photo_id = :previous_revision
              ) prev
           WHERE pa_photo_id = :revision_id
      </querytext>
</fullquery>

</queryset>



