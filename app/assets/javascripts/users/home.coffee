class Home

  initialize : ()->
    this.add_event_listeners()
    
    document.my_flag_search=false
    
    Home.h = {}
    Home.h[198] = 90
    Home.h[169] = 60
    Home.h[141] = 30
    Home.h[113] = 20
    Home.h[84] = 15
    Home.h[56] = 10
    Home.h[28] = 5
    Home.h[0] = 2
    
    Home.r = {}
    Home.r[198] = 5
    Home.r[148] = 4
    Home.r[99] = 3
    Home.r[49] = 2
    Home.r[0] = 1
    
    Home.v = {}
    Home.v[198] = 6
    Home.v[131] = 4
    Home.v[65] = 2
    Home.v[0] = 0
    
    Home.s = {}
    Home.s[198] = 1
    Home.s[131] = 2
    Home.s[65] = 3
    Home.s[0] = 4
    
    if document.location.pathname != "/lawyers"
      document.location.hash = "!#{document.location.pathname}"

    if document.location.hash == ""
      this.set_defaults(default_state)
      this.submit()
    else
      this.read_hash()
      this.submit()
    
  submit : ()->
    $.ajax(this.current_search_url(),{
      complete : ()->
      dataType : 'script'

    })
    document.location.hash = this.current_hash()
    document.title = this.current_title().replace /-lawyers/, ""
    new_meta = document.createElement('meta')
    new_meta.name = 'Current'
    new_meta.content = this.current_meta()
    document.getElementsByTagName('head')[0].appendChild(new_meta)
  add_event_listeners : ()->
    this.form().submit(()=>
      this.submit()
      false
    )
    $("#free_minutes_slider").bind "slidechange", (event, ui)=>
      $("#freetimeval").val(Home.h[$("#free_minutes_slider .ui-slider-range").width()])
      this.submit()
      false
    $("#minimum_client_rating").bind "slidechange", (event, ui)=>
      $("#ratingval").val(Home.r[$("#minimum_client_rating .ui-slider-range").width()])
      this.submit()
      false
    $("#hourly_rate").bind "slidechange", (event, ui)=>
      $("#hourlyratestart").val(Home.v[$("#hourly_rate .ui-slider-handle").first().position().left])
      $("#hourlyrateend").val(Home.v[$("#hourly_rate .ui-slider-handle").last().position().left])
      this.submit()
      false
    $("#law_school_quality").bind "slidechange", (event, ui)=>
      $("#schoolrating").val(Home.s[$("#law_school_quality .ui-slider-range").width()])
      this.submit()
      false
       
      
    $("#clear_data_search").click =>
        if document.my_flag_search
          document.my_flag_search=false
          $("#search_query").val('')
          $("#input_close_sea_img").hide()
          $("#input_search_bg_img").show()
          $("#search_query").submit()
          false
        if !document.my_flag_search && $("#search_query").val()
          document.my_flag_search=true
          $("#input_search_bg_img").hide()
          $("#input_close_sea_img").show()
          $("#search_query").submit()
          false
    $("#search_query").keypress((e) =>
      if e.keyCode == 13
        if !document.my_flag_search && $("#search_query").val()
          document.my_flag_search=true
          $("#input_search_bg_img").hide()
          $("#input_close_sea_img").show()
          $("#search_query").submit()
          false
        this.set_defaults_s(default_state)
        this.submit()
        false
      )

    this.service_type_fields().click((e)=>
      this.set_service_type_fields_val(
        $(e.target).attr('data-val')
      )
      this.submit()
      false
    )
    this.practice_area_fields().click((e)=>
      this.set_practice_area_fields_val(
        $(e.target).val()
      )
      this.submit()
    )
    this.state_fields().change((e)=>
      this.set_state_fields_val(
        $(e.target).val()
      )
      this.submit()
    )

  current_search_url : ()->
    params = "?"
    if $("#search_query").val()
      params += "&search_query=" + $("#search_query").val() 
    if $("#freetimeval").val()
      params += "&freetimeval=" + $("#freetimeval").val() 
    if $("#ratingval").val()
      params += "&ratingval=" + $("#ratingval").val()
    if ( $("#hourlyratestart").val() && $("#hourlyrateend").val() )
      params += "&hourlyratestart=" + $("#hourlyratestart").val() + "&hourlyrateend=" + $("#hourlyrateend").val()
    if $("#schoolrating").val()
      params += "&schoolrating=" + $("#schoolrating").val()
    
    if @practice_area == "All"
      "/lawyers/#{@service_type}/#{@state}"+params
    if !@service_type 
      @service_type="Legal-Advice"
    if !@state 
      @state="All-States"
    if !@practice_area 
      @practice_area="All"
    else
      practice_area = @practice_area.replace /\s+/g, "-"
      "/lawyers/#{@service_type}/#{@state}/#{practice_area}"+params
      
  current_hash : ()->
    "!#{this.current_search_url()}"
  current_title : ()->
    if !@service_type 
      @service_type="Legal-Advice"
    if !@state 
      @state="All-States"
    if !@practice_area 
      @practice_area="All"
    service_type = @service_type.replace /-/, " "
    state = @state.replace /_/, " "
    practice_area = @practice_area.replace /-/, " "
    "#{service_type} from #{state} #{practice_area} Lawyers. Lawdingo: Ask a Lawyer Online Now"
  current_meta : ()->
    service_type = @service_type.replace /-/, " "
    state = @state.replace /-/, " "
    practice_area = @practice_area.replace /-/, " "
    "Ask a #{state} #{practice_area} lawyer for #{service_type} online now on Lawdingo."   
  read_hash : ()->
    hash = document.location.hash.replace("#!/lawyers/","")
    hash = hash.split("/")
    this.set_service_type_fields_val(hash[0])
    this.set_state_fields_val(hash[1])
    if hash[2]
      this.set_practice_area_fields_val(hash[2]).parent().find('img').trigger('click')
    else 
      this.set_practice_area_fields_val("Any state")
      
  set_defaults : (default_state)->
    
    this.set_service_type_fields_val(
      this.service_type_fields()
        .filter("[data-default=1]")
        .attr('data-val')    
    )
    if (default_state == "")
      this.set_state_fields_val(
          this.state_fields().find(
            "option[data-default=1]"
          ).val()
      )
    else
      this.set_state_fields_val(default_state+'-lawyers')
      this.set_practice_area_fields_val(
        this.practice_area_fields()
          .filter("[data-default=1]")
          .val()
      ).parent().find('img').trigger('click')
      
  set_defaults_s : (default_state)->
    if (default_state == "")
      this.set_state_fields_val(
          this.state_fields().find(
            "option[data-default=1]"
          ).val()
      
      )
    else
      this.set_state_fields_val(default_state+'-lawyers')
      
  form : ()->
    $("form.filters")

  state_fields : ()->
    this.form().find("div#state select")

  set_state_fields_val : (val)->
    @state = val
    this.state_fields()
      .val(val)

  service_type_fields : ()->
    this.form()
      .find("div#service_type .service_type")

  set_practice_area_fields_val : (val)->
    @practice_area = val
    
    this.form().find(".children").hide()

    $field = this.practice_area_fields()
      .filter("[value='#{val}']")
      .attr("checked", true)

    is_national = $field.data "is-national"
    $notice_container = ($ @form).find(".national-area-notice")

    if is_national
      # Set state to Any state and hide select field
      this.set_state_fields_val(
        this.state_fields().find(
          "option[data-default=1]"
        ).val()
      )

      ($ @state_fields()).hide()

      # Show help notice for national area
      notice = "<span class=\"state\">#{$field.val()}</span> is not state specific."
      $notice_container.show().find("p").html(notice)

      # Show states select field on link click
      show_states_selector_link = $notice_container.find("a.show-states-selector")
      show_states_selector_link.live "click", (event) => 
        event.preventDefault()
        ($ @state_fields()).show()
        $notice_container.hide()
    else
      # Hide notice and show states select field
      ($ @state_fields()).show()
      $notice_container.hide()
			
    $field.parents(".practice-areas")
      .show()

    $field.parent().next().show() unless @service_type == "Legal-Services"
    $field


  set_service_type_fields_val : (val)->
    @service_type = val
    this.service_type_fields()

      .removeClass('selected')
      .filter("[data-val='#{val}']")
      .addClass("selected")
    
    if val == "Legal-Services"
      @practice_area_fields().parent().find(".children").hide()
    else
      $field = @practice_area_fields().filter("[checked='checked']")
      $field.parents(".practice-areas").show()
      $field.parent().find(".children").show()

  practice_area_fields : ()->
    this.form()
      .find("div#practice_areas input:radio")

this.Home = new Home()
