class HelpItem < ActiveRecord::Base
  default_scope includes(:translations)
  attr_accessible :body, :category, :position, :soon, :title, :url, :visible, :post, :rating, :wanted, :translations_attributes, :show_help

  translates :title, :body

  CATEGORIES = %w(
    buy_product
    ved_request
    ved_tender
    sell_to_russia
    all_for_world_trade
  )
  has_many :help_slides
  validates_presence_of :title, :category
  scope :by_category, ->(category) { where(category: category) }

  accepts_nested_attributes_for :translations

  def column_help?
    CATEGORIES.exclude?(category)
  end

  def main_page?
    title == 'main_page' && category == 'page'
  end

  def self.categories
    CATEGORIES
  end

  def url_method
    post? ? :post : :get
  end

  def self.by_category_n_title(category, title)
    by_category(category).where(title: title.to_s).visible.first
  end

  def vote(current_contractor)
    return '' if voted?(current_contractor)
    self.rating += 1
    $redis.sadd("contractor_votes:#{current_contractor.id}", id)
    save
  end

  def voted?(current_contractor)
    return true unless current_contractor.presence
    $redis.sismember "contractor_votes:#{current_contractor.id}", id
  end
end
