//= require default.js
//= require redactor
//= require redactor_config
//= require select2
//= require select2_locale_ru
//= require best_in_place
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
//= require file-validator

//= require form

//= require_self

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
  $(".multiselect").select2(
    width: '100%'
    placeholder: 'выберите компании'
    allowClear: true
  )
$ ->
  $(".best_in_place").best_in_place()

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

  $( ".datepicker" ).datepicker()