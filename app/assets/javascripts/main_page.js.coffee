$ ->
  hideOrShowToUpButton()
  $(window).scroll ->
    hideOrShowToUpButton()

  $('body').on 'click', '.find_suppliers_link', (e) ->
    e.preventDefault()
    $('html, body').animate
      scrollTop: $('.buy_button_frame').offset().top
      1000
  $('body').on 'click', '.get_best_offer_link', (e) ->
    e.preventDefault()
    $('html, body').animate
      scrollTop: $('.best_offer_frame').offset().top
      1000
  $('body').on 'click', '.ved_request_link', (e) ->
    e.preventDefault()
    $('html, body').animate
      scrollTop: $('.ved_request_frame').offset().top
      1000
  $('body').on 'click', '.to_top', (e) ->
    e.preventDefault()
    $('html, body').animate
      scrollTop: 0
      1000

hideOrShowToUpButton = ->
  if $('body').scrollTop() > 100
    $('.to_top').fadeIn()
  else
    $('.to_top').fadeOut()