jQuery ->
  interact_with_lawyer.initialize()

interact_with_lawyer =
  initialize: ->
    @interact_with_lawyer_tabs()

  interact_with_lawyer_tabs: ->
    ($ "form#phone_consultation_form").submit ->
      lawyers = interact_with_lawyer.get_lawyers(this)
      unless lawyers.length
        alert 'Sorry, no such lawyers are available right now.'
        return false
      unless interact_with_lawyer.is_logged_in(this)
        interact_with_lawyer.redirect_to_clients_new_path(lawyers[0], interact_with_lawyer.phone_number(this))
        return false
      interact_with_lawyer.start_call(interact_with_lawyer.phone_url(lawyers[0], interact_with_lawyer.phone_number(this)))   
      false  
  is_logged_in: (form) ->
    ($ form).find('#client_id').length > 0
  inactive: -> 
    tabs = ($ "#interact_with_lawyer_tabs .tab")
    interact_with_lawyer.tabs().removeClass('active')
  activate: (el) ->  
    ($ el).children('.tab').addClass('active')
  get_link_index: (el) ->   
    $(interact_with_lawyer.links()).index(el);
  contents: -> 
    ($ "#interact_with_lawyer_tabs").next('ul.interact_with_lawyer_ul').children('li')
  phone_number: (form) ->
    ($ form).find('#client_phone').val()  
  get_lawyers: (form) ->
    state_name = ($ form).find('#state_name').val()
    practice_area = ($ form).find('#practice_area').val()
    state_name = 'All-States' unless state_name.length
    practice_area = 'All' unless practice_area.length
    token = ($ "[name='csrf-token']").attr "content"
    url = '/lawyers/Legal-Advice/' +  state_name + '/' +  practice_area  + '.json'
    lawyers = []
    $.ajax(
        url: url,
        type: 'POST'
        async : false
        data: 
          authenticity_token: token
        dataType: "json"
        success: (response) ->
          if response.lawyers.length
            lawyers = response.lawyers
    )
    lawyers
  phone_url: (lawyer, number) ->  
    url = '/twilio/phonecall?id=' + lawyer.id
    url += "&number=#{number}" if number.length
    url
  start_call: (phone_url) ->
    window.location.href = phone_url 
  redirect_to_clients_new_path: (lawyer, number) ->
    path = encodeURI(interact_with_lawyer.phone_url(lawyer, number))
    document.location = "/clients/new?lawyer_path=#{lawyer.id}&client[phone]=#{number}&notice=true&return_path=#{path}"