spin_opts = {
  lines: 13,
  length: 7,
  width: 4,
  radius: 11,
  rotate: 0,
  color: '#222',
  speed: 1,
  trail: 60,
  shadow: false,
  hwaccel: false,
  className: 'spinner',
  zIndex: 9999,
  top: 'auto',
  left: 'auto'
}

jQuery ->
  ($ "input#offering_fee").numeric()

  ($ "li.offering .cancel > a").on "click", (event) ->
    event.preventDefault()

    offering = ($ this).parents("li")
    controls = ($ this).parent("div.cancel").siblings("div.controls")
    cancelEditing = ($ this).parent("div.cancel")

    offering.removeClass("selected")
    cancelEditing.hide()
    controls.show()


    ($ "div#new_offering_outer").css("opacity", 0.6).spin(spin_opts)
    $.ajax(
      url: "/users/#{offering.data('user-id')}/offerings/new"
      success: (data) ->
        ($ "div#new_offering_outer").html(data)
        ($ "div#new_offering_outer").css("opacity", 1).spin(false)
      complete: ->
        ($ "div#new_offering_outer > h3").effect("highlight", {}, 1000)
    )

  ($ "li.offering a.edit").on "click", (event) ->
    event.preventDefault()

    # Revert previuos changes
    ($ "li.offering a.edit").parents("li").removeClass("selected").find(".controls").show()
    ($ "li.offering a.edit").parents("li").removeClass("selected").find(".controls").next().hide()

    li = ($ this).parents("li")
    controls = ($ this).parent("div.controls")
    cancelEditing = ($ this).parent("div.controls").next()

    # Select editing item
    li.addClass("selected")

    # Hide control elements
    controls.hide()
    cancelEditing.show()

    ($ "div#new_offering_outer").css("opacity", 0.6).spin(spin_opts)
    $.ajax(
      url: "/offerings/#{li.data('id')}/edit"
      success: (data) -> 
        ($ "div#new_offering_outer").html(data)
        ($ "div#new_offering_outer").css("opacity", 1).spin(false)
      complete: ->
        ($ "div#new_offering_outer > h3").effect("highlight", {}, 1000)
    )

class Offering
  constructor : (id)->
    @id = id
    @div = $("#offering_#{id}")
    @lawyer_id = @div.data "lawyer-id"
    @form = new AppointmentForm(@lawyer_id)
    @slug = @div.data "lawyer-slug"

    this.add_event_listeners()

  add_event_listeners : ()->
    @div.find("a.appt-select").click (e)=>
      # if logged in, show form
      if $("body.logged-in").length > 0
        @form.select_time(
          $(e.target).attr("data-time")
        )
        @form.show()
      # otherwise redirect
      else
        path = encodeURI(
          # document.location.pathname + document.location.search
          "/attorneys/#{@lawyer_id}/#{@slug}"
        )
        document.location = "/clients/new?appointment_with=#{@lawyer_id}&return_path=#{path}"
      # always return false
      return false

@Offering = Offering
