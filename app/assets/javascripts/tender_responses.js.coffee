$ ->
  setEqualAttrIfEqual()
  $('input:checkbox.attrs_equal').change ->
    checkboxId = $(@).attr('id')
    inputField = $("input#tender_response_#{checkboxId}")
    value = $("span##{checkboxId}").text()
    
    toggleTextInputs $(@), inputField, value
    toggleSelectInputs $(@), value

  $("input:checkbox.attrs_products_equal").change ->
    checkboxId = $(@).attr('id')
    inputField = $(".#{checkboxId} input")
    if inputField.length == 0 
      inputField = $("div.#{checkboxId} textarea")

    value = $("span.#{checkboxId}").text()
    toggleTextInputs $(@), inputField, value

  $(".tender_response_f").on "keyup", ":input", ->

    $(@).parents('.string').first().find('.attrs_products_equal, .attrs_equal').attr('checked', false)

setEqualAttrIfEqual = ->
  $('input:checkbox.attrs_equal').each ->
    checkboxId = $(@).attr('id')
    inputField = $("input#tender_response_#{checkboxId}")

    if $("span##{checkboxId}").text() == inputField.val()
      $(@).attr('checked', true)
      #inputField.attr('readonly', true)
    selectElement = $(@).parent("td").siblings('td').last().find('select').first()
    if  $("span##{checkboxId}").text() == selectElement.val()
      $(@).attr('checked', true)

  $("input:checkbox.attrs_products_equal").each ->
    checkboxId = $(@).attr('id')
    inputField = $(".#{checkboxId} input")
    if inputField.length == 0 
      inputField = $("div.#{checkboxId} textarea")
    if $("span.#{checkboxId}").text() == inputField.val()
      $(@).attr('checked', true)
      #inputField.attr('readonly', true)


toggleTextInputs = (attrEqual, inputField, value) ->
  if attrEqual.is(':checked')
    inputField.val(value)#.attr('readonly', 'true')
  else
    inputField.val('')#.removeAttr('readonly')

toggleSelectInputs = (attrEqual, value) ->
  selectElement = attrEqual.parent("td").siblings('td').last().find('select').first()
  if attrEqual.is(':checked')
    selectElement.val(value)
  else
    selectElement.val('')


#tender response parsing of supplier products

$ ->
  $(".new_product_checkbox").hide()

  # $('.select_supplier_product').each ->
  #   fieldset = $(@).parents("fieldset").first()
  #   if $(@).val() != ''
  #     addNewProductCheckbox(fieldset)

  $('body').on 'change', ".select_supplier_product", ->
    productId = $(@).val()
    objId = $(@).attr('id')
    fieldset = $("fieldset.#{objId}")
    unless $(@).val() == ''
      $.ajax
        url: "/supplier_products/#{productId}.json"
        type: 'GET'
        dataType: 'json'
        success: (product) ->
          fillForm(product, fieldset)
          addNewProductCheckbox(objId)
          
  fillForm = (product, fieldset) ->
    formIds = [getIdForCostCalculationForm(fieldset), getIdForForm(fieldset)]
    $.each( formIds, ( index, formId ) ->
      $.each( product, ( key, value ) ->
        $("##{formId}#{key}").val(value)
      )
    )
    linkToAddProperties = fieldset.find('.column2 .add_fields_to').first()
    fieldset.find('.column2 .form_properties fieldset').remove()
    $.each(product.properties, (key, value) ->
      linkToAddProperties.trigger("click")
      propertyFieldset = fieldset.find('.column2 .form_properties fieldset').last()
      propertyFieldset.find('input:text').first().val(value.title)
      propertyFieldset.find('input:text').last().val(value.body)
    )
    $.each(product.properties, (key, value) ->
      fieldset.find("span.property_title").each -> 
        if $(@).text() is value.title
          $(@).parents('tr').first().find(".property_body_in_fieldset").not('.obligatory').val(value.body)
    )

addNewProductCheckbox = (objId) ->
  $(".pnc_#{objId}").show().find(":checkbox")

getIdForForm = (fieldset) ->
  formInteger = fieldset.find(".first_title_in_fieldset").attr('id').replace(/[^0-9]/g, '')
  formId = "tender_response_product_responses_attributes_#{formInteger}_supplier_product_attributes_"
  formId

getIdForCostCalculationForm = (fieldset) ->
  formInteger = fieldset.find(".first_title_in_fieldset").attr('id').replace(/[^0-9]/g, '')
  formId = "cost_calculation_product_supplier_product_attributes_"
  formId
  
