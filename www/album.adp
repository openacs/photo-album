<master>
<property name="title">@title@</property>
<property name="context">@context@</property>
    <property name="header_suppress">1</property>
@page_nav@
@message@
<h2>@title@</h2>
<if @description@ not nil>
<p>@description@</p>
</if>
<if @story@ not nil>
<p>@story@</p>
</if>
<if @child_photo:rowcount@ gt 0>
<table align="center" cellspacing="5" cellpadding="5">
<grid name=child_photo cols=4 orientation=horizontal>
<if @child_photo.col@ eq 1>
<tr align="center" valign="top">
</if>
<if @child_photo.rownum@ le @child_photo:rowcount@>
<td><a href="photo?photo_id=@child_photo.photo_id@"><img src="images/@child_photo.thumb_path@" height="@child_photo.thumb_height@" width="@child_photo.thumb_width@" alt="@child_photo.caption@" /><br />
@child_photo.caption@</a>
</td>
</if>
<else>
<td>&nbsp;</td>
</else>
<if @child_photo.col@ eq 4>
</tr>
</if>
</grid>
</table>
@page_nav@
</if><else>
<p>This album does not contain anything.</p>
</else>
<ul>
<if @photo_p@ eq 1>
  <li><a href="photo-add?album_id=@album_id@">Add a single photo to this album</a></li>
  <li><a href="photos-add?album_id=@album_id@">Add a collection of photos to this album</a></li>
  <li><a href="photos-edit?album_id=@album_id@&page=@page@">Edit these photos</a></li>
</if>
<if @write_p@ eq 1>
  <li><a href="album-edit?album_id=@album_id@">Edit album attributes</a></li>
</if>
<if @move_p@ eq 1>
  <li><a href="album-move?album_id=@album_id@">Move this album to another folder</a></li>
</if>
<if @admin_p@ eq 1>
  <li><a href="/permissions/one?object_id=@album_id@">Modify this albums permissions</a></li>
</if>
<if @delete_p@ eq 1>
  <li><a href="album-delete?album_id=@album_id@">Delete this album</a></li>
</if>
</ul>
<p style="color: #999999;">Click on the small photos to see a bigger
version, the numbers to see different pages, or the Next or Previous
page links to move back and forth.  You can also pick photos for
printing or emailing on the individual photo display page.
</p>
<if @collections@ gt 0>
<p><a href="clipboards">View all of your clipboards</a>.</p>
</if>
