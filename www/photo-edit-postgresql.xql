<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_next_object_id">      
      <querytext>
      select acs_object_id_seq.nextval 
      </querytext>
</fullquery>

 
<fullquery name="update_photo_attributes">      
      <querytext>
	    select content_revision__new (
	      :new_title, -- title => 
  	      :new_desc, -- description 
      	      current_timestamp, -- publish_date
      	      null, -- mime_type
      	      null, -- nls_language
              null, -- locale
	      :photo_id, -- item_id 
	      :revision_id, -- revision_id 
	      current_timestamp, -- creation_date 
	      :user_id, -- creation_user
	      :peeraddr -- creation_ip 
	    )
	      </querytext>
</fullquery>


<fullquery name="set_live_revision">      
      <querytext>
	    select content_item__set_live_revision (:revision_id)
      </querytext>
</fullquery>

 
</queryset>
