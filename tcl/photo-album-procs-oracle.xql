<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="pa_get_root_folder_internal.pa_root_folder">      
      <querytext>
      select photo_album.get_root_folder(:package_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="pa_new_root_folder.make_new_root">      
      <querytext>
       begin
	:1 := photo_album.new_root_folder(:package_id);
       end;
      </querytext>
</fullquery>

 
<fullquery name="pa_new_root_folder.get_grantee_id">      
      <querytext>
      select acs.magic_object_id('$party') from dual
      </querytext>
</fullquery>

 
<fullquery name="pa_new_root_folder.grant_default">      
      <querytext>
      
		begin
		  acs_permission.grant_permission (
	            object_id  => :new_folder_id,
	            grantee_id => :grantee_id,
	            privilege  => :privilege
		  );
		end;
	    
      </querytext>
</fullquery>

 
<fullquery name="pa_get_folder_name.folder_name">      
      <querytext>
      
    select content_folder.get_label(:folder_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="pa_context_bar_list.get_start_and_final">      
      <querytext>
      select parent_id as start_id,
	  content_item.get_title(item_id,'t') as final
	  from cr_items where item_id = :item_id
      </querytext>
</fullquery>

 
<fullquery name="pa_context_bar_list.context_bar">      
      <querytext>
      
    select decode(
             content_item.get_content_type(i.item_id),
             'content_folder',
             'index?folder_id=',
             'pa_album',             
             'album?album_id=',
             'photo?photo_id='
           ) || i.item_id,
           content_item.get_title(i.item_id,'t')
    from   cr_items i
    connect by prior i.parent_id = i.item_id
      and i.item_id != :root_folder_id
    start with item_id = :start_id
    order by level desc
      </querytext>
</fullquery>

 
<fullquery name="pa_is_type_in_package.check_is_type_in_package">      
      <querytext>
      select case when (select 1 
	from dual
	where exists (select 1 
	    from cr_items 
	    where item_id = :root_folder 
	    connect by prior parent_id = item_id 
	    start with item_id = :item_id)
	  and content_item.get_content_type(:item_id) = :content_type
	) = 1 then 't' else 'f' end
	from dual
      </querytext>
</fullquery>

 
<fullquery name="pa_grant_privilege_to_creator.grant_privilege">      
      <querytext>
      
	    begin
	      acs_permission.grant_permission (
	        object_id  => :object_id,
	        grantee_id => :user_id,
	        privilege  => :privilege
	      );
	    end;
	
      </querytext>
</fullquery>

 
<fullquery name="pa_load_images.new_photo">      
      <querytext>
        declare 
            dummy  integer;
        begin

        dummy := pa_photo.new (
            name            => :image_name,
            parent_id       => :album_id,
            item_id         => :photo_id,
            revision_id     => :photo_rev_id,
            creation_user   => :user_id,
            creation_ip     => :peeraddr,
            context_id      => :album_id,
            title           => :client_filename,
            description     => :description,
            is_live         => 't',
            caption         => :caption,
            story           => :story
         );
         end;

    </querytext>
</fullquery>

 
<fullquery name="pa_insert_image.pa_insert_image">      
      <querytext>
      
        declare 
            dummy  integer;
        begin

        dummy := image.new (
            name            => :name,
            parent_id       => :photo_id,
            item_id         => :item_id,
            revision_id     => :rev_id,
            mime_type       => :mime_type,
            creation_user   => :user_id,
            creation_ip     => :peeraddr,
            relation_tag    => :relation,
            title           => :title,
            description     => :description,
            is_live         => :is_live,
            file_size       => :size,
            filename        => :path,
            height          => :height,
            width           => :width,
            context_id      => :context_id
        );
        end;
    
      </querytext>
</fullquery>

<fullquery name="pa_load_images.update_photo_data">      
    <querytext>

        UPDATE pa_photos 
        SET camera_model = :tmp_exif_Cameramodel,
            user_filename = :upload_name,
            date_taken = to_date(:tmp_exif_DateTime, 'YYYY-MM-DD HH24:MI:SS'),
            flash = :tmp_exif_Flashused,
            aperture = :tmp_exif_Aperture,
            metering = :tmp_exif_MeteringMode,
            focal_length = :tmp_exif_Focallength,
            exposure_time = :tmp_exif_Exposuretime,
            focus_distance = :tmp_exif_FocusDist,
            sha256 = :base_sha256
        WHERE pa_photo_id = :photo_rev_id

    </querytext>
</fullquery>

<fullquery name="pa_rotate.get_image_files">      
      <querytext>
      
            select i.image_id, crr.filename, i.width, i.height
            from cr_items cri, cr_revisions crr, images i
            where cri.parent_id = :id
              and crr.revision_id = cri.latest_revision
              and i.image_id = cri.latest_revision
            order by crr.content_length desc
	
      </querytext>
</fullquery>

</queryset>
