jQuery ->
  conversations.initialize()

conversations =
  initialize: ->
    @handleMessageForm()

  handleMessageForm: ->
    submit_message_button = ($ "body.conversations.summary input#no_answer_message_submit, #schedule_session a#send_message_button")
    submit_message_button.on "click", ->
      close_dialogs()
      message = ($ "textarea#message").val()
      lawyer_id = ($ "input#lawyer_id").val()
      token = ($ "[name='csrf-token']").attr "content"

      unless message == ""
        $.ajax(
          url: '/messages/send_message/' + lawyer_id,
          type: 'POST'
          data:
            email_msg: message,
            authenticity_token: token
          beforeSend: ->
            submit_message_button.val "Sending..."
          complete: ->
            submit_message_button.val "Leave message"
          success: (response) ->
            if response.result 
              alert('Your message has been sent.')
            else
              window.location.href = '/clients/new' 
        )
      else
        alert "You can not send blank message."
