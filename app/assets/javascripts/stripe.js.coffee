# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
  subscription.setupForm()
  client_payment.setupForm()


client_payment =
  setupForm: ->
    $('#new_callpayment').submit ->
      $('input[type=submit]').attr('disabled', true)
      if $('#card_number').length
        client_payment.processCard()
        false
      else
        true

  processCard: ->
    card =
      number: $('#card_number').val()
      cvc: $('#card_cvc').val()
      expMonth: $('#card_month').val()
      expYear: $('#card_year').val()
    Stripe.createToken(card, client_payment.handleStripeResponse)
  
  handleStripeResponse: (status, response) ->
    if status == 200
      $('#client_stripe_card_token').val(response.id)
      $('#new_callpayment')[0].submit()
    else
      $('#stripe_error').text(response.error.message)
      $('input[type=submit]').attr('disabled', false)



subscription =
  setupForm: ->
    $('#new_subscription').submit ->
      $('input[type=submit]').attr('disabled', true)
      if $('#card_number').length
        subscription.processCard()
        false
      else
        true

    $('#apply_coupon_button').click ->    
      token = ($ "[name='csrf-token']").attr "content"
      coupon = $('input#coupon')
      stripe_plan_amount = $('input#stripe_plan_amount').val()
      _this = this
      $.ajax(
        url: $(this).attr 'href'
        type: 'POST'
        data:
          coupon: coupon.val(),
          authenticity_token: token
        beforeSend: ->
          $(_this).text "Checking..."
        complete: ->
          $(_this).text "Apply"
        success: (response) ->
          if response.result
            coupon.removeClass 'invalid'
            coupon.addClass 'valid'
            $('span#subscription_price').text('$' + (stripe_plan_amount - response.coupon.percent_off*0.01) + '/month for the first one month, $'+stripe_plan_amount+' thereafter period.')
          else
            coupon.removeClass 'valid'
            coupon.addClass 'invalid'
      )
      false

  
  processCard: ->
    card =
      number: $('#card_number').val()
      cvc: $('#card_cvc').val()
      expMonth: $('#card_month').val()
      expYear: $('#card_year').val()
    Stripe.createToken(card, subscription.handleStripeResponse)
  
  handleStripeResponse: (status, response) ->
    if status == 200
      $('#stripe_card_token').val(response.id)
      $('#new_subscription')[0].submit()
    else
      $('#stripe_error').text(response.error.message)
      $('input[type=submit]').attr('disabled', false)
