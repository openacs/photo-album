<master>
<property name="title">@title@</property>
<property name="context">@context_list@</property>

<form method=POST action=album-delete>
<input type=hidden name=album_id value=@album_id@>
<input type=hidden name=confirmed_p value="t">

<p>#photo-album.lt_Are_you_sure_you_want#

<p>
<center>
<input type=submit value="<#Yes,_Delete_It Yes, Delete It>"
</center>

</form>

