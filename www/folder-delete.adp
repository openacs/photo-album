<master>
<property name="title">@title@</property>
<property name="context">@context_list@</property>

<form method=POST action=folder-delete>
<input type=hidden name=folder_id value=@folder_id@>
<input type=hidden name=confirmed_p value="t">

<p>#photo-album.lt_Are_you_sure_you_want_1#

<p>
<center>
<input type=submit value="<#Yes,_Delete_It Yes, Delete It#>">
</center>

</form>

