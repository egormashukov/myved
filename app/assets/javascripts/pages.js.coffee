# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $(".home_page").on 'click', '.soon.with_help', (e) ->
    openHelpFrame $(@).find('i').data("help-item-id")
    return false

  $(".home_page .with_help").not('.soon').on 'click', 'i', (e) ->
    openHelpFrame $(@).data("help-item-id")
    return false

  $('body').on "click", '.other_help_slide', (e) ->
    pth = $(@).attr("href")
    $('.help_frame').fadeOut()
    $.ajax
      url: pth
      dataType : "html"
      type: "POST"
      success: (html) ->
        $('.help_frame').replaceWith(html)
        fixSize()
        $('.help_frame').fadeIn()
    return false

  $('body').on 'click', '.overlay', (e) ->
    closeHelpFrame()
  $("body").on 'click', '.close_help_frame', (e) ->
    closeHelpFrame()

$ ->
  $('body').on 'click', '.help_item_icon', (e) ->
    e.preventDefault()
    openHelpFrame($(@).data('help-item-id'))

closeHelpFrame = ->
  $('.overlay').remove()
  $(".help_frame").remove()

openHelpFrame = (help_item_id) ->
  $.ajax
    url: "/help_items/#{help_item_id}"
    dataType : "html"
    success: (html) ->
      addOverlay()
      $("body").append(html)
      fixSize()
      $('.help_frame').fadeIn()

addOverlay = ->
  $("body").append("<div class='overlay' />")

fixSize = ->
  hgth = 500
  wdth = 800
  windowHeight = $(window).height()
  windowWidth = $(window).width()
  $('.help_frame').height(hgth).width(wdth).css({top: Math.abs((windowHeight - hgth - 6*16)/2 ), left: Math.abs((windowWidth - wdth)/2)})
