# encoding: utf-8

class Tenders::BuildController < ApplicationController
  include Wicked::Wizard
  
  before_filter :authenticate_contractor!
  before_filter :check_owner, except: :building
  before_filter :check_new, except: :building

  steps :general_info, :conditions_of_supply, :add_product_requests, :final

  def show
    @step = step
    @steps = steps.size
    render_wizard
  end

  def update
    params[:tender][:status] = step.to_s
    if step == steps.last
      params[:tender][:status] = 'active'
    end
    @tender.assign_attributes(params[:tender])
    if @tender.save
      if step == steps.last
        @tender.send_to_ns
        redirect_to tender_path(params[:tender_id]), notice: I18n.t('notice.tender.sent_to_myved')
      else
        @tender.to_form
        render_wizard @tender
      end
    else
      render_wizard @tender
    end
  end

  def building
    @deal = current_contractor.deals.create
    @deal.to_tender
    @tender = @deal.create_tender(owner_id: current_contractor.id)
    redirect_to wizard_path(steps.first, :tender_id => @tender.id)
  end

private

  def check_owner
    @tender = Tender.find(params[:tender_id])
    unless @tender.owner?(current_contractor) || current_contractor.ns?
      redirect_to @tender, notice: 'вы не имеете доступа к этой информации'
    end
  end

  def check_new
    if @tender.active?
      redirect_to @tender
    end
  end
end