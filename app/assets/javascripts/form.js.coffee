$ ->
  $('form').on 'click', '.remove_fields', (e) ->
    $(@).prev('input[type=hidden]').val('1')
    $(@).closest('fieldset').hide()
    $(@).closest('fieldset').parent('.fieldset_title').hide()
    $(@).closest(".removeable").hide()
    if $(@).parents('#accordion').length > 0 && $(@).parents('fieldset').length < 2
      $(@).closest('.bordered').hide()
    e.preventDefault()
    if $(@).parents('fieldset').length < 2
      $('#accordion').accordion('destroy').accordion(
        header: "> .bordered > .fieldset_title"
        heightStyle: "content"
        active: 'false'
      )
    addListNumerical()

  # $('form').on 'click', '.remove_fields_from_table', (e) ->
  #   $(@).prev('input[type=hidden]').val('1')
  #   $(@).closest('.fieldset').hide()
  #   e.preventDefault()
  #   resetAccordion() if $(@).parents('fieldset').length < 2

  $('form').on 'click', '.add_fields', (e) ->
    time = new Date().getTime()
    regexp = new RegExp($(@).data("id"), 'g')
    $(@).before($(@).data('fields').replace(regexp, time))
    e.preventDefault()
    resetAccordion()
    addListNumerical()
    reinitSelect2()

  # $('form').on 'click', '.add_fields_to_table', (e) ->
  #   time = new Date().getTime()
  #   regexp = new RegExp($(@).data("id"), 'g')
  #   $(@).parents('tr').first().before($(@).data('fields').replace(regexp, time))
  #   e.preventDefault()
  #   resetAccordion() if $(@).parents('fieldset').length < 2

  $('input[type=file]').fileValidator(
    onInvalid:    (type, file) -> 
      $(this).val(null)
      alert "размер файла должен быть меньше 10Mb"
    maxSize: '10m'
  )
  $('form').on 'click', '.add_fields_to', (e) ->
    time = new Date().getTime()
    regexp = new RegExp($(@).data("id"), 'g')
    $(@).siblings('.insertion_point').first().append($(@).data('fields').replace(regexp, time))
    e.preventDefault()
    resetAccordion() if $(@).parents('#accordion').length < 1
    addListNumerical()
    reinitSelect2()

$ ->
  $('.file_field_as_button input[type="file"]').each ->
    filePth($(@))
  $('body').on 'change', '.file_field_as_button input[type="file"]', (e) ->
    filePth($(@))
  addListNumerical()

filePth = (pth) ->
  val = pth.val().split('\\').pop()
  pth.parents('fieldset').first().find('.file_location').first().text(val) if val != ''

reinitSelect2 = ->
  $('.selectto').select2("destroy")
  $('.selectto').select2(
    width: '100%'
    allowClear: true
  )
  $(".select_nice_goods").each ->
    if $(@).data("select2") is undefined
      $(@).select2(
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



resetAccordion = ->
  $('#accordion').accordion('destroy').accordion(
    header: "> .bordered > .fieldset_title"
    heightStyle: "content"
    active: ($('#accordion .fieldset_title').length - 1)
  )

addListNumerical = ->
  i = 1
  $('.numerical_item').each ->
    $(@).text("№#{i}")
    i += 1
