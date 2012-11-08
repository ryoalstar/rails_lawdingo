jQuery ->
  state_and_practice_area_validation.initialize()

state_and_practice_area_validation =
  initialize: ->
    @practice_areas = []
    @states = []
    @handleStateAndPracticeAreaDialogWindow()
    @handleStateAndPracticeAreaValidation()
    @handleStateAndPracticeAreaValidationForm()

  online_icons: -> 
    ($ '.online_icons span.video.online a, .online_icons span.voice.online a')
  dialog_overlay: -> 
    ($ '#dialog-overlay')
  dialog_close: -> 
    ($ '.dialog-close')
  dialog_overlay_and_close: -> 
    ($ '#dialog-overlay, .dialog-close')
  dialog_div: -> 
    ($ '#state_and_practice_area_validation' )
  dialog_window: -> 
    ($ '.dialog-window')
  close: -> 
    ($ '<div class="dialog-close"></div>')
  dialog_opener: -> 
    ($ '.state-and-practice-area-validation-dialog-opener')
  continue_button: ->
    ($ '#state_and_practice_area_validation #continue_button')

  handleStateAndPracticeAreaDialogWindow: ->
    @dialog_div().append( @close() )
    @dialog_overlay_and_close().live "click", =>
      @dialog_window().hide()
      @close().hide()
      @dialog_overlay().hide()

  handleStateAndPracticeAreaValidation: ->
    _this = this
    @dialog_opener().live "click", ->
      _this.practice_areas = []
      _this.states = []
      if ($ @).attr("data-l-id") != undefined
        ($ ".current_selected_lawyer").val(($ @).attr("data-l-id"));
        ($ "div#state_and_practice_area_validation span.lawyer_name").html(($ @).attr("data-fullname"));
        _this.url = ($ @).attr("href")
        _this.dialog_overlay().show()
        _this.dialog_div().show()
      false
  handleStateAndPracticeAreaValidationForm: ->
    @state_name_and_practice_area_select().on "change", =>
      @checkLawyersStateAndPracticeArea()
    @continue_button().live "click", =>
      if @checkLawyersStateAndPracticeArea()
        window.location.href = @url
  checkLawyersStateAndPracticeArea: ->
    current_state_id = @state_name_select().val()
    current_state_name = @state_name_select().find("option[value='#{current_state_id}']").text();
    current_practice_area_id = @practice_area_select().val()
    current_practice_area_name = @practice_area_select().find("option[value='#{current_practice_area_id}']").text();
    lawyer_id = ($ "input#lawyer_id").val()
    lawyer_name = ($ "#state_and_practice_area_validation span.lawyer_name").text()
    
    # both are true
    if @isLawyersState(current_state_id, lawyer_id) && @isLawyersPracticeArea(current_practice_area_id, lawyer_id)
      @enable_submit_message_button()
      @clear_state_and_practice_area_validation_warning() 
      true
      
    else if !@isStateSelected() && !@isPracticeAreaSelected() 
      @disable_submit_message_button()
      @write_state_and_practice_area_validation_state_and_practice_area_missing_warning()
      false
      
    else if !@isStateSelected()
      @disable_submit_message_button()
      @write_state_and_practice_area_validation_state_missing_warning() 
      false
      
    else if !@isPracticeAreaSelected()  
      @disable_submit_message_button()
      @write_state_and_practice_area_validation_practice_area_missing_warning() 
      false
      
    # isLawyersState false
    else if !@isLawyersState(current_state_id, lawyer_id) && @isLawyersPracticeArea(current_practice_area_id, lawyer_id)
      @disable_submit_message_button()
      @write_state_and_practice_area_validation_state_warning(current_state_name, lawyer_name) 
      false
    # isLawyersPracticeArea false
    else if @isLawyersState(current_state_id, lawyer_id) && !@isLawyersPracticeArea(current_practice_area_id, lawyer_id)
      @disable_submit_message_button()
      @write_state_and_practice_area_validation_practice_area_warning(current_practice_area_name, lawyer_name) 
      false
    else #
      @disable_submit_message_button()
      @write_state_and_practice_area_validation_state_and_practice_area_warning(current_state_name, current_practice_area_name, lawyer_name)
      false
    
  state_name_select: -> 
    ($ "#state_and_practice_area_validation #state_name")
  practice_area_select: -> 
    ($ "#state_and_practice_area_validation #practice_area")
  state_name_and_practice_area_select: ->
    ($ "#state_and_practice_area_validation #state_name, #state_and_practice_area_validation #practice_area")
  state_and_practice_area_validation_warning: ->
    ($ "#state_and_practice_area_validation_warning")
  isStateSelected: ->
    parseInt(@state_name_select().val()) > 0
  isPracticeAreaSelected: ->
    parseInt(@practice_area_select().val()) > 0
  isStateAndPracticeAreaSelected: -> 
    @isStateSelected() && @isPracticeAreaSelected()
  isLawyersPracticeArea: (practice_area_id, lawyer_id) ->
    return false if practice_area_id == ''
    unless @practice_areas.length
      $.ajax(
        url: '/lawyers/'+lawyer_id+'/practice_areas.json',
        async: false,
        dataType: 'json',
        success: (response) =>
          if response.practice_areas.length 
            $.each response.practice_areas, ( key, practice_area ) -> 
              _this.practice_areas.push(practice_area)
      )
    @inArray(practice_area_id, @practice_areas)
  write_state_and_practice_area_validation_state_and_practice_area_warning: (state_name,practice_area_name,lawyer_name) ->
    @isStateSelected()
    state_name_for_url = @state_name_for_url(state_name)
    practice_area_name_for_url = @practice_area_name_for_url(practice_area_name)
    text = "#{lawyer_name} isn't licensed in #{state_name} and doesn't advise on #{practice_area_name}, and thus can't help you. Find <a href='/lawyers/Legal-Advice/#{state_name_for_url}/#{practice_area_name_for_url}'>#{state_name} lawyers advising on #{practice_area_name}</a>"
    @state_and_practice_area_validation_warning().html(text)
  write_state_and_practice_area_validation_practice_area_warning: (practice_area_name,lawyer_name) ->
    practice_area_name_for_url = @practice_area_name_for_url(practice_area_name)
    text = "#{lawyer_name} doesn't advise on #{practice_area_name}, and thus can't help you. Find <a href='/lawyers/Legal-Advice/All-States/#{practice_area_name_for_url}'>Lawyers advising on #{practice_area_name}</a>"
    @state_and_practice_area_validation_warning().html(text)
  write_state_and_practice_area_validation_state_warning: (state_name,lawyer_name) ->
    state_name_for_url = @state_name_for_url(state_name)
    text = "#{lawyer_name} isn't licensed in #{state_name} and, thus can't help you. Find <a href='/lawyers/Legal-Advice/#{state_name_for_url}'>#{state_name} lawyers</a>"
    @state_and_practice_area_validation_warning().html(text)
  write_state_and_practice_area_validation_state_and_practice_area_missing_warning: ->
    text = "Please, select State and Type of law."
    @state_and_practice_area_validation_warning().html(text)
  write_state_and_practice_area_validation_state_missing_warning: ->
    text = "Please, select State."
    @state_and_practice_area_validation_warning().html(text)
  write_state_and_practice_area_validation_practice_area_missing_warning: ->
    text = "Please, select Type of law."
    @state_and_practice_area_validation_warning().html(text)
  practice_area_name_for_url: (practice_area_name) ->
    practice_area_name.replace /\s+/g, "-"
  state_name_for_url: (state_name) ->
    "#{state_name.replace /\s+/g, "_"}-lawyers"
  clear_state_and_practice_area_validation_warning: () ->
    state_and_practice_area_validation_warning = ($ "#state_and_practice_area_validation_warning")
    state_and_practice_area_validation_warning.html('')
  isLawyersState: (state, lawyer_id) ->
    return false if state == ''
    unless @states.length
      $.ajax(
        url: '/lawyers/'+lawyer_id+'/states.json',
        async: false,
        dataType: 'json',
        success: (response) =>
          if response.states.length 
            $.each response.states, ( key, state ) -> 
              _this.states.push(state)
      )
    @inArray(state, @states)
  inArray: (value, array) ->
    result = false
    $.each array, ( key, obj ) -> 
      if value == obj.id.toString()
        result = true
    result    
  disable_submit_message_button: ->
    @continue_button().attr('disabled','disabled')
  enable_submit_message_button: ->
    @continue_button().removeAttr('disabled')

this.state_and_practice_area_validation = state_and_practice_area_validation

