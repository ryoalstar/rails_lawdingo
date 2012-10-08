# conversations.js
jQuery ->
  messages.initialize()

messages =
  initialize: ->
    @handleMessageFromLawyerMiniProfileForm()

  handleMessageFromLawyerMiniProfileForm: ->
    submit_message_button = ($ "div.description form.new_message input#message_submit_button")
    submit_message_button.live "click", ->
      form = $(this).parent('form.new_message')
      lawyer_id = form.find('#message_lawyer_id').val()
      message = form.find('#message_body').val()
      token = ($ "[name='csrf-token']").attr "content"
      unless message == ""
        $.ajax(
          url: '/messages/send_message/' + lawyer_id,
          type: 'POST'
          data:
            email_msg: message,
            authenticity_token: token
          success: (response) ->
            if response.result 
              alert('Your message has been sent.')
            else
              window.location.href = '/clients/new' 
        )
      else
        alert "You can not send blank message."
      false  