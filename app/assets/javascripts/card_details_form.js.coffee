jQuery ->
  cardDetailsForm.initialize()

cardDetailsForm =
  initialize: (container) ->
    @ensureCardDetails()

  ensureCardDetails: ->
    ($ "[data-card-details-form]").on "submit", (event) =>
      event.preventDefault()
      @processCard()
      false

  processCard: ->
    card =
      number: ($ "#card_number").val()
      cvc: ($ "#card_code").val()
      expMonth: ($ "#card_month").val()
      expYear: ($ "#card_year").val()

    Stripe.createToken(card, cardDetailsForm.handleStripeResponse)

  handleStripeResponse: (status, response) ->
    if status == 200
      ($ "input#stripe_card_token").val(response.id)
      ($ "[data-card-details-form]")[0].submit()
    else
      ($ "#stripe_error").text(response.error.message)
