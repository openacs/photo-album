<master>
<property name="title">@title@</property>
<property name="context_list">@context_list@</property>

<form method=POST action=folder-delete>
<input type=hidden name=folder_id value=@folder_id@>
<input type=hidden name=confirmed_p value="t">

<p>Are you sure you want to delete the folder "@title@"?  This action cannot be reversed.

<p>
<center>
<input type=submit value="Yes, Delete It">
</center>

</form>
