jQuery ->
  ($ "input#offering_fee").numeric()

  ($ "li.offering a.edit").bind "click", (event) ->
    event.preventDefault()

    # Revert previuos changes
    ($ "li.offering a.edit").parents("li").removeClass("selected").find(".controls").show()

    li = ($ this).parents("li")
    controls = ($ this).parent("div.controls")

    # Select editing item
    li.addClass("selected")

    # Hide control elements
    controls.hide()
    
    $.ajax(
      url: "/offerings/#{li.data('id')}/edit"
      success: (data) -> ($ "div#new_offering").html(data)
    )

    # Highlight new form
    ($ "div#new_offering").effect("highlight", {}, 1000)


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