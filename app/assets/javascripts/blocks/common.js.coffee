$ ->
  $(".js-accordion-content").not(".js-open").hide()
  $("body").on "click", ".js-accordion-trigger", (e) ->
    e.preventDefault()
    $(@).closest(".js-accordion-wr").find(".js-accordion-content").stop().slideToggle()
    $(@).toggleClass("_exp")