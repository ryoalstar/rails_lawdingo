jQuery ->
  ($ "a#schedule_session_button").bind "click", ->
    lawyer_name = ($ @).data('fullname')

    ($ "div#schedule_session").center()
    ($ "div#schedule_session span.lawyer_name").html(lawyer_name)

  ($ "input#lawyer_photo").bind "change", ->
    label = ($ "span.file_select_value")
    input_value = ($ @).val()

    label.html(input_value.split(/\\/).pop()) if input_value.length > 0

  ($ "input#lawyer_rate").numeric() # accept only numbers
  ($ "input#lawyer_rate").bind "change", ->
    $input = ($ @)
    rate = $input.val().match(/\d+/)[0] unless $input.val() == "" # remove dollar sign
    rate_per_minute = rate / 60

    if $input.val() is ""
      ($ "span.rate_hint").html "Will be quoted by the min." if $input.val() == ""
    else
      ($ "span.rate_hint").html "Quoted as $#{rate_per_minute.toPrecision(2)}/minute."

