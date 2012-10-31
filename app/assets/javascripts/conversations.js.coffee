jQuery ->
  conversations.initialize()

conversations =
  initialize: ->
    @handleMessageForm()

  handleMessageForm: ->
    submit_message_button = ($ "body.conversations.summary input#no_answer_message_submit, #schedule_session #send_message_button")
    state_name_select = ($ "#schedule_session #state_name")
    practice_area_select = ($ "#schedule_session #practice_area")
    state_name_and_practice_area_select = ($ "#schedule_session #state_name, #schedule_session #practice_area")
    submit_message_button.on "click", ->
      if conversations.checkLawyersStateAndPracticeArea(submit_message_button,state_name_select,practice_area_select,state_name_and_practice_area_select)
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
              'message[body]': message,
              'message[lawyer_id]': lawyer_id,
              'message[state_id]': state_name_select.val(),
              'message[practice_area_id]': practice_area_select.val(),
              authenticity_token: token
            beforeSend: ->
              submit_message_button.val "Sending..."
            complete: ->
              submit_message_button.val "Leave message"
            success: (response) ->
              if response.result
                alert 'Your message has been sent.'
              else
                window.location.href = '/clients/new' 
          )
        else
          alert "You can not send blank message."
      false
    state_name_and_practice_area_select.on "change", ->
      conversations.checkLawyersStateAndPracticeArea(submit_message_button,state_name_select,practice_area_select,state_name_and_practice_area_select)
  checkLawyersStateAndPracticeArea: (submit_message_button,state_name_select,practice_area_select,state_name_and_practice_area_select,lawyer_name) -> 
    current_state_id = state_name_select.val()
    current_state_name = ($ "#schedule_session #state_name option[value='#{current_state_id}']").text();
    current_practice_area_id = practice_area_select.val()
    current_practice_area_name = ($ "#schedule_session #practice_area option[value='#{current_practice_area_id}']").text();
    lawyer_id = ($ "input#lawyer_id").val()
    lawyer_name = ($ "#schedule_session span.lawyer_name").text()
    
    # both are true
    if conversations.isLawyersState(current_state_id, lawyer_id) && conversations.isLawyersPracticeArea(current_practice_area_id, lawyer_id)
      conversations.enable_submit_message_button submit_message_button 
      conversations.clear_schedule_session_warning() 
      true
      
    else if !conversations.isStateSelected() && !conversations.isPracticeAreaSelected() 
      conversations.disable_submit_message_button submit_message_button
      conversations.write_schedule_session_state_and_practice_area_missing_warning()
      false
      
    else if !conversations.isStateSelected()  
      conversations.disable_submit_message_button submit_message_button
      conversations.write_schedule_session_state_missing_warning() 
      false
      
    else if !conversations.isPracticeAreaSelected()  
      conversations.disable_submit_message_button submit_message_button
      conversations.write_schedule_session_practice_area_missing_warning() 
      false
      
    # isLawyersState false
    else if !conversations.isLawyersState(current_state_id, lawyer_id) && conversations.isLawyersPracticeArea(current_practice_area_id, lawyer_id)
      conversations.disable_submit_message_button submit_message_button 
      conversations.write_schedule_session_state_warning(current_state_name, lawyer_name) 
      false
    # isLawyersPracticeArea false
    else if conversations.isLawyersState(current_state_id, lawyer_id) && !conversations.isLawyersPracticeArea(current_practice_area_id, lawyer_id)
      conversations.disable_submit_message_button submit_message_button 
      conversations.write_schedule_session_practice_area_warning(current_practice_area_name, lawyer_name) 
      false
    else #
      conversations.disable_submit_message_button submit_message_button 
      conversations.write_schedule_session_state_and_practice_area_warning(current_state_name, current_practice_area_name, lawyer_name)
      false

  state_name_select: -> 
    ($ "#schedule_session #state_name")
  practice_area_select: -> 
    ($ "#schedule_session #practice_area")
  schedule_session_warning: ->
    ($ "#schedule_session_warning")
  isStateSelected: ->
    parseInt(conversations.state_name_select().val()) > 0
  isPracticeAreaSelected: ->
    parseInt(conversations.practice_area_select().val()) > 0
  isStateAndPracticeAreaSelected: -> 
    conversations.isStateSelected() && conversations.isPracticeAreaSelected()
  isLawyersPracticeArea: (practice_area_id, lawyer_id) ->
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
    conversations.inArray(practice_area_id, practice_areas)
  write_schedule_session_state_and_practice_area_warning: (state_name,practice_area_name,lawyer_name) ->
    conversations.isStateSelected()
    state_name_for_url = conversations.state_name_for_url(state_name)
    practice_area_name_for_url = conversations.practice_area_name_for_url(practice_area_name)
    text = "#{lawyer_name} isn't licensed in #{state_name} and doesn't advise on #{practice_area_name}, and thus can't help you. Find <a href='/lawyers/Legal-Advice/#{state_name_for_url}/#{practice_area_name_for_url}'>#{state_name} lawyers advising on #{practice_area_name}</a>"
    conversations.schedule_session_warning().html(text)
  write_schedule_session_practice_area_warning: (practice_area_name,lawyer_name) ->
    practice_area_name_for_url = conversations.practice_area_name_for_url(practice_area_name)
    text = "#{lawyer_name} doesn't advise on #{practice_area_name}, and thus can't help you. Find <a href='/lawyers/Legal-Advice/All-States/#{practice_area_name_for_url}'>Lawyers advising on #{practice_area_name}</a>"
    conversations.schedule_session_warning().html(text)
  write_schedule_session_state_warning: (state_name,lawyer_name) ->
    state_name_for_url = conversations.state_name_for_url(state_name)
    text = "#{lawyer_name} isn't licensed in #{state_name} and, thus can't help you. Find <a href='/lawyers/Legal-Advice/#{state_name_for_url}'>#{state_name} lawyers</a>"
    conversations.schedule_session_warning().html(text)
  write_schedule_session_state_and_practice_area_missing_warning: ->
    text = "Please, select State and Type of law."
    conversations.schedule_session_warning().html(text)
  write_schedule_session_state_missing_warning: ->
    text = "Please, select State."
    conversations.schedule_session_warning().html(text)
  write_schedule_session_practice_area_missing_warning: ->
    text = "Please, select Type of law."
    conversations.schedule_session_warning().html(text)
  practice_area_name_for_url: (practice_area_name) ->
    practice_area_name.replace /\s+/g, "-"
  state_name_for_url: (state_name) ->
    "#{state_name.replace /\s+/g, "_"}-lawyers"
  clear_schedule_session_warning: () ->
    schedule_session_warning = ($ "#schedule_session_warning")
    schedule_session_warning.html('')
  isLawyersState: (state, lawyer_id) ->
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
    conversations.inArray(state, states)
  inArray: (value, array) ->
    result = false
    $.each array, ( key, obj ) -> 
      if value == obj.id.toString()
        result = true
    result    
  disable_submit_message_button: (button) ->
    button.attr('disabled','disabled')
  enable_submit_message_button: (button) ->
    button.removeAttr('disabled')
    
this.conversations = conversations

