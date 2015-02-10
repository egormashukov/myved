class ReviewsController < ApplicationController
  before_filter :authenticate_contractor!

  def create
    @review = Review.new(params[:review])
    @review.contractor = current_contractor
    @review.save
  end

end
