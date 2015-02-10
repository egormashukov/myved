$ ->
  $(".multiselect").select2(
    width: '100%'
    placeholder: 'выберите компании'
    allowClear: true
  )
  $(".selectto").select2(
    width: '100%'
  )

$ ->
  expandBlockByClick '.toggle_properties'

$ ->
  $(".all_messages").hide()
  $(".show_all_messages").click (e) ->
    e.preventDefault()
    $(@).siblings(".all_messages").toggle()

$ ->
  $('.agreement_field').hide()
  $(".agreement_checkbox").change ->
    $('.agreement_field').show()

expandBlockByClick = (link) ->

  $('body').on "click", link, (e) ->
    e.preventDefault()
    $block = $(".#{$(@).attr('id')}")

    showText = $(@).data("show-text")
    hideText = $(@).data("hide-text")
    
    $block.toggle()
    toggleText($(@), showText, hideText)

  toggleText = (obj, showText, hideText)->
    if obj.text() == showText
      obj.text(hideText)
    else
      obj.text(showText)