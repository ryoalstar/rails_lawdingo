jQuery ->
  ($ "input#lawyer_photo").bind "change", ->
    label = ($ "span.file_select_value")
    input_value = ($ @).val()

    label.html(input_value.split(/\\/).pop()) if input_value.length > 0
