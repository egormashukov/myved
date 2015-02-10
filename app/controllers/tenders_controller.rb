# encoding: utf-8

class TendersController < ApplicationController

  before_filter :authenticate_contractor!
  before_filter :check_owner, :except => [:show, :new, :create, :index, :archive, :report]
  before_filter :check_show, :only => :show
  before_filter :check_report, :only => :report
  before_filter :check_edit, :only => :edit

  def complete
    @tender.save_with_winner(params[:tender_response])
    #@tender.deal.transactions.find(params[:transaction_id]).update_attributes(completed: true)

    # email to all contractors in tender
    redirect_to @tender, notice: 'победитель выбран'
  end

  def reject_all
    @tender.reject_all
    #@tender.deal.transactions.find(params[:transaction_id]).update_attributes(completed: true)
    redirect_to @tender, notice: 'тендер не состоялся'
  end

  def archive
    if current_contractor.buyer?
      @my_tenders = current_contractor.own_tenders.archive.order('created_at DESC')
    elsif current_contractor.supplier?
      @tender_invitations = current_contractor.tenders.invitations.archive
      @tender_participations = current_contractor.tenders.participations.archive
    end
  end

  def index
    if current_contractor.buyer?
      @my_tenders = current_contractor.own_tenders.active.order('created_at DESC')
      @waiting_tenders = current_contractor.own_tenders.waiting_for_approving.order('created_at DESC')
    elsif current_contractor.supplier?
      @tender_invitations = current_contractor.tenders.invitations.for_contractor
      @tender_participations = current_contractor.tenders.participations.for_contractor
    end
  end

  def show
    @tender = @tender.decorate
    @tender_responses = @tender.tender_responses.sent.approved.includes(:contractor, :product_responses => [:product_request, :supplier_product => [:properties, :advantages]])
  end

  def edit
    
  end


  def update
    @tender = Tender.find(params[:id])
    #respond_to удалять нельзя, json ответ нужен для best_in_place
    respond_to do |format|
      if !@tender.completed? && @tender.update_attributes(params[:tender])
        #обновляем отложенный таск на 3 дня вперед
        @tender.update_prolongation_delayed_tasks
        format.html { redirect_to(@tender, :notice => 'Тендер обновлен') }
        format.json { respond_with_bip(@tender) }
      else
        flash[:notice] = "#{t(:update_after_completion) if @tender.completed?}"
        format.html { render "edit"}
        format.json { respond_with_bip(@tender) }
      end
    end
  end

  def report
    @tender = @tender.decorate
  end
private

  def get_messages
    @messages = Message.for_current_contractor(current_contractor.id).ordered.grouped_and_sorted_by_contractor(current_contractor)
    @receivers = current_contractor.context_receivers(@tender)
  end

  def check_owner
    @tender = Tender.find(params[:id])
    unless @tender.owner?(current_contractor) || current_contractor.ns?
      redirect_to deals_path, notice: 'вы не имеете доступа к этой информации'
    end
  end

  def check_report
    @tender = Tender.includes(:deal => :buyer, :product_requests => :properties).find(params[:id]).decorate
    @tender_response = @tender.tender_responses.winner
    if !@tender.successful? || (!@tender_response.owner?(current_contractor) && !@tender.owner?(current_contractor))
      unless current_contractor.ns?
        redirect_to deals_path, notice: 'вы не имеете доступа к этой информации'
      end
    end
  end

  def check_show
    @tender = Tender.includes(:deal => :buyer, :product_requests => :properties).find(params[:id]).decorate
    if !@tender.visible_for?(current_contractor) && !current_contractor.ns? && !current_contractor.china?
      redirect_to deals_path, notice: 'вы не имеете доступа к этой информации'
    end
  end

  def check_edit
    @tender = Tender.includes(:deal => :buyer, :product_requests => :properties).find(params[:id]).decorate
    if !(@tender.owner?(current_contractor) && !@tender.approved?) && !current_contractor.ns?
      redirect_to deals_path, notice: 'вы не можете редактировать торги'
    end
  end
  
end
