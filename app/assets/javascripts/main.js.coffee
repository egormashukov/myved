$ ->
  # $('#mycalculator').fingrdCalc()

$ ->
  $('body').on 'keypress', '.js-enter-autosubmit', (e) ->
    if e.which == 13
      e.preventDefault()
      $(@).closest('form').submit()

$ ->
  $('.js-autosate').change ->
    $(@).closest('form').submit()

$ ->
  $('textarea.autosize').autosize()

$ ->
  $('.js-submit-hidable').on 'submit', ->
    $(@).find('input:submit').prop('disabled', true)

$ ->
  $.datepicker.regional['ru'] = {
    closeText: 'Закрыть'
    prevText: '&#x3c;Пред'
    nextText: 'След&#x3e;'
    currentText: 'Сегодня'
    monthNames: ['Январь','Февраль','Март','Апрель','Май','Июнь'
    'Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь']
    monthNamesShort: ['Янв','Фев','Мар','Апр','Май','Июн'
    'Июл','Авг','Сен','Окт','Ноя','Дек']
    dayNames: ['воскресенье','понедельник','вторник','среда','четверг','пятница','суббота']
    dayNamesShort: ['вск','пнд','втр','срд','чтв','птн','сбт']
    dayNamesMin: ['Вс','Пн','Вт','Ср','Чт','Пт','Сб']
    weekHeader: 'Не'
    dateFormat: 'yy-mm-dd'
    firstDay: 1
    isRTL: false
    showMonthAfterYear: false
    yearSuffix: ''
  }
  $.datepicker.setDefaults($.datepicker.regional['ru'])


  $('.datepicker').each ->
    minDate = $(@).data('min-date') || null
    maxDate = $(@).data('max-date') || null
    $(@).datepicker(
      minDate: minDate
      maxDate: maxDate
    )

$ ->
  $(".run_privacy").find(".help_item_icon").trigger('click')
  $(".run_info").find(".help_item_icon").trigger('click')

  $(".best_in_place").best_in_place()

  $('body').on "click", ".start_tour" , (e) ->
    e.preventDefault()
    startTour()

  if $("#notice").text() == "Ваш ответ отправлен"
    startTour()

  if $("#start_tour_trigger").length > 0
    startTour()

  $(".js-autotriggered .help_item_icon").first().trigger("click")

  $("body").on 'click', ".close_help_frame_with_tour", (e) ->
    e.preventDefault()
    $(".close_help_frame").trigger("click")
    startTour()

$ ->
  i = 0
  $(".indexed").each ->
    i += 1
    $(@).append(i)

$ ->
  $("div.password_changing").hide()
$ ->
  $('body').on 'click', ".toggle_link", (e) ->
    e.preventDefault()
    if $(@).data('hide-text') == $(@).text()
      $(@).text($(@).data('show-text'))
    else
      $(@).text($(@).data('hide-text'))
    toggledEl = $(@).data('toggled-element')
    $(".#{toggledEl}").not($(@)).toggle()

$ ->
  $('#accordion').accordion(
    header: "> .bordered > .fieldset_title"
    heightStyle: "content"
    #active: ($('#accordion .fieldset_title').length - 1)
  )
$ ->
  $("body").on 'click', '.print_link', (e) ->
    e.preventDefault()
    window.print()
$ ->
  $("a.fancybox").fancybox(
    'transitionIn'  : 'elastic'
    'transitionOut' : 'fade'
    'speedIn'   : 600
    'hideOnOverlayClick':true
    'speedOut'    : 100
    'centerOnScroll':true
    'cyclic': true
    'overlayShow' : true
    'overlayColor': '#000'
    'overlayOpacity': '0.8'
    'easingIn':'easeOutQuart'
    'easingOut':'easeOutQuart'
    'changeSpeed':200
    'changeFade': 0
    'showNavArrows': true
  )
  
$ ->
  $(".select_nice_goods").select2(
    placeholder: "Подберите код для товара"
    minimumInputLength: 1
    width: "100%"
    ajax:
      url: "/nice_goods.json"
      data: (term, page) ->
        q: term
        page_limit: 25
      results: (data, page) ->
        results: data.results
  )

# $ ->
#   $("body").on "click", "a.messages", (e) ->
#     e.preventDefault()
#     toggleMessagePanel()
#     toggleMessageLink()

#   $("body").on "click", ".messages_overlay", (e) ->
#     e.preventDefault()
#     toggleMessagePanel()
#     toggleMessageLink()

startTour = ->
  link = $(".start_tour").first()
  introJs().setOptions(
    "nextLabel": link.data("next")
    'prevLabel': link.data("prev")
    'skipLabel': link.data("skip")
    'doneLabel': link.data("done")
  ).start()

toggleMessagePanel = ->
  $panel = $(".messages_panel").toggleClass("exp")
  if $panel.hasClass('exp')
    right = 0
  else
    right = -501
  $panel.animate(
    right: right
  )


toggleMessageLink = ->
  $link = $(".messages_panel_link").toggleClass("exp")
  if $link.hasClass('exp')
    link_right = 426
    $("body").append("<div class='messages_overlay' />")
  else
    link_right = -75
    $(".messages_overlay").remove()

  $link.animate(
    right: link_right
  )

$ ->
  $("body").on 'change', 'input:file', ->
    $(@).parents('.field').first().after("<div class='field small_text'>#{$('.file_field_as_button').data('notice')}</div>")
    $(@).closest('.file_field_as_button').fadeOut()

$ ->
  addLink = ->
    body_element = document.getElementsByTagName('body')[0]
    selection = window.getSelection();
    pagelink = "<br /><br /> Источник: <a href=\'#{document.location.href}\'>#{document.location.href}</a><br />© myved.com"
    copytext = selection + pagelink
    newdiv = document.createElement('div')
    newdiv.style.position = "absolute"
    newdiv.style.left = "-99999px"
    body_element.appendChild(newdiv)
    newdiv.innerHTML = copytext
    selection.selectAllChildren(newdiv)
    window.setTimeout(
      -> body_element.removeChild(newdiv);
      0
    )
  document.oncopy = addLink