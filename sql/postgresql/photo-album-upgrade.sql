-- Add new photo attributes...

alter table pa_photos add     camera_model      varchar(250);
alter table pa_photos add     date_taken        timestamp;
alter table pa_photos add     flash             boolean;
alter table pa_photos add     focal_length      numeric;
alter table pa_photos add     exposure_time     numeric;
alter table pa_photos add     focus_distance    numeric;
alter table pa_photos add     aperture          varchar(32);
alter table pa_photos add     metering          varchar(100);
alter table pa_photos add     sha256            varchar(64);

 select content_type__create_attribute (
   'pa_photo',		     -- content_type
   'camera_model',	     -- attribute_name
   'text',		     -- datatype
   'Camera',		     -- pretty_name
   'Cameras',		     -- pretty_plural
   null,		     -- sort_order
   null,		     -- default_value
   'text'		     -- column_spec
 );

select content_type__create_attribute (
   'pa_photo',		     -- content_type
   'date_taken',             -- attribute_name
   'date',		     -- datatype
   'Date taken',	     -- pretty_name
   'Dates taken',	     -- pretty_plural
   null,		     -- sort_order
   null,		     -- default_value
   'timestamp'		     -- column_spec
 );

select content_type__create_attribute (
   'pa_photo',		     -- content_type
   'flash',                  -- attribute_name
   'boolean',		     -- datatype
   'Flash used',	     -- pretty_name
   'Flash used',	     -- pretty_plural
   null,		     -- sort_order
   null,		     -- default_value
   'boolean'		     -- column_spec
 );

select content_type__create_attribute (
   'pa_photo',		     -- content_type
   'exposure_time',                  -- attribute_name
   'number',		     -- datatype
   'Exposure time',	     -- pretty_name
   'Exposure times',	     -- pretty_plural
   null,		     -- sort_order
   null,		     -- default_value
   'number'		     -- column_spec
 );

select content_type__create_attribute (
   'pa_photo',		     -- content_type
   'aperture',                  -- attribute_name
   'string',		     -- datatype
   'Aperture',	     -- pretty_name
   'Apertures',	     -- pretty_plural
   null,		     -- sort_order
   null,		     -- default_value
   'varchar'		     -- column_spec
 );

select content_type__create_attribute (
   'pa_photo',		     -- content_type
   'focus_distance',                  -- attribute_name
   'number',		     -- datatype
   'Focus distance',	     -- pretty_name
   'Focus distances',	     -- pretty_plural
   null,		     -- sort_order
   null,		     -- default_value
   'number'		     -- column_spec
 );

select content_type__create_attribute (
   'pa_photo',		     -- content_type
   'metering',                  -- attribute_name
   'string',		     -- datatype
   'Metering',	     -- pretty_name
   'Meterings',	     -- pretty_plural
   null,		     -- sort_order
   null,		     -- default_value
   'varchar'		     -- column_spec
 );

select content_type__create_attribute (
   'pa_photo',		     -- content_type
   'sha256',                  -- attribute_name
   'string',		     -- datatype
   'SHA256',	     -- pretty_name
   'SHA256',	     -- pretty_plural
   null,		     -- sort_order
   null,		     -- default_value
   'varchar'		     -- column_spec
 );

--
-- Add new mime types 
--
create function inline_0 () returns integer as '
declare
  v_count integer;
begin
  select count(*) into v_count from cr_mime_types where mime_type = ''image/jpeg'';

  if v_count = 0 then
    insert into cr_mime_types values (''JPEG image'', ''image/jpeg'', ''jpeg'');
  end if;

  select count(*) into v_count from cr_mime_types where mime_type = ''image/gif'';

  if v_count = 0 then
    insert into cr_mime_types values (''GIF image'', ''image/gif'', ''gif'');
  end if;

  select count(*) into v_count from cr_mime_types where mime_type = ''image/png'';

  if v_count = 0 then
    insert into cr_mime_types values (''PNG image'', ''image/png'', ''png'');
  end if;

  select count(*) into v_count from cr_mime_types where mime_type = ''image/tiff'';

  if v_count = 0 then
    insert into cr_mime_types values (''TIFF image'', ''image/tiff'', ''tiff'');
  end if;

  return 1;
end; ' language 'plpgsql';

select inline_0 ();

drop function inline_0 ();
