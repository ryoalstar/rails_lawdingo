//= require users/home
jQuery ->

  # ($ ".leveled-list input.parent-area").bind "click", ->
  #  value = ($ this).attr("checked") is "checked" ? "true" : "false"
  #  ($ ".sub[data-parent-id='#{($ this).data("id")}']").find("input").attr "checked", value

  # Bind loading spinner to ajaxStart and ajaxStop
  spin_opts = {
    lines: 13,
    length: 7,
    width: 4,
    radius: 11,
    rotate: 0,
    color: '#222',
    speed: 1,
    trail: 60,
    shadow: false,
    hwaccel: false,
    className: 'spinner',
    zIndex: 9999,
    top: 'auto',
    left: 'auto'
  }

  ($ "body.home").ajaxStart -> ($ "body").spin(spin_opts)
  ($ "body.home").ajaxStop -> ($ "body").spin(false)

  # Practice areas checkboxes behavior
  ($ "#leveled-list_practice_areas input.parent-area").bind "change", ->
    input = ($ this)
    parent_id = input.data "id"
    checked = input.is ":checked"

    console.log checked

    children_areas = input.parent().find("[data-parent-id='#{parent_id}'] input")
    children_areas.each (index, element) -> ($ element).attr "checked", checked
  
  ($ "a#close_notice").bind "click", (e)-> 
    $(e.target).parents(".notice").hide()
    $(e.target).parents(".notice_wrapper").hide()
    

    

  ($ "a#barids_opener").bind "click", -> ($ "div#bar_membership").center()
  ($ "a#practice_areas_opener").bind "click", -> ($ "div#practices").center()
  ($ "a#start_phone_session_button").bind "click", -> ($ "div#paid_schedule_session").center()

  ($ "a#schedule_session_button, div.description form.new_message input#message_body").live "click", ->
    lawyer_name = ($ @).data('fullname')
    ($ "div#schedule_session").center()
    ($ "div#schedule_session span.lawyer_name").html(lawyer_name)

  ($ "input#lawyer_photo").bind "change", ->
    label = ($ "span.file_select_value")
    input_value = ($ @).val()
    label.html(input_value.split(/\\/).pop()) if input_value.length > 0

  ($ "input#lawyer_rate").numeric() # accept only numbers
  ($ "input#lawyer_rate").bind "keyup", ->
    $input = ($ @)
    rate = $input.val().match(/\d+/)[0] unless $input.val() == "" # remove dollar sign
    rate_per_6minutes = rate / 10

    if $input.val() is ""
      $("span.rate_hint", $(this).parent()).html "Will be quoted per 0.1 hour."
    else
      $("span.rate_hint", $(this).parent()).html "Quoted as $#{rate_per_6minutes.toFixed(2)} per 6 mins."

  ($ "input#lawyer_hourly_rate").numeric() # accept only numbers
  ($ "input#lawyer_hourly_rate").bind "keyup", ->
    $input = ($ @)
    rate = $input.val().match(/\d+/)[0] unless $input.val() == "" # remove dollar sign
    rate_per_6minutes = rate / 10

    if $input.val() is ""
      $("span.rate_hint", $(this).parent()).html "Will be quoted per 0.1 hour."
    else
      $("span.rate_hint", $(this).parent()).html "Quoted as $#{rate_per_6minutes.toFixed(2)} per 6 mins."


  ($ "a#start_phone_session_button").bind "click", ->
    lawyerid = ($ @).data('lawyerid')
    free_consultation_duration = ($ @).data('fcd')
    lawyer_rate = ($ @).data('lrate')
    lawyer_first_name = ($ @).data('fullname')
    $("#lawyer_id").val(lawyerid)
    $('.paid_model_header').html("The first #{free_consultation_duration} minutes with #{lawyer_first_name} are free. To start the phone call, though, we require payment info, as any time past #{free_consultation_duration} minutes is billed at $#{lawyer_rate}/minute.");
    $('#payment_overlay_submit_button').val('Continue');
    
  $("#tabs_autoselect li").click ->
    $("#new_question").resetClientSideValidations()
    tabId = $(this).attr("data-target")
    tabContent = $("#" + tabId)
    tabContent.show().removeClass('hidden')
    $(this).addClass "selected"
    $(this).siblings().removeClass "selected"
    tabContent.siblings().hide()
    
    $("#question_state").hide()
    $("#question_area").hide()
    $("#autoselect_lawyer_wraper").removeClass("expanded")
    $("#autoselect_landing_wraper").removeClass("expanded")
    $("#new_question").enableClientSideValidations()
    return false
    
  users.initialize()

users =
  initialize: ->
    @handleApplyForm()
    
  no_charge: -> 
    ($ '#no_charge')
  lawyer_hourly_rate: ->
    ($ '#lawyer_hourly_rate')
  rate_hint: ->
    ($ 'span.rate_hint')
  handleApplyForm: ->
    _this = this
    @no_charge().on "change", ->
      if ($ this).is ':checked'
        _this.lawyer_hourly_rate().val('').attr('disabled', 'disabled')
        _this.rate_hint().html "Will be quoted per 0.1 hour."
      else
        _this.lawyer_hourly_rate().removeAttr('disabled')
    
this.users = users
