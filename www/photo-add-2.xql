<?xml version="1.0"?>
<queryset>

<fullquery name="check_photo_id">      
      <querytext>
      select count(*) from cr_items where item_id = :photo_id
      </querytext>
</fullquery>

 
<fullquery name="duplicate_check">      
      <querytext>
      
    select count(*)
    from   cr_items
    where  (item_id = :photo_id or name = :client_filename)
    and    parent_id = :album_id
      </querytext>
</fullquery>

 
</queryset>
