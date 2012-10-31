# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  questions.initialize()

questions =
  initialize: ->
    @handleQuestionForm()
    @handleQuestionOptionsPage()
  
  new_question: ->
    ($ "#new_question")
  question_body: -> 
    ($ "#question_body")
  question_state: -> 
    ($ "#question_state")
  question_area: -> 
    ($ "#question_area")

  handleQuestionForm: ->
    _this = this;
    ($ document).on "mouseup", (e) ->
      question_body = _this.question_body().val()
      if _this.new_question().length
        if _this.new_question().has(e.target).length == 0
          if question_body.length == 0 || question_body == ""
            _this.question_state().hide('slow')
            _this.question_area().hide('slow')
            $wrapper = _this.new_question().parents("#autoselect_lawyer_wraper")
            if $wrapper.length == 0
              $wrapper = _this.new_question().parents("#autoselect_landing_wraper")
            if $wrapper.length > 0
              $wrapper.removeClass('expanded')
              
    @question_body().on "blur", (e) ->
      if _this.new_question().length
        question_body = _this.question_body().val()
        if question_body.length
          _this.question_body().val(question_body.strip_tags())
          
    @question_body().on "focus", (e) ->
      e.stopPropagation()
      _this.question_state().show('slow')
      _this.question_area().show('slow')
      $wrapper = ($ @).parents("#autoselect_lawyer_wraper")
      if $wrapper.length == 0
        $wrapper = ($ @).parents("#autoselect_landing_wraper")
      if $wrapper.length > 0
        $wrapper.addClass('expanded')

  question_options: -> 
    ($ ".question_options_wrapper input[type='radio']")
  question: -> 
    ($ ".question_options_wrapper #question")
  question_id: ->
    @question().attr('data-id')
  practice_area_name_for_url: ->
    practice_area_name = "All" 
    if @question().attr('data-practice_area').length
      practice_area_name = @question().attr('data-practice_area').replace /\s+/g, "-"
    practice_area_name
  state_name_for_url: ->
    state_name = 'All-States'
    if @question().attr('data-state_name').length
      state_name = "#{@question().attr('data-state_name').replace /\s+/g, "_"}-lawyers"
    state_name
  handleQuestionOptionsPage: ->
    _this = this
    @question_options().on "click", ->
      switch ($ this).val()
        when '1'
          _this.sendUserToTheStripePaymentPage()
        when '2'
          _this.sendUserToTheLawyersPage()
  sendUserToTheLawyersPage: ->
    @flash('Please choose one of these lawyers to talk to.')
    window.location.href = "/lawyers/Legal-Advice/#{@state_name_for_url()}/#{@practice_area_name_for_url()}"
  sendUserToTheStripePaymentPage: ->
    window.location.href = "/stripe/subscribe_question/#{@question_id()}"
    
  token: -> 
    ($ "[name='csrf-token']").attr "content"
  flash: (question, type = 'notice') ->
    $.ajax( url: "/flash/#{type}", type: 'POST', async: false, data: { message: question, token: @token() })

this.questions = questions

