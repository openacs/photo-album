<master>
<property name="title">@title@</property>
<property name="context">@context@</property>
<property name="header_suppress">1</property>

@photo_nav_html@
<div style="text-align: center">
<img src="images/@path@/@title@" height="@height@" width="@width@" alt="@title@" />
<if @caption@ not nil><p>@caption@</p></if>
</div>
<if @description@ not nil>
<p>@description@</p>
</if>
<if @story@ not nil>
<p>Story: @story@</p>
</if>
@photo_nav_html@
<div style="text-align: center">
<a href="album?album_id=@album_id@&amp;page=@page_num@">Image&nbsp;thumbnail&nbsp;index</a> 
| <a href="photo?photo_id=@photo_id@">Smaller&nbsp;image</a></div>
