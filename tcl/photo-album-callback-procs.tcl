ad_library {
    Library of callbacks implementations for photo-album
}


#Callbacks for application-track

ad_proc -callback application-track::getApplicationName -impl album {} { 
        callback implementation 
    } {
        return "album"
    }    
      
ad_proc -callback application-track::getGeneralInfo -impl album {} { 
        callback implementation 
    } {
	db_1row my_query {
	select count(p.pa_album_id) as result
			from pa_albums p, cr_items cr,acs_objects a,dotlrn_communities_all d
		    	where  d.community_id = :comm_id
		    	and cr.live_revision = p.pa_album_id		    	
			  and a.object_id = cr.parent_id
			  and apm_package__parent_id(a.context_id) = d.package_id		
	
	} 
	
	return "$result"
    } 

                            
ad_proc -callback application-track::getSpecificInfo -impl album {} { 
        callback implementation 
    } {
   	
	upvar $query_name my_query
	upvar $elements_name my_elements

	set my_query {
	
		select p.pa_photo_id as id,p.story as story,p.photographer as photographer
			from pa_photos p, dotlrn_communities com,acs_objects ac,acs_objects ac2,acs_objects ac1
		    		where com.community_id=:class_instance_id	    	
		    		and ac.object_id = p.pa_photo_id
		    		and ac.context_id = ac1.object_id
		    		and ac1.context_id = ac2.object_id				
				and ac2.context_id
					IN	(select ac1.context_id
				from pa_albums p, dotlrn_communities com,acs_objects ac,acs_objects ac1
		    		where com.community_id=:class_instance_id	    	
		    		and ac.object_id = p.pa_album_id
		    		and ac.context_id = ac1.object_id
		    		)
				
	}
	set my_elements {
		photo_id {
	            label "Photo_id"
	            display_col id	                        
	 	    html {align center}	 	                
	        }
	        p_story {
	            label "Story"
	            display_col story	                        
	 	    html {align center}	 	                
	        }
	        p_photographer {
	            label "photographer"
	            display_col photographer	                        
	 	    html {align center}	 	                
	        }
	        
	}

        return "OK"
    }