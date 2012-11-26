class AppointmentForm
  
  constructor : (lawyer_id)->
    @div = $("#appointment_form_#{lawyer_id}")
    this.add_click_listeners()
    this

  add_click_listeners : ()->
    @div.find("a.appointment-time").click (e)=>
      @div.find("a.appointment-time").removeClass("selected")
      $(e.target).addClass("selected")
      @div.find("#appointment_time").val($(e.target).attr("data-time"))
      @div.find(".appointment-info").html(
        "Appointment set at #{$(e.target).attr("data-time-formatted")}"
      )
      false

    @div.find("a.more").click (e)=>
      @div.find("a.more").parent().hide()
      @div.find("li.hidden").removeClass('hidden')
      false
      
    ($ ".profile_info a.arrows#right_arrow").on 'click', ->
      if parseInt(($ '.available-appointments').css('left')) < -2900
        ($ '.profile_info a.arrows#right_arrow').addClass('hidden')
        
      if parseInt(($ '.available-appointments').css('left')) < 415
        ($ '.profile_info a.arrows#left_arrow').removeClass('hidden')
      
      ($ '.available-appointments').animate(
        left: '-=415'
      , 1000)
      
    ($ ".profile_info a.arrows#left_arrow").on 'click', ->
      if parseInt(($ '.available-appointments').css('left')) > -3400
        ($ '.profile_info a.arrows#right_arrow').removeClass('hidden')
        
      if parseInt(($ '.available-appointments').css('left')) > -450
        ($ @).addClass('hidden')
        
      ($ '.available-appointments').animate(
        left: '+=415px'
      , 1000)

    radios = @div.find(
      "#appointment_appointment_type_phone, " 
      + "#appointment_appointment_type_video"
    )
    radios.click (e)=>
      if $(e.target).attr("checked")
        val = $(e.target).attr("id") == "appointment_appointment_type_video"
        @div.find("#appointment_contact_number").attr('disabled', val)

    radios.each (e)=>
      $(e.target).triggerHandler('click')

    @div.find("form").submit (e)=>
      if this.isClientHasPhone() && this.checkLawyersStateAndPracticeArea() 
        this.save()
      false
      
    @state_name_and_practice_area_select().on "change", =>
      this.checkLawyersStateAndPracticeArea()
      
    @appointment_contact_number().on "change", =>
      @enable_submit_button()
      @clear_appointment_warning() 
     
  state_name_select : ->
    @div.find("#appointment_state_id")
  practice_area_select : -> 
    @div.find("#appointment_practice_area_id")
  state_name_and_practice_area_select : -> 
    @div.find("#appointment_state_id, #appointment_practice_area_id")
  appointment_warning : ->
    @div.find("#appointment_warning")
  submit_button : ->
    @div.find(".submit_appointment_button")
  appointment_contact_number : -> 
    @div.find("#appointment_contact_number")
  checkLawyersStateAndPracticeArea: => 
    current_state_id = @state_name_select().val()
    current_state_name = @state_name_select().find("option[value='#{current_state_id}']").text();
    current_practice_area_id = @practice_area_select().val()
    current_practice_area_name = @practice_area_select().find("option[value='#{current_practice_area_id}']").text();
    lawyer_id = @div.attr("data-id")
    lawyer_name = @div.attr("data-full_name")

    # both are true
    if this.isLawyersState(current_state_id, lawyer_id) && this.isLawyersPracticeArea(current_practice_area_id, lawyer_id)
      this.enable_submit_button()
      this.clear_appointment_warning() 
      true
      
    else if !this.isStateSelected() && !this.isPracticeAreaSelected() 
      this.disable_submit_button()
      this.write_appointment_state_and_practice_area_missing_warning()
      false
      
    else if !this.isPracticeAreaSelected()  
      this.disable_submit_button()
      this.write_appointment_practice_area_missing_warning() 
      false
      
    else if !this.isStateSelected() && !@isPracticeAreaNational()
      this.disable_submit_button()
      this.write_appointment_state_missing_warning() 
      false
      
    # isLawyersState false
    else if !this.isLawyersState(current_state_id, lawyer_id) && this.isLawyersPracticeArea(current_practice_area_id, lawyer_id)
      this.disable_submit_button()
      this.write_appointment_state_warning(current_state_name, lawyer_name) 
      false
    # isLawyersPracticeArea false
    else if this.isLawyersState(current_state_id, lawyer_id) && !this.isLawyersPracticeArea(current_practice_area_id, lawyer_id)
      this.disable_submit_button()
      this.write_appointment_practice_area_warning(current_practice_area_name, lawyer_name) 
      false
    else #
      this.disable_submit_button()
      this.write_appointment_state_and_practice_area_warning(current_state_name, current_practice_area_name, lawyer_name)
      false  
  isStateSelected: =>
    parseInt(this.state_name_select().val()) > 0
  isPracticeAreaSelected: =>
    parseInt(this.practice_area_select().val()) > 0
  isStateAndPracticeAreaSelected: => 
    this.isStateSelected() && this.isPracticeAreaSelected()
  isClientHasPhone: ->
    unless @appointment_contact_number().val().length
      @disable_submit_button()
      @write_phone_warning()
      false
    else
      true
  isLawyersPracticeArea: (practice_area_id, lawyer_id) => 
    return false if practice_area_id == ''
    practice_areas = []
    $.ajax(
      url: '/lawyers/'+lawyer_id+'/practice_areas.json',
      async: false,
      dataType: 'json',
      success: (response) ->
        if response.practice_areas.length 
          $.each response.practice_areas, ( key, practice_area ) -> 
            practice_areas.push(practice_area)
    )
    this.inArray(practice_area_id, practice_areas)
  write_appointment_state_and_practice_area_warning: (state_name,practice_area_name,lawyer_name) =>
    state_name_for_url = this.state_name_for_url(state_name)
    practice_area_name_for_url = this.practice_area_name_for_url(practice_area_name)
    text = "#{lawyer_name} isn't licensed in #{state_name} and doesn't advise on #{practice_area_name}, and thus can't help you. Find <a href='/lawyers/Legal-Advice/#{state_name_for_url}/#{practice_area_name_for_url}'>#{state_name} lawyers advising on #{practice_area_name}</a>"
    this.appointment_warning().html(text)
  write_appointment_practice_area_warning: (practice_area_name,lawyer_name) =>
    practice_area_name_for_url = this.practice_area_name_for_url(practice_area_name)
    text = "#{lawyer_name} doesn't advise on #{practice_area_name}, and thus can't help you. Find <a href='/lawyers/Legal-Advice/All-States/#{practice_area_name_for_url}'>Lawyers advising on #{practice_area_name}</a>"
    this.appointment_warning().html(text)
  write_appointment_state_warning: (state_name,lawyer_name) =>
    state_name_for_url = this.state_name_for_url(state_name)
    text = "#{lawyer_name} isn't licensed in #{state_name} and, thus can't help you. Find <a href='/lawyers/Legal-Advice/#{state_name_for_url}'>#{state_name} lawyers</a>"
    this.appointment_warning().html(text)
  write_appointment_state_and_practice_area_missing_warning: =>
    text = "Please select state and type of law."
    this.appointment_warning().html(text)
  write_appointment_state_missing_warning: =>
    text = "Please select state."
    this.appointment_warning().html(text)
  write_appointment_practice_area_missing_warning: =>
    text = "Please select type of law."
    this.appointment_warning().html(text)
  write_phone_warning: =>
    text = "Please add phone number."
    this.appointment_warning().html(text)
  practice_area_name_for_url: (practice_area_name) ->
    practice_area_name.replace /\s+/g, "-"
  state_name_for_url: (state_name) ->
    "#{state_name.replace /\s+/g, "_"}-lawyers"
  clear_appointment_warning: () =>
    this.appointment_warning().html('')
  isPracticeAreaNational: ->
    current_practice_area_id = @practice_area_select().val()
    current_practice_area_is_national = @practice_area_select().find("option[value='#{current_practice_area_id}']").attr('is_national');
    current_practice_area_is_national == 'true'
  isLawyersState: (state, lawyer_id) =>
    return true if @isPracticeAreaNational()
    return false if state == ''
    states = []
    $.ajax(
      url: '/lawyers/'+lawyer_id+'/states.json',
      async: false,
      dataType: 'json',
      success: (response) ->
        if response.states.length 
          $.each response.states, ( key, state ) -> 
            states.push(state)
    )
    this.inArray(state, states)
  inArray: (value, array) ->
    result = false
    $.each array, ( key, obj ) -> 
      if value == obj.id.toString()
        result = true
    result    
  disable_submit_button: () =>
    this.submit_button().attr('disabled','disabled')
  enable_submit_button: () =>
    this.submit_button().removeAttr('disabled')
  show : ()->
    @div.find("form").show()
    @div.find("div.message").hide()
    @div.removeClass('consutation_scheduled')
    @div.jqdialog({
      height : 500,
      width : 500,
      modal : true,
      draggable : false,
      resizable : false
    })
  has_payment_info: ->
    result = false
    $.ajax
      url : '/haveIPaymentInfo'
      dataType: "json"
      async: false
      success: (response) -> 
        result = response.result
    result
  save : ()->
    $.ajax(
      url : "#{@div.find("form").attr("action")}.json",
      type : "POST",
      data : @div.find("form").serialize(),
      dataType : "json"
      statusCode : 
        201 : (data, status, xhr)=>
          lawyer_id = @div.attr("data-id")
          if @has_payment_info()
            this.show_success(data.appointment)
          else
            window.location.href = "/lawyers/#{lawyer_id}/call-payment/appointment"
        200 : (data, status, xhr)=>
          alert "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
          $('.dialog-close').click();
        302 : (data, status, xhr)=>
          alert "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
          $('.dialog-close').click();
        422 : (xhr, status, text)=>
          this.show_error(JSON.parse(xhr.responseText).appointment.errors)
          true
    )
  # TODO: make this use a templating language
  show_success : (appointment)->
    str = "<h2>Consultation Scheduled.</h2>
      <p>Thanks! Your appointment has been scheduled for #{appointment.time}.
        #{appointment.attorney_name} should be online then, so at
        that time please come to Lawdingo and contact the attorney</p><hr /><a href='#' class='button dialog-close'>Ok</a>"
    @div.find("form").hide()
    @div.find("div.message").html(str).show()
    @div.addClass('consutation_scheduled')

  show_error : (errors)->
    error_string = ""
    $.each(errors, (field, messages)->
      $.each(messages, (j, message)->
        error_string += "#{message}<br/>"
      )
    )
    @div.find("div.error")
      .show()
      .html(error_string)

  select_time : (time)->
    @div.find("a.appointment-time[data-time='#{time}']").click()
    
    
  $(".dialog-close").live "click", ->
    $(".ui-dialog").hide()
    $(".ui-widget-overlay").hide()
    
this.AppointmentForm = AppointmentForm