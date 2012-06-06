class Home

  initialize : ()->
    this.add_event_listeners()
    
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
    
    if document.location.pathname != "/lawyers"
      document.location.hash = "!#{document.location.pathname}"

    if document.location.hash == ""
      this.set_gs(default_state)
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
      this.set_defaults_s(default_state)
      this.submit()
      false
    $("#minimum_client_rating").bind "slidechange", (event, ui)=>
      $("#ratingval").val(Home.r[$("#minimum_client_rating .ui-slider-range").width()])
      this.set_defaults_s(default_state)
      this.submit()
      false
      
    $("#clear_data_search").click =>
        $("#search_query").val('')
        this.set_defaults(default_state)
        this.submit()
        false
    $("#search_query").keypress((e) =>
      if e.keyCode == 13
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
    if @practice_area == "All"
      "/lawyers/#{@service_type}/#{@state}"+params
    else
      "/lawyers/#{@service_type}/#{@state}/#{@practice_area}"+params
      
  current_hash : ()->
    "!#{this.current_search_url()}"
  current_title : ()->
    service_type = @service_type.replace /-/, " "
    state = @state.replace /_/g, " "
    practice_area = @practice_area.replace /-/, " "
    "#{service_type} from #{state} #{practice_area} Lawyers. Lawdingo: Ask a Lawyer Online Now"
  current_meta : ()->
    service_type = @service_type.replace /-/, " "
    state = @state.replace /-/, " "
    practice_area = @practice_area.replace /-/, " "
    "Ask a #{state} #{practice_area} lawyer for #{service_type} online now on Lawdingo."   
  read_hash : ()->
    hash = document.location.hash.replace("#!/lawyers/","")
    first = getUrlVars()["search_query"];
    if first
      $("#search_query").val(first)
      hash = document.location.hash.replace("?search_query=","")
      hash = document.location.hash.replace(first,"")
    hash = hash.split("/")
    this.set_service_type_fields_val(hash[0])
    this.set_state_fields_val(hash[1])
    if hash[2]
      this.set_practice_area_fields_val(hash[2]).parent().find('img').trigger('click')
    else 
      this.set_practice_area_fields_val("All").parent().find('img').trigger('click')
      
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
  set_defaults_s : (default_state)->
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
      
  getUrlVars = ->
    vars = []
    hash = undefined
    hashes = window.location.href.slice(window.location.href.indexOf("?") + 1).split("&")
    i = 0
    
    while i < hashes.length
      hash = hashes[i].split("=")
      vars.push hash[0]
      vars[hash[0]] = hash[1]
      i++
    vars
    
        
this.Home = new Home()
