
declare
  cursor priv_cursor is
    select object_id, grantee_id, privilege
    from acs_permissions 
    where privilege = 'pa_create_photo';
  priv_val  priv_cursor%ROWTYPE;
begin
  for priv_val in priv_cursor
    loop
      acs_permission.revoke_permission (
        object_id  => priv_val.object_id,
	grantee_id => priv_val.grantee_id,
	privilege  => priv_val.privilege
      );
    end loop;
end;
/

declare
  cursor priv_cursor is
    select object_id, grantee_id, privilege
    from acs_permissions 
    where privilege = 'pa_create_album';
  priv_val  priv_cursor%ROWTYPE;
begin
  for priv_val in priv_cursor
    loop
      acs_permission.revoke_permission (
        object_id  => priv_val.object_id,
	grantee_id => priv_val.grantee_id,
	privilege  => priv_val.privilege
      );
    end loop;
end;
/

declare
  cursor priv_cursor is
    select object_id, grantee_id, privilege
    from acs_permissions 
    where privilege = 'pa_create_folder';
  priv_val  priv_cursor%ROWTYPE;
begin
  for priv_val in priv_cursor
    loop
      acs_permission.revoke_permission (
        object_id  => priv_val.object_id,
	grantee_id => priv_val.grantee_id,
	privilege  => priv_val.privilege
      );
    end loop;
end;
/

begin
  -- kill stuff in permissions.sql
 
  acs_privilege.remove_child('create', 'pa_create_photo');
  acs_privilege.remove_child('create', 'pa_create_album');
  acs_privilege.remove_child('create', 'pa_create_folder');

  acs_privilege.drop_privilege('pa_create_album');
  acs_privilege.drop_privilege('pa_create_folder');
  acs_privilege.drop_privilege('pa_create_photo');

end;
/

begin
  content_type.unregister_child_type (
    parent_type => 'pa_album',
    child_type => 'pa_photo',
    relation_tag => 'generic'
  );

  content_type.unregister_child_type (
    parent_type => 'pa_photo',
    child_type => 'pa_image',
    relation_tag => 'generic'
  );
end;
/

-- clear out all the reference that cause key violations when droping type

-- delete images
declare
  cursor image_cursor is
    select item_id
    from cr_items 
    where content_type = 'pa_image';
  image_val  image_cursor%ROWTYPE;
begin
  for image_val in image_cursor
    loop
      pa_image.delete (
        item_id  => image_val.item_id
      );
    end loop;
end;
/

-- delete photos
declare
  cursor photo_cursor is
    select item_id
    from cr_items 
    where content_type = 'pa_photo';
  photo_val  photo_cursor%ROWTYPE;
begin
  for photo_val in photo_cursor
    loop
      pa_photo.delete (
        item_id  => photo_val.item_id
      );
    end loop;
end;
/

-- delete albums
declare
  cursor album_cursor is
    select item_id
    from cr_items 
    where content_type = 'pa_album';
  album_val  album_cursor%ROWTYPE;
begin
  for album_val in album_cursor
    loop
      pa_album.delete (
        album_id  => album_val.item_id
      );
    end loop;
end;
/

declare
  cursor folder_cursor is
    select folder_id, content_type
    from cr_folder_type_map where content_type = 'pa_album';
  folder_val folder_cursor%ROWTYPE;
begin
  for folder_val in folder_cursor
    loop
      content_folder.unregister_content_type (
        folder_id    => folder_val.folder_id,
	content_type => folder_val.content_type
      );
    end loop;
end;
/

drop package photo_album;

drop package pa_album;

drop package pa_photo;  

drop package pa_image;

begin
  acs_object_type.drop_type('pa_image');
end;
/

drop table pa_images;

begin
  acs_object_type.drop_type('pa_photo');
end;
/

drop table pa_photos;

begin
  acs_object_type.drop_type('pa_album');
end;
/

drop table pa_albums;

-- delete all the folder under the root folders of photo album instances
declare
  cursor folder_cur is
    select item_id as folder_id, level
    from cr_items
    where content_type = 'content_folder'
    connect by prior item_id = parent_id
    start with item_id in (select folder_id from pa_package_root_folder_map)	
    order by level desc;
  folder_val folder_cur%ROWTYPE;
begin
  for folder_val in folder_cur 
    loop
      if folder_val.level = 1 then
        -- folder is a root folder, delete it from maping table to avoid fk constraint violation
        delete from pa_package_root_folder_map where folder_id = folder_val.folder_id;
      end if;
      content_folder.delete (folder_id => folder_val.folder_id);
    end loop;
end;
/
  
drop table pa_package_root_folder_map;

drop table pa_files_to_delete;





