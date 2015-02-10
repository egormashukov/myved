# encoding: utf-8

class Contractor::VedMessagesController < ApplicationController
  before_filter :load_messagable
  def create
    @ved_message = @ved_request.ved_messages.build(params[:ved_message])
    @ved_message.contractor = current_contractor
    if @ved_message.save
      redirect_to @ved_request.decorate.project_pth, notice: 'Ожидайте ответа'
    else
      render "#{@ved_request.base_class.pluralize.underscore}/show", id: @ved_request.id
    end
  end

  def load_messagable
    klass = [CostCalculationExecution, CertificationRequest, SeaFreightExecutionSeaAuto, SeaFreightExecutionRailway, SeaFreightExecutionSeaRailway, SeaFreightExecutionSea, Contractor::AuthorizationExecution].detect{|c| params["#{c.name.underscore.split('/').last}_id"]}
    if klass
      @ved_request = klass.find(params["#{klass.name.underscore.split('/').last}_id"]).decorate
    else
      @ved_request = nil
    end
  end
end
