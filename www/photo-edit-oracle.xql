<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_next_object_id">      
      <querytext>
      select acs_object_id_seq.nextval from dual
      </querytext>
</fullquery>

 
<fullquery name="update_photo_attributes">      
      <querytext>
      
	    declare
	      dummy integer;
	    begin

	    dummy := content_revision.new (
	      title => :new_title,
  	      description => :new_desc,
	      item_id => :photo_id,
	      revision_id => :revision_id,
	      creation_date => sysdate,
	      creation_user => :user_id,
	      creation_ip => :peeraddr
	    );
	    end;
	
      </querytext>
</fullquery>


<fullquery name="set_live_revision">      
      <querytext>
            begin	
	    content_item.set_live_revision (
	      revision_id => :revision_id
            );

	    end;
      </querytext>
</fullquery>

 
</queryset>
