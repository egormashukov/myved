# encoding: utf-8

class SeaFreights::BuildController < ApplicationController
  include Wicked::Wizard
  before_filter :authenticate_contractor!
  before_filter :check_owner, :except => :building

  steps :general_info, :final

  def show
    @step = step
    @steps = steps.size
    render_wizard
  end

  def update
    params[:sea_freight][:status] = step.to_s
    if step == steps.last
      params[:sea_freight][:status] = 'active'
    end
    @sea_freight.assign_attributes(params[:sea_freight])
    if @sea_freight.save 
      if step == steps.last
        @sea_freight.to_myved
        @sea_freight.notifications.build(contractor_id: current_contractor.id).set_body(:created)
        @sea_freight.notifications.build(contractor_id: Contractor.ns.id).set_body(:created_to_myved)
        redirect_to sea_freight_path(params[:sea_freight_id], autorun: true), notice: I18n.t('notice.sea_freight.new')
      else
        @sea_freight.to_form
        render_wizard @sea_freight
      end
    else
      render_wizard @sea_freight
    end
  end

  def building
    @deal = current_contractor.deals.create
    @deal.to_sea_freight
    @sea_freight = @deal.create_sea_freight(contractor_id: current_contractor.id)
    redirect_to wizard_path(steps.first, sea_freight_id: @sea_freight.id, window: params[:window], transport: params[:transport])
  end

  private

  def check_owner
    @sea_freight = SeaFreight.find(params[:sea_freight_id]).decorate
    unless @sea_freight.owner?(current_contractor) || current_contractor.ns?
      redirect_to @sea_freight, notice: 'вы не имеете доступа к этой информации'
    end
  end

  def check_new
    if @sea_freight.active?
      redirect_to @sea_freight
    end
  end
end