<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="insert_photo">      
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
	  

<fullquery name="insert_base_image">      
      <querytext>
      
	declare 
	  dummy  integer;
	begin
	dummy := image.new (
	  name            => :base_image_name,
	  parent_id       => :photo_id,
	  item_id         => :base_item_id,
	  revision_id     => :base_rev_id,
	  creation_date   => sysdate,
	  creation_user   => :user_id,
	  creation_ip     => :peeraddr,
	  context_id      => :photo_id,
	  title           => :client_filename,
	  description     => :description,
	  mime_type       => :base_mime_type,
	  relation_tag    => 'base',
	  is_live         => 't',
	  filename        => :base_filename_with_rel_path,
	  height          => :base_height,
	  width           => :base_width,
	  file_size       => :base_n_bytes
	);
	
	end;
    
      </querytext>
</fullquery>

<fullquery name="insert_thumb_image">      
      <querytext>
      
	declare 
	  dummy  integer;
	begin

	dummy := image.new (
	  name            => :th_image_name,
	  parent_id       => :photo_id,
	  item_id         => :thumb_item_id,
	  revision_id     => :thumb_rev_id,
	  creation_date   => sysdate,
	  creation_user   => :user_id,
	  creation_ip     => :peeraddr,
	  context_id      => :photo_id,
	  title           => :client_filename,
	  description     => :description,
	  mime_type       => :thumb_mime_type,
	  relation_tag    => 'thumb',
	  is_live         => 't',
	  filename        => :thumb_filename_with_rel_path,
	  height          => :thumb_height,
	  width           => :thumb_width,
	  file_size       => :thumb_n_bytes
	);

	
	end;
    
      </querytext>
</fullquery>

<fullquery name="insert_viewer_image">      
      <querytext>
      
	declare 
	  dummy  integer;
	begin

	dummy := image.new (
	  name            => :vw_image_name,
	  parent_id       => :photo_id,
	  item_id         => :viewer_item_id,
	  revision_id     => :viewer_rev_id,
	  creation_date   => sysdate,
	  creation_user   => :user_id,
	  creation_ip     => :peeraddr,
	  context_id      => :photo_id,
	  title           => :client_filename,
	  description     => :description,
	  mime_type       => :viewer_mime_type,
	  relation_tag    => 'viewer',
	  is_live         => 't',
	  filename        => :viewer_filename_with_rel_path,
	  height          => :viewer_height,
	  width           => :viewer_width,
	  file_size       => :viewer_n_bytes
	);
	
	end;
    
      </querytext>
</fullquery>

 
</queryset>
