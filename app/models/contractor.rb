# encoding: utf-8
require 'file_size_validator'
class Contractor < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :confirmable

  mount_uploader :logo, ContractorLogoUploader
  mount_uploader :doc_by_law, AttachmentsUploader
  mount_uploader :doc_ogrn, AttachmentsUploader
  mount_uploader :doc_inn, AttachmentsUploader
  mount_uploader :doc_egrul, AttachmentsUploader
  mount_uploader :doc_director, AttachmentsUploader
  mount_uploader :doc_proxy, AttachmentsUploader

  attr_accessible :email, :password, :password_confirmation, :remember_me, :title, :invitation_contrator_id, :invitation_tender_id, :profile_attributes, :pattern_of_ownership, :first_name, :last_name, :contact_person_email, :telephone_number, :logo, :logo_cache, :profile_type, :profile_id, :prof, :description, :country, :city, :street, :house, :office, :building, :director, :staff, :register_number, :site, :business_kind, :id_field, :main_markets, :authorized_capital, :authorized_capital_units, :foundation_year, :certificates_attributes, :statutory_documents_attributes, :contractor_documents_attributes, :myved_documents_attributes, :full_name, :invitation_cod, :reg_invitation_cod, :appointment, :postal_code, :language, :filials, :belongings, :pattern_of_ownership, :full_name, :shipment_types, :fact_address, :fax, :number, :legal_address, :agree, :email_lists_attributes, :direction, :shipments_number, :bank_title, :bic, :settlement_account, :correspondent_account, :proxy_person, :proxy_number, :transport, :foreign_bank_title, :foreign_bank_address, :foreign_bank_swift, :foreign_bank_account_number, :doc_by_law_cache, :doc_ogrn_cache, :doc_inn_cache, :doc_egrul_cache, :doc_director_cache, :doc_proxy_cache, :http_referer

  attr_accessor :invitation_contrator_id, :invitation_tender_id, :full_name, :prof, :reg_invitation_cod, :full_name, :agree

  serialize :shipment_types#, Array
  serialize :business_kind#, Array
  serialize :transport#, Array

  validates_presence_of :title, :first_name, :last_name, :telephone_number
  validates :logo, file_size: { maximum: 10.megabytes.to_i }

  validates_acceptance_of :agree, on: :create, allow_nil: false

  has_one :email_lists, class_name: 'Contractor::EmailLists'

  has_many :reviews
  has_many :inbox_payments
  has_many :outbox_payments

  has_many :notifications
  has_many :ved_requests
  has_many :project_contractors, dependent: :destroy

  has_many :inbox_messages, class_name: 'Message', foreign_key: 'receiver_id', dependent: :destroy
  has_many :outbox_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :destroy

  has_many :buyer_deals, class_name: 'Deal', foreign_key: 'buyer_id', dependent: :destroy
  has_many :supplier_deals, class_name: 'Deal', foreign_key: 'supplier_id', dependent: :nullify

  has_many :own_tenders, class_name: 'Tender', foreign_key: 'owner_id', dependent: :destroy

  has_many :sea_freights, dependent: :destroy
  has_many :sea_freight_responses, dependent: :destroy

  has_many :tender_responses, dependent: :destroy
  has_many :cost_calculations, dependent: :destroy
  has_many :supplier_products, dependent: :destroy

  has_many :certificates, dependent: :destroy
  has_many :statutory_documents, dependent: :destroy
  has_many :contractor_documents, dependent: :destroy
  has_many :myved_documents, dependent: :destroy

  has_many :tender_contractors, dependent: :destroy
  has_many :tenders, through: :tender_contractors do
    def invitations
      where('tender_contractors.confirmed' => nil)
    end
    def participations
      where('tender_contractors.confirmed' => true)
    end
  end
  belongs_to :profile, polymorphic: true

  scope :buyers, -> { where(profile_type: 'BuyerProfile') }
  scope :suppliers, -> { where(profile_type: 'SupplierProfile') }
  scope :ved_contractors, -> { where(profile_type: 'VedProfile') }

  accepts_nested_attributes_for :profile, :certificates, :statutory_documents, :contractor_documents, :myved_documents, allow_destroy: true

  accepts_nested_attributes_for :email_lists

  after_create :add_emails_lists, :add_to_contacts_by_invitation_cod, :add_ns_to_contacts, :add_to_tender_from_invitation, :add_project, :subscribe#, :add_authorization_execution# :add_contact_from_invitation, , б
  before_create :add_profile, :set_invitation_cod, :set_language
  before_validation :set_from_full_name
  before_destroy :remove_contacts

  state_machine initial: :new do
    state :new
    state :form
    state :execution
    state :successful
  end

  def own_deals
    dc_ids = deal_contractors.includes(:deal).where(owner: true).map(&:deal_id)
    Deal.where('id IN (?)', dc_ids)
  end

  def self.direction_options
    [
      ['Импорт в Россию', 'import'],
      ['Экспорт из России', 'export'],
      ['Импорт-экспорт', 'import_export']
    ]
  end

  def business_kind_options
    if supplier?
      options = [:producer, :trading_company]
    elsif buyer?
      options = [:producer, :wholesale_trade, :retail_trade, :logistics, :other]
    elsif ved_contractor?
      options = [:forwarder, :agent_ocean_line, :auto_owner, :customs_representative, :port_forwarder, :railway_operator, :warehouse_owner]
    else
      options = []
    end
    options.map { |option| [I18n.t("options.contractor.business_kind.#{option}"), option] }
  end

  def shipment_types_options
    if buyer?
      options = [:fcl, :lcl, :other]
    elsif ved_contractor?
      options = [:fcl, :lcl, :outsize_cargo, :bulked_cargo]
    else
      options = []
    end
    options.map { |option| [I18n.t("options.contractor.shipment_types.#{option}"), option] }
  end

  def self.transport_options
    options = [:sea, :railway, :auto, :avia]
    options.map { |option| [I18n.t("options.contractor.transport.#{option}"), option] }
  end

  def self.language_options
    [
      ['Русский', 'ru'],
      ['English', 'en']
    ]
  end

  def context_receivers(obj)
    if obj.owner?(self)
      ids = obj.contractor_ids
      ids << Contractor.ns.id
      Contractor.find(ids)
    else
      obj.owner
    end
  end

  def tender_invitations
    tenders_ids = tender_contractors.where(confirmed: nil).map(&:tender_id)
    Tender.where('id IN (?)', tenders_ids).current.approved_by_ns.order('created_at DESC')
  end

  def contact_person
    "#{first_name} #{last_name}"
  end

  def deals
    if buyer?
      buyer_deals
    elsif supplier?
      supplier_deals
    end
  end

  def tender_participations
    tenders_ids = tender_contractors.where(confirmed: true).map(&:tender_id)
    Tender.where('id IN (?)', tenders_ids).current.approved_by_ns.order('created_at DESC')
  end

  def current_tenders_for_admin
    if supplier?
      tenders.participations
    else
      own_tenders
    end
  end

  def self.currency_options
    ['$', '&euro;', 'руб']
  end

  def contacts_pairs
    contractors = Contact.where('contractor_id = ? OR contractor_contact_id = ?', id, id).collect{|c| 
      c.contractor_id == id ? [c.contractor_contact_id, c.id] : [c.contractor_id, c.id]}
  end

  def contact_contractors
    contractors_ids = Contact.where('contractor_id = ? OR contractor_contact_id = ?', id, id).collect{|c| c.contractor_id == id ? c.contractor_contact_id : c.contractor_id}
    Contractor.where('id IN (?)', contractors_ids)
  end

  def contact_suppliers
    contact_contractors.where(profile_type: 'SupplierProfile')
  end

  def self.ns
    find_by_email('admin@myved.com')
  end

  def self.china
    find_by_email('china@myved.com')
  end

  def ns?
    self == Contractor.ns
  end

  def china?
    self == Contractor.china
  end

  def friends
    contractors_ids = Contact.approved.where("contractor_id = ? OR contractor_contact_id = ?", id, id).collect{|c| 
      c.contractor_id == id ? c.contractor_contact_id : c.contractor_id}
    Contractor.where('id IN (?)', contractors_ids)
  end

  def opposite_profile
    if buyer?
      'supplier'
    elsif supplier?
      'buyer'
    else
      'ved_contractor'
    end
  end

  def profile_short_title
    if buyer?
      'buyer'
    elsif supplier?
      'supplier'
    else
      'ved_contractor'
    end
  end

  def buyer?
    profile_type == 'BuyerProfile'
  end

  def supplier?
    profile_type == 'SupplierProfile'
  end

  def ved_contractor?
    profile_type == 'VedProfile'
  end

  def in_contacts?(current_contractor)
    friends.map(&:id).include?(current_contractor.id)
  end

  def profile_title
    case profile_type
    when 'SupplierProfile'
      SupplierProfile.model_name.human
    when 'BuyerProfile'
      BuyerProfile.model_name.human
    when 'VedProfile'
      VedProfile.model_name.human
    else
      ''
    end
  end

  def address
    "#{house}#{'/' if building.presence}#{building}#{', ' + street if street.presence}#{', ' + city if city.presence}#{' ,' + Country.all.detect{|c| c[1] == country}[0] if Country.all.detect{|c| c[1] == country}.presence}#{', ' + postal_code.to_s if postal_code.presence}"
  end

  def self.country_options
    Country.all.sort
  end

  def owner?(current_contractor)
    self == current_contractor
  end

  def subject
    "Внесение изменений в профиль: #{title}"
  end

  def signer
    proxy_person.presence || director
  end

  def signer_document
    proxy_person.present? ? "доверенности #{proxy_number}" : 'устава'
  end

  def signer_appointment
    proxy_person.present? ? "доверенность #{proxy_number}" : 'ген.директор'
  end

  def russian?
    country == 'RU'
  end

  private

  def add_project
    project = Contractor::Authorization.find(id).project_contractors.create(contractor_id: id)
    project.to_current
    project.update_attributes(projectable_type: 'Contractor::Authorization')
  end

  def add_to_contacts_by_invitation_cod
    if reg_invitation_cod.presence && Contractor.find_by_invitation_cod(reg_invitation_cod).presence
      Contact.create(contractor_id: id, contractor_contact_id: Contractor.find_by_invitation_cod(reg_invitation_cod).id)
    end
  end

  def add_ns_to_contacts
    Contact.create(contractor_id: id, contractor_contact_id: Contractor.ns.id)
  end

  def add_contact_from_invitation
    # опасное место!
    if invitation_contrator_id
      Contact.create(contractor_id: id, contractor_contact_id:invitation_contrator_id)
    end
  end

  def add_to_tender_from_invitation
    if invitation_tender_id.presence && reg_invitation_cod.presence && Tender.find_by_id(invitation_tender_id).try(:owner_id) == Contractor.find_by_invitation_cod(reg_invitation_cod).try(:id)
      TenderContractor.create(contractor_id: id, tender_id: invitation_tender_id)
    end
  end

  def set_invitation_cod
    number = rand(999999).to_s.center(6, rand(9).to_s)
    if Contractor.find_by_invitation_cod(number).presence
      set_invitation_cod
    else
      self.invitation_cod = number
    end
  end

  def set_language
    if prof == 'supplier'
      self.language = 'en'
    else
      self.language = 'ru'
    end
  end

  def add_profile
    if prof == 'supplier'
      self.profile = SupplierProfile.create
    elsif prof == 'ved_contractor'
      self.profile = VedProfile.create
    else
      self.profile = BuyerProfile.create
    end
  end

  def remove_contacts
    Contact.where('contractor_id = ? OR contractor_contact_id = ?', id, id).destroy_all
  end

  def set_from_full_name 
    if full_name.presence
      self.last_name = full_name.split(" ").first
      self.first_name = full_name.split(" ").last
    end
  end

  def add_authorization_execution
    create_authorization_execution unless ved_contractor?
  end

  def add_emails_lists
    self.create_email_lists
  end

  def subscribe
    unless Rails.env.development?
      gb = Gibbon::API.new('4f4088d8d6c985015d525273794d9293-us8', { timeout: 5 })
      begin
        gb.lists.subscribe({ id: '1a734893fb', email: { email: email }, merge_vars: { :FNAME => 'First Name', :LNAME => 'Last Name' }, double_optin: false })
      rescue Gibbon::MailChimpError => e
        'Подписка на рассылку не удалась. Вы уже подписаны'
      end
    end
  end
end
