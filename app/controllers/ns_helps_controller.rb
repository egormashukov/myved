# encoding: utf-8

class NsHelpsController < ApplicationController
  before_filter :authenticate_contractor!

  def create
    @ns_help = NsHelp.new(params[:ns_help])
    @ns_help.contractor = current_contractor
    if @ns_help.save
      if @ns_help.deal
        @transaction = @ns_help.deal.transactions.where(transaction_type: 'find_suppliers').first.update_attributes(completed: true)
        redirect_to [:get_best_prices, @ns_help.deal], notice: 'Запрос отправлен'
      else 
        redirect_to :back, notice: 'Запрос отправлен'
      end

    else
      redirect_to :back, notice: 'Запрос не был отправлен'
    end

  end
end
