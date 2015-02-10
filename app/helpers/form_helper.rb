module FormHelper

  def link_to_add_attachments(name, f, association, partial, category, classes = '')
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(partial, f: builder, category: category)
    end
    link_to(name, "#", class: "add_fields #{classes}", data: {id:id, fields: fields.gsub('\n', '')})
  end
  def 
    link_to_add_fields(name, f, association, partial, classes = '')
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(partial, f: builder)
    end
    link_to(name, "#", class: "add_fields #{classes}", data: {id:id, fields: fields.gsub('\n', '')})
  end

  def link_to_add_fields_to(name, f, association, partial, classes = '')
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(partial, f: builder)
    end
    link_to(name, "#", class: "add_fields_to #{classes}", data: {id:id, fields: fields.gsub('\n', '')})
  end

  def link_to_add_standart_property(name, f, association, partial, classes = '')
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(partial, f: builder, standart_title: name)
    end
    link_to(name, '#', class: "add_fields_to #{classes}", data: {id:id, fields: fields.gsub('\n', '')})
  end

  def link_to_add_fields_with_partial(name, f, association, partial)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(partial, f: builder)
    end
    link_to(name, '#', class: 'add_fields', data: {id:id, fields: fields.gsub('\n', '')})
  end

  def fields_for_nested_responses(f, association, product_request)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder, product_request: product_request)
    end 
    fields
  end

  def fields_for_nested_suppliers(f, association, product_request)
    new_object = f.object.build_supplier_product
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder, product_request: product_request)
    end 
    fields 
  end

  def fields_for_cost_calc_products(f, association, product_response)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder, product_response: product_response, product_request: product_response.product_request, tender_supplier_product: product_response.supplier_product)
    end 
    fields
  end

  def fields_for_nested_cost_calc_suppliers(f, association, product_response)
    new_object = f.object.build_supplier_product
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder, product_response: product_response, product_request: product_response.product_request, tender_supplier_product: product_response.supplier_product)
    end 
    fields 
  end

  def fields_for_nested_cost_calc_properties(f, association, property)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render('property_fields', f: builder, property: property)
    end 
    fields
  end

  def fields_for_nested_properties(f, association, product_property)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render('product_request_property_fields', f: builder, property: product_property)
    end 
    fields
  end

  def link_to_add_fields_to_response(name, f, association, product_requests)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder, product_requests: product_requests)
    end
    link_to(name, '#', class: 'add_fields', data: {id:id, fields: fields.gsub('\n', '')})
  end


  def attr_is_strong(f, form_tag, column, product_request)
    if eval("product_request.#{column}_strong?")
      eval("f.#{form_tag} :#{column}, readonly: true, value: product_request.#{column}, rows: 2")
    else
      eval("f.#{form_tag} :#{column}, rows: 2")
    end
  end

  def obligatory_field(product_request, column)
    if eval("product_request.#{column}_obligatory?")
      eval("product_request.#{column}")
    else
      eval("product_request.#{column}") + ' *'
    end
  end

  def attr_equal_check_box(column, tender)
    if eval("tender.#{column}.presence")
      check_box_tag column, '1', false, class: 'attrs_equal'
    end
  end

  def attr_products_equal_check_box(column, obj)

    if eval("obj.#{column}.presence")
      check_box_tag "#{obj.class.name.underscore}_#{column}_#{obj.id}", '1', false, class: 'attrs_products_equal'
    end
  end
end
