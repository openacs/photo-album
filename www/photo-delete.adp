<master>
<property name="title">@title@</property>
<property name="context">@context_list@</property>

<image src="images/@path@" height=@height@ width=@width@>
<form method=POST action=photo-delete>
<input type=hidden name=photo_id value=@photo_id@>
<input type=hidden name=confirmed_p value="t">

<p>Are you sure you want to delete the photo "@title@"?  This action cannot be undone.
<p>
<center>
<input type=submit value="Yes, Delete It">
</center>

</form>
