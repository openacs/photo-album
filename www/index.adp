<master>
<property name="title">@folder_name@</property>
<property name="context">@context@</property>

<if @folder_description@ not nil>
<p>@folder_description@</p>
</if>
<div style="float: right"><ul>
<if @subfolder_p@ eq 1>
  <li><a href="folder-add?parent_id=@folder_id@">Add a new folder</a></li>
</if>
<if @album_p@ eq 1>
  <li><a href="album-add?parent_id=@folder_id@">Add a new album</a></li>
</if>
<if @write_p@ eq 1>
  <li><a href="folder-edit?folder_id=@folder_id@">Edit folder information</a></li>
</if>
<if @move_p@ eq 1>
  <li><a href="folder-move?folder_id=@folder_id@">Move this folder to another folder</a></li>
</if>
<if @delete_p@ eq 1>
  <li><a href="folder-delete?folder_id=@folder_id@">Delete this folder</a></li>
</if>
<if @admin_p@ eq 1>
  <li><a href="/permissions/one?object_id=@folder_id@">Modify this folder's permissions</a></li>
</if>
</ul>
</div>
<if @child:rowcount@ gt 0>

<table border="1" cellpadding="2" cellspacing="2">
 <tr>
  <td bgcolor="#cccccc">Name</td>
  <td bgcolor="#cccccc">Description</td>
 </tr>

<multiple name="child">
 <tr>
  <if @child.type@ eq "Folder">
   <td align="center"><a href="./?folder_id=@child.item_id@"><img src="graphics/folder.gif" alt="@child.name@" border="0" /></a></td>
  </if><else>
   <td align="center"><if @child.iconic@ not nil><a href="album?album_id=@child.item_id@"><img src="images/@child.iconic@" alt="@child.name@" border="0" /></if><else><img src="graphics/album.gif" alt="@child.name@" /></else></a></td>
  </else>
  <td>
<if @child.type@ eq "Folder"><a href="./?folder_id=@child.item_id@"></if><else><a href="album?album_id=@child.item_id@"></else>
@child.name@</a><if @child.description@ not nil><br />@child.description@</if></td>
 </tr>
</multiple>
</table>

</if><else>
<p>There are no items in this folder.</p>
</else>

<if @collections@ gt 0>
<p><a href="clipboards">View all of your clipboards</a>.</p>
</if>

<if @shutterfly_p@ eq "t">
    <p class="hint">
      To order prints of these photos you will first need to add them
      to a clipboard (you can do this when viewing an individual
      photo).  Once they are in a clipboard you can send them off to
      <a href="http://shutterfly.com">shutterfly.com</a> for
      printing from a <a href="clipboards">clipboard</a> screen.
    </p>
</if>
