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

 
<fullquery name="pa_load_images.insert_photo">      
      <querytext>
      
                declare 
                dummy  integer;
                begin

                dummy := pa_photo.new (
                                       name            => :image_name,
                                       parent_id       => :album_id,
                                       item_id         => :photo_id,
                                       revision_id     => :photo_rev_id,
                                       creation_date   => sysdate,
                                       creation_user   => :user_id,
                                       creation_ip     => :peeraddr,
                                       context_id      => :album_id,
                                       title           => :client_filename,
                                       description     => :description,
                                       is_live         => 't',
                                       caption         => :caption,
                                       story           => :story,
                                       user_filename   => :client_filename
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
                            creation_date   => sysdate,
                            creation_user   => :user_id,
                            creation_ip     => :peeraddr,
                            context_id      => :context_id,
                            title           => :title,
                            description     => :description,
                            mime_type       => :mime_type,
                            relation_tag    => :relation,
                            is_live         => :is_live,
                            path            => :path,
                            height          => :height,
                            width           => :width,
                            file_size       => :size
                            );
        end;
    
      </querytext>
</fullquery>

</queryset>
