<master>
<property name="doc(title)">@title@</property>
<property name="context">@context_list@</property>

<image src="images/@path@" height=@height@ width=@width@>
<form method=POST action=photo-delete>
<input type=hidden name=photo_id value=@photo_id@>
<input type=hidden name=confirmed_p value="t">

<p>#photo-album.lt_Are_you_sure_you_want_2#
<p>
<center>
<input type=submit value="#photo-album._Yes_Delete#">
</center>

</form>

