# encoding: utf-8

class MessagesController < ApplicationController
  before_filter :load_messagable
  
  def index
    @contractor = Contractor.find(params[:contractor_id])
    @messages = @messagable.messages.dialogue(current_contractor, @contractor).order(:created_at).includes(:sender)
    render layout: false
    @messages.to_current_contractor(current_contractor).each do |m|
      m.update_attributes(read: true)
    end
  end

  def new
    @contractor = current_contractor
    @receivers = @contractor.contact_contractors
  end

  def create
    @message = @messagable.messages.build(params[:message])
    @message.sender = current_contractor
    unless @message.save
      redirect_to :back, notice: 'Сообщение невозможно отправить'
    end
  end

  def get_dialogue
    klass = [Tender].detect{|c| c.name.underscore == params[:messagable_type]}
    @contractor = Contractor.find(params[:contractor])
    if klass
      @messagable = klass.find(params[:messagable_id])
      @messages = @messagable.messages.dialogue(current_contractor, @contractor).ordered.limit(10)
    else
      @messagable = ''
      @messages = Message.dialogue(current_contractor, @contractor).ordered.limit(10)
    end
    render layout: false
    @messages.to_current_contractor(current_contractor).where(read: false).each { |m| m.update_attributes(read: true) }
  end

  def get_more_messages
    klass = [Tender].detect{|c| c.name.underscore == params[:messagable_type]}
    @contractor = Contractor.find(params[:contractor])
    if klass
      @messagable = klass.find(params[:messagable_id])
      @messages = @messagable.messages.dialogue(current_contractor, @contractor).ordered.to_a.from(params[:last_position].to_i).first(10)
    else
      @messagable = '' 
      @messages = Message.dialogue(current_contractor, @contractor).ordered.to_a.from(params[:last_position].to_i).first(10)
    end
    render layout: false
  end

  private

  def load_messagable
    klass = [Tender, SeaFreight, CostCalculation, SeaFreightExecutionSeaAuto, SeaFreightExecutionRailway, SeaFreightExecutionSeaRailway, SeaFreightExecutionSea, Contractor::Authorization].detect{|c| params["#{c.name.underscore}_id"] || params["#{c.name.underscore.split('/').last}_id"]}
    if klass
      @messagable = klass.where(id: [params["#{klass.name.underscore}_id"], params["#{klass.name.underscore.split('/').last}_id"]]).first
    end
  end
end
