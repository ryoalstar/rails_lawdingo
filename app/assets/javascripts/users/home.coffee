class Home

  initialize : ()->
    this.add_event_listeners()
    if document.location.hash == ""
      this.set_defaults()
    else
      this.read_hash()
      this.submit()
    
  submit : ()->
    $.ajax(this.current_search_url(),{
      complete : ()->
        console.log(arguments)
      dataType : 'script'

    })
    document.location.hash = this.current_hash()

  add_event_listeners : ()->
    this.form().submit(()=>
      this.submit()
      false
    )

    this.service_type_fields().click((e)=>
      this.set_service_type_fields_val(
        $(e.target).val()
      )
      this.submit()
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
    if @practice_area == "All"
      "/lawyers/#{@service_type}/#{@state}"
    else
      "/lawyers/#{@service_type}/#{@state}/#{@practice_area}"

  current_hash : ()->
    "!#{this.current_search_url()}"

  read_hash : ()->
    hash = document.location.hash.replace("#!/lawyers/","")
    hash = hash.split("/")
    this.set_service_type_fields_val(hash[0])
    this.set_state_fields_val(hash[1])
    if hash[2]
      this.set_practice_area_fields_val(hash[2])    


  set_defaults : ()->
    this.set_service_type_fields_val(
      this.service_type_fields()
        .filter("[data-default=1]")
        .val()
    )

    this.set_state_fields_val(
      this.state_fields().find(
        "option[data-default=1]"
      ).val()
    )

    this.set_practice_area_fields_val(
      this.practice_area_fields()
        .filter("[data-default=1]")
        .val()
    )

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
      .find("div#service_type input:radio")

  set_practice_area_fields_val : (val)->
    @practice_area = val

    this.form().find("ul.children").hide()

    $field = this.practice_area_fields()
      .filter("[value='#{val}']")
      .attr("checked", true)
    
    $field.parents("ul.practice-areas")
      .show()

    $field.parent()
      .find("ul.children").show()


  set_service_type_fields_val : (val)->
    @service_type = val
    this.service_type_fields()
      .filter("[value='#{val}']")
      .attr("checked", true)

  practice_area_fields : ()->
    this.form()
      .find("div#practice_areas input:radio")

this.Home = new Home()