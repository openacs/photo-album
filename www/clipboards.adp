  <master>
    <property name="title">Your clipboards</property>
    <property name="context">Clipboards</property>
    <if @user_id@ eq 0> 
      You will have to <a href="/register/">log in</a> or
      <a href="/register/">register</a>
      in order to manage clipboards.
    </if>
    <else>
      <if @clipboards:rowcount@ eq 0>
        You do not currently have any clipboards defined.  You will
        need to browse the <a href="./">photos</a> and add them to a clipboard to use 
        this part of the site.
      </if>
      <else> 
        <ul>
          <multiple name="clipboards">
            <li> <a href="clipboard-view?collection_id=@clipboards.collection_id@">@clipboards.title@</a>
              (@clipboards.photos@ photos) 
              [ <a href="clipboard-ae?collection_id=@clipboards.collection_id@">edit
                name</a> | <a href="clipboard-delete?collection_id=@clipboards.collection_id@">delete clipboard</a> ]</li>
          </multiple>
        </ul>
      </else>
    </else>