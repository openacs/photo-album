<master>
<property name="title">@title@</property>
<property name="context">@context_list@</property>

<p>Name: @title@ 
<if @description@ not nil>
<p>Description: @description@
</if>
<if @story@ not nil>
<p>Story: @story@
</if>
<ul>
<if @photo_p@ eq 1>
  <li><a href="photo-add?album_id=@album_id@">Add a single photo to this album</a>
</if>
<if @photo_p@ eq 1>
  <li><a href="photos-add?album_id=@album_id@">Add a collection of photos to this album</a>
</if>
<if @write_p@ eq 1>
  <li><a href="album-edit?album_id=@album_id@">Edit album attributes</a>
</if>
<if @move_p@ eq 1>
  <li><a href="album-move?album_id=@album_id@">Move album to another folder</a>
</if>
<if @delete_p@ eq 1>
  <li><a href="album-delete?album_id=@album_id@">Delete this album</a>
</if>
<if @admin_p@ eq 1>
  <li><a href="/permissions/one?object_id=@album_id@">Modify album permissions</a>
</if>
</ul>
<if @child_photo:rowcount@ gt 0>
   <form action="photos-edit-2">
      <input type=hidden name=album_id value="@album_id@">
      <input type=hidden name=page value="@page@">            
      <input type=submit value=Submit>
        <table>
          <multiple name="child_photo">
                <if @child_photo.rownum@ odd><tr bgcolor="#F0F0F0"></if><else><tr bgcolor="#FFFFFF"></else>
              <td>&nbsp;</td>
              <td align=center><input type=radio name="d.@child_photo.photo_id@"
                                      value=0 checked></td>
              <td>&nbsp;</td>
              <td rowspan=3>
                    <table>
                      <tr><td>Hide:</td><td><input type=checkbox name="hide.@child_photo.photo_id@" value=1></td></tr>
                      <tr><td>Caption:</td><td><input type=text name="caption.@child_photo.photo_id@" value="@child_photo.caption@" size=60></td></tr>
                      <tr><td>Story:</td><td><textarea name="story.@child_photo.photo_id@" cols="60" wrap="soft" rows="3">@child_photo.story@</textarea></td></tr>
                    <if @child_photo.datetaken@ not nil><tr><td colspan="2">Taken: @child_photo.datetaken@ @child_photo.camera_model@ @child_photo.focal_length@mm @child_photo.aperture@ <if @child_photo.flash@>Flash</if></td></tr></if>
                    </table>
              </td>
            </tr>
            <if @child_photo.rownum@ odd><tr bgcolor="#F0F0F0"></if><else><tr bgcolor="#FFFFFF"></else>
              <td><input type=radio name="d.@child_photo.photo_id@" value=90></td>
              <td align=center><a
                                  href="photo?photo_id=@child_photo.photo_id@" onclick="javascript:w=window.open('images/@child_photo.viewer_path@','@child_photo.photo_id@','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=@child_photo.window_width@,height=@child_photo.window_height@');w.focus();return false;"><img src="images/@child_photo.thumb_path@" width="@child_photo.thumb_width@" height="@child_photo.thumb_height@"></a></td>
              <td><input type=radio name="d.@child_photo.photo_id@" value=270></td>
            </tr>
            <if @child_photo.rownum@ odd><tr bgcolor="#F0F0F0"></if><else><tr bgcolor="#FFFFFF"></else>
              <td>&nbsp;</td>
              <td align=center><input type=radio name="d.@child_photo.photo_id@" value=180></td>
              <td>&nbsp;</td>
            </tr>
          </multiple>
        </table>
        <input type=submit value=Submit>
    </form>
</if><else>
<p>This album does not contain anything.
</else>
<p>
@page_nav;noquote@