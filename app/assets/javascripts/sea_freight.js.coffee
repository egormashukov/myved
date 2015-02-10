$ ->
  setSeaFields()
  $(".js-sf-transport").change ->
    setSeaFields()

$ ->
  setDisableField $('.js-cb-disable-field').first()
  $('.js-cb-disable-field').on 'change', ->
    setDisableField $(@)

$ ->
  $('.js-currency-vat-choose').each ->
    setCurrencyVat $(@)
  $('.js-currency-vat-choose .js-currency').change ->
    setCurrencyVat $(@).closest('.js-currency-vat-choose')
    setSum()

$ -> 
  setSeaResponseFields $('.js-sea-resp-selector').first()
  $('.js-sea-resp-selector').change ->
    setSeaResponseFields $(@)

$ ->
  setSum()
  $('.js-autosum').keyup ->
    setSum()

setSum = ->
  sum = 0
  $('.js-autosum').each ->
    val = $(@).closest('.field').find('.js-currency').first()
    currency = val.val() || val.select2('val')
    factor = setFactor(currency)
    factoredSum = parseFloat($(@).val() || 0) / factor
    sum += factoredSum || 0
  $('.js-autosum-result').text("$#{sum.toFixed(2)}")

setFactor = (currency) ->
  usdRub = $('.js-currency-usd-rub').text()
  eurUsd = $('.js-currency-eur-usd').text()
  if currency == 'rub'
    parseFloat(usdRub)
  else if currency == 'eur'
    1/parseFloat(eurUsd)
  else if currency == 'usd'
    1
  else
    1

setSeaResponseFields = (el) ->
  types = seaResponseTypes el.select2('val')
  $fields = $('.js-sea-resp')

  $fields.filter(types).show()
  $fields.not(types).each ->
    $(@).hide()
    $(@).find('input, textarea').val('')


seaResponseTypes = (val) ->
  if val == 'sea_auto'
    '._sea, ._auto'
  else if val == 'sea'
    '._sea'
  else if val == 'sea_railway'
    '._sea, ._railway'
  else if val == 'railway'
    '._railway'

setCurrencyVat = (el) ->
  if el.find('.js-currency').first().select2('val') == 'rub'
    el.find('.js-vat').show()
  else
    el.find('.js-vat').hide()
    el.find('.js-vat').select2('val', 0)

setDisableField = (field) ->
  if field.is(':checked')
    $('#sea_freight_destination_port').attr('readonly', true).val('любой')
  else
    $('#sea_freight_destination_port').removeAttr('readonly').val(
      -> if $(@).val() == 'любой' then '' else  $(@).val()
    )

setSeaFields = ->
  if $(".js-sf-transport").select2("val") == "sea"
    $(".js-hidable-sea").hide()

    $(".js-cb-disable-field").attr('disabled', true)
    $('.js-cb-disable-field').parent().hide()
    $('#sea_freight_destination_port').removeAttr('readonly')
  else
    $(".js-hidable-sea").show()
    $('.js-cb-disable-field').removeAttr('disabled')
    $('.js-cb-disable-field').parent().show()

