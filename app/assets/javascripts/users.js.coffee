jQuery ->
  ($ "a#barids_opener").bind "click", -> ($ "div#bar_membership").center()
  ($ "a#practice_areas_opener").bind "click", -> ($ "div#practices").center()
  ($ "a#start_phone_session_button").bind "click", -> ($ "div#paid_schedule_session").center()

  ($ "a#schedule_session_button").bind "click", ->
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
    rate_per_minute = rate / 60

    if $input.val() is ""
      ($ "span.rate_hint").html "Will be quoted by the min."
    else
      ($ "span.rate_hint").html "Quoted as $#{rate_per_minute.toFixed(2)}/minute."

  ($ "a#start_phone_session_button").bind "click", ->
    lawyerid = ($ @).data('attorneyid')
    free_consultation_duration = ($ @).data('fcd')
    lawyer_rate = ($ @).data('lrate')
    $("#attorney_id").val(lawyerid)
    $('.paid_model_header').html("The first #{free_consultation_duration} minutes with Harmeet are free. To start the phone call, though, we require payment info, as any time past #{free_consultation_duration} minutes is billed at $#{lawyer_rate}/minute.");
    $('#payment_overlay_submit_button').val('Continue');

