jQuery ->
  ($ "a#schedule_session_button").bind "click", ->
    lawyer_name = ($ @).data('fullname')

    ($ "div#schedule_session").center()
    ($ "div#schedule_session span.lawyer_name").html(lawyer_name)

  ($ "input#lawyer_photo").bind "change", ->
    label = ($ "span.file_select_value")
    input_value = ($ @).val()

    label.html(input_value.split(/\\/).pop()) if input_value.length > 0
