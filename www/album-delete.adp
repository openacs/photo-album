<master>
<property name="title">@title@</property>
<property name="context">@context_list@</property>

<form method=POST action=album-delete>
<input type=hidden name=album_id value=@album_id@>
<input type=hidden name=confirmed_p value="t">

<p>Are you sure you want to delete the album "@title@"?  This action cannot be reversed.

<p>
<center>
<input type=submit value="Yes, Delete It">
</center>

</form>
