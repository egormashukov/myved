class TenderResponse < ActiveRecord::Base
  attr_accessible :body, :contractor_id, :tender_id, :delivery_time, :terms_of_payment, :conditions_of_supply, :service, :delivery_time_unit, :product_responses_attributes, :attachments_attributes, :updated_count, :ready

  attr_readonly :contractor_id, :tender

  has_many :supplier_products, through: :product_responses
  has_many :product_responses, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy

  belongs_to :tender, inverse_of: :tender_responses
  belongs_to :contractor

  scope :sent, -> {where{state != 'new'}}
  scope :approved, -> {where('state = ? OR state = ? OR state = ?', 'active', 'winner', 'loser')}
  scope :non_approved, -> {where(state: 'waiting')}

  validates_presence_of :conditions_of_supply, :terms_of_payment, :delivery_time, :contractor_id
  validate :contractor_must_be_supplier, on: :create 
  validate :must_have_product_responses, on: :create

  validate :updated_only_three_time, on: :update

  validates_acceptance_of :ready, if: lambda {|t| t.try(:ready)}

  accepts_nested_attributes_for :product_responses, :product_responses, :attachments, allow_destroy: true

  state_machine initial: :new do
    state :new do
      def current_state
        I18n.t('statuses.tender_response.new')
      end
    end
    state :waiting do
      def current_state
        I18n.t('statuses.tender_response.waiting')
      end
    end
    state :active do
      def current_state
        I18n.t('statuses.tender_response.active')
      end
    end
    state :winner do
      def current_state
        I18n.t('statuses.tender_response.winner')
      end
    end
    state :loser do
      def current_state
        I18n.t('statuses.tender_response.loser')
      end
    end
    state :active, :loser, :winner do
      def approved?
        true
      end
    end

    state all - [:active, :loser, :winner] do
      def approved?
        false
      end
    end

    event :send_to_ns do
      transition new: :waiting
    end
    event :approve do
      transition waiting: :active
    end
    event :win do
      transition active: :winner
    end
    event :lose do
      transition active: :loser
    end

  end

  def approved_string
    current_state
  end

  def owner?(current_contractor)
    contractor == current_contractor
  end

  def visible_for?(current_contractor)
    owner?(current_contractor) || (approved? && tender.owner?(current_contractor))
  end

  def summ_cost
    pairs = product_responses.collect{|pr| [pr.price, pr.product_request.quantity]}
    cost = 0
    pairs.each do |p|
      cost += p[0]*p[1]
    end
    cost
  end

  def self.best
    self.scoped.sort{|x, y| x.summ_cost <=> y.summ_cost }.first
  end

  def self.winner
    where(state: 'winner').first
  end

  def best?
    best_response = tender.best_response(tender.tender_responses.approved.reject{|tr| tr.id == id })
    if best_response.presence
      best_response > summ_cost
    else
      false
    end
  end

  def delivery_time_view
    delivery_time.round(0)
  end

  def save_with_callbacks
    approve
    Contact.create(contractor_id: contractor.id, contractor_contact_id: tender.owner.id)

    tender.notifications.build(contractor_id: contractor.id).set_body(:response_approved)
    save
    send_best_messages
  end

 def self.first_by_contractor(contractor)
   scoped.select{|tr| tr.contractor_id == contractor.id}.first
 end

  def save_with_product_requests
    self.product_responses.each do |product_response|
      if product_response.edit_product?
        sp_attrs = accessible_attrs_hash(product_response.supplier_product)
        supplier = SupplierProduct.find(product_response.supplier_product_attr)
        product_response.supplier_product.properties.each do |property|
          supplier.properties.find_or_create_by_title(property.title).update_attributes(body: property.body)
        end
        product_response.supplier_product = supplier
        # место неоднозначное. Не очень ясно, как быть с валидациями
        supplier.update_attributes(sp_attrs)
      end
    end
    save
    #send_best_messages
  end

  def update_with_product_requests
    product_responses.each do |product_response|
      if product_response.edit_product? && product_response.supplier_product_id.to_s != product_response.supplier_product_attr.to_s
        sp_attrs = accessible_attrs_hash(product_response.supplier_product)
        supplier = SupplierProduct.find(product_response.supplier_product_attr)
        supplier.assign_attributes(sp_attrs)
        supplier.properties << product_response.supplier_product.properties
        product_response.supplier_product = supplier
        
      elsif !product_response.edit_product?
        sp_attrs = accessible_attrs_hash(product_response.supplier_product)
        supplier = SupplierProduct.new(sp_attrs)
        product_response.supplier_product.properties.each do |property|
          supplier.properties.build(title: property.title, body: property.body)
        end
        product_response.supplier_product.advantages.each do |advantage|
          supplier.advantages.build(title: advantage.title, body: advantage.body)
        end
        product_response.supplier_product = supplier

        # место неоднозначное. Не очень ясно, как быть с валидациями
      end
    end
    save
    send_best_messages
    true
  end

  # def update_with_product_requests
  #   self.product_responses.each do |product_response|
  #     if product_response.edit_product?
  #       sp_attrs = accessible_attrs_hash(product_response.supplier_product)
  #       supplier = SupplierProduct.find(product_response.supplier_product_attr)
  #       product_response.supplier_product.properties.each do |property|
  #         prop = supplier.properties.find_or_initialize_by_title(property.title)
  #         prop.assign_attributes(body: property.body)
  #         supplier.properties << prop
  #       end
  #       product_response.supplier_product = supplier
  #       # место неоднозначное. Не очень ясно, как быть с валидациями
  #       supplier.assign_attributes(sp_attrs)
  #       supplier.save

  #     elsif !product_response.edit_product?
  #       sp_attrs = accessible_attrs_hash(product_response.supplier_product)

  #       supplier = SupplierProduct.new(sp_attrs)
  #       product_response.supplier_product.properties.each do |property|
  #         supplier.properties.build(title: property.title, body: property.body)
  #       end
  #       product_response.supplier_product.advantages.each do |advantage|
  #         supplier.advantages.build(title: advantage.title, body: advantage.body)
  #       end
  #       product_response.supplier_product = supplier
  #       # место неоднозначное. Не очень ясно, как быть с валидациями
  #     end
  #   end
  #   send_best_messages
  #   save
  # end

  def accessible_attrs_hash(obj)
    attrs = obj.attributes
    classname = eval(obj.class.name)
    protected_attrs = classname.new.attributes.keys - classname.accessible_attributes.to_a
    protected_attrs.each do |pa|
      attrs.delete(pa)
    end
    attrs   
  end

  def send_best_messages
    if active? && best? 
      tender.notifications.build(contractor_id: tender.owner.id).set_body(:new_best_response, self)

      # посылаем сообщения другим участникам
      tender.tender_contractors.each do |tc|
        tender.notifications.build(contractor_id: tc.contractor_id).set_body(:new_best_response, self)
      end
    end  
  end

  def increment_updated_count
    self.updated_count += 1 if (active? && valid?)
    true
  end

  def updated_left
    4 - updated_count
  end

  private

  def contractor_must_be_supplier
    if !contractor.supplier?
      errors.add :contractor_id, 'must be supplier'
    end
  end

  def must_have_product_responses
    if product_responses.size != tender.product_requests.size
      errors.add :product_responses, 'amount must be equal to product requests quantity'
    end    
  end

  def updated_only_three_time
    if updated_count > 3
      errors[:base] << I18n.t("activerecord.errors.tender_response.three_times")
    end
  end
end
