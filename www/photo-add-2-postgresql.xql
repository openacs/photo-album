<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="insert_photo">      
      <querytext>
	select pa_photo__new (
	  :image_name, -- name
	  :album_id, -- parent_id 
	  :photo_id, -- item_id 
	  :photo_rev_id, -- revision_id     
	  current_timestamp, -- creation_date   
	  :user_id, -- creation_user 
	  :peeraddr, -- creation_ip     
	  null, -- locale
	  :album_id, -- context_id      
	  :client_filename, -- title 
	  :description, -- description 
	  't', -- is_live
	  current_timestamp, -- publish_date
	  null, -- nls_language 
	  :caption, -- caption 
	  :story -- story 
	)
      </querytext>
</fullquery>

<fullquery name="insert_base_image">      
      <querytext>	  
	select image__new (
          :base_image_name, -- name 
	  :photo_id, -- parent_id 
	  :base_item_id, -- item_id         
	  :base_rev_id, -- revision_id     
	  :base_mime_type, -- mime_type       
	  :user_id, -- creation_user   
	  :peeraddr, -- creation_ip     
	  'base', -- relation_tag
          :base_image_name, -- title
	  'original image', -- description     
	  't', -- is_live         
	  current_timestamp, -- publish_date
	  :base_filename_with_rel_path, -- path            
	  :base_n_bytes, -- file_size
	  :base_height, -- height          
	  :base_width -- width           
	)

      </querytext>
</fullquery>

<fullquery name="insert_thumb_image">      
      <querytext>
	select image__new (
	  :th_image_name, -- name 
	  :photo_id, -- parent_id 
	  :thumb_item_id, -- item_id         
	  :thumb_rev_id, -- revision_id     
	  :thumb_mime_type, -- mime_type       
	  :user_id, -- creation_user   
	  :peeraddr, -- creation_ip     
	  'thumb', -- relation_tag
	  :th_image_name, -- title
	  'thumbnail', -- description     
	  't', -- is_live         
	  current_timestamp, -- publish_date
	  :thumb_filename_with_rel_path, -- path            
	  :thumb_n_bytes, -- file_size
	  :thumb_height, -- height          
	  :thumb_width -- width           
	)
      </querytext>
</fullquery>

<fullquery name="insert_viewer_image">      
      <querytext>
	select image__new (
	  :vw_image_name, -- name 
	  :photo_id, -- parent_id 
	  :viewer_item_id, -- item_id         
	  :viewer_rev_id, -- revision_id     
	  :viewer_mime_type, -- mime_type       
	  :user_id, -- creation_user   
	  :peeraddr, -- creation_ip     
	  'viewer', -- relation_tag
	  :vw_image_name, -- title
	  'web sized image', -- description     
	  't', -- is_live         
	  current_timestamp, -- publish_date
	  :viewer_filename_with_rel_path, -- path            
	  :viewer_n_bytes, -- file_size
	  :viewer_height, -- height          
	  :viewer_width -- width           
	)
      </querytext>
</fullquery>

 
</queryset>
