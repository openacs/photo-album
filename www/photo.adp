  <master>
    <property name="title">@title@</property>
    <property name="context">@context@</property>
    <property name="header_suppress">1</property>

    @photo_nav_html@
    <div style="text-align: center; margin: 1em;">
      <if @show_base_link@ eq "t">
        <a href="base-photo?photo_id=@photo_id@"><img src="images/@path@/@title@" height="@height@" width="@width@" alt="@title@" /></a>
      </if><else>
        <img src="images/@path@/@title@" height="@height@" width="@width@" alt="@title@" />
      </else>
      <if @caption@ not nil>
        <p>@caption@</p>
      </if>
    </div>
    <if @description@ not nil>
      <p>@description@</p>
    </if>
    <if @story@ not nil>
      <p>Story: @story@</p>
    </if>
    <if @write_p@ eq 1 or @move_p@ eq 1 or @delete_p@ eq 1><ul>
        <if @write_p@ eq 1>
          <li><a href="photo-iconic?photo_id=@photo_id@">Make this photo the iconic photo for this album</a>
            <li><a href="photo-edit?photo_id=@photo_id@">Edit photo attributes</a>
        </if>
        <if @move_p@ eq 1>
          <li><a href="photo-move?photo_id=@photo_id@">Move photo to another album</a>
        </if>
        <if @delete_p@ eq 1>
          <li><a href="photo-delete?photo_id=@photo_id@">Delete this photo</a>
        </if>
      </ul>
    </if>



    @photo_nav_html@
    <div style="text-align: center">
      <a href="album?album_id=@album_id@&amp;page=@page_num@">Image thumbnail index</a>
    </div>
    <if @clipboards:rowcount@ eq 1>
      <multiple name="clipboards">
        <a href="clipboard-attach?photo_id=@photo_id@&amp;collection_id=@clipboards.collection_id@">Save this photo to print or view later</a>
      </multiple>
    </if>
    <if @clipboards:rowcount@ gt 1>
      <form class="inline" action="clipboard-attach">
        <if @collection_id@ gt 0>
          <strong>Image saved to clipboard.</strong>
        </if>
        <else> 
          <if @collection_id@ not nil>
            <strong>Image removed from clipboard.</strong>
          </if>
        </else>
        Save this photo to print or view later.  Place in folder 
        <input type="hidden" name="photo_id" value="@photo_id@"></input>
        <select name="collection_id">
          <multiple name="clipboards">
            <option value="@clipboards.collection_id@" @clipboards.selected@>@clipboards.title@</option>
          </multiple>
        </select>
        <input type="submit" value="Save"></input>
      </form>
    </if>
    <if @clipped:rowcount@ gt 0> 
      This photo clipped to: 
      <multiple name="clipped"> 
        <a href="clipboard-view?collection_id=@clipped.collection_id@">@clipped.title@</a>&nbsp;[<a href="clipboard-remove?collection_id=@clipped.collection_id@&photo_id=@photo_id@">remove</a>]&nbsp;
      </multiple>
    </if>
    <if @clipboards:rowcount@ gt 1>
      <br /><a href="clipboards">View all your clipboards</a>
    </if>
    
    
    
