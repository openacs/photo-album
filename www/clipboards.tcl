set user_id [ad_conn user_id]

db_multirow clipboards clipboards {
  SELECT c.collection_id, title, 
         sum(case when m.photo_id is not null then 1 else 0 end) as photos
    FROM pa_collections as c left outer join pa_collection_photo_map as m 
      on (m.collection_id = c.collection_id) 
   WHERE c.owner_id = :user_id
   GROUP BY c.collection_id, title
   ORDER BY title
}
