# encoding: utf-8

#coding: utf-8
class Admin::NsHelpsController < Admin::ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :get_ns_help, :only => [:send_invitation, :toggle_processed, :edit, :update, :destroy]

  def send_invitation
    if params[:ns_help][:email].presence
      MessageMailer.send_invite_from_myved(params[:ns_help][:email], @ns_help.tender).deliver
      @ns_help.emails = "#{@ns_help.emails} #{params[:ns_help][:email]}----#{Time.now.strftime('%d.%m.%y')}"
      @ns_help.save
    end
    redirect_to :back, notice: "сообщение отправлено"
  end

  def distribution
    if params[:emails].presence
      DistributionMailer.send_invitations(params[:emails]).deliver
    end
    redirect_to :back
  end

  def toggle_processed
    @ns_help.toggle(:processed)
    @ns_help.save
    redirect_to :back
  end

  def index
    @ns_helps = NsHelp.order(sort_column + " " + sort_direction).order('created_at DESC')
  end
  
  def new
    @ns_help = NsHelp.new
    render 'edit'
  end
  
  def edit
    contacts_pairs = @ns_help.contractor.contacts_pairs
    contactors_ids = contacts_pairs.collect{|c| c[0]}
    @contactor_friends = Contractor.order('title').find(contactors_ids)
    @contractors = @ns_help.tender.contractors
    @tender_responses = @ns_help.tender.tender_responses
  end
  
  def create
    @ns_help = NsHelp.new(params[:ns_help])
    if @ns_help.save
      redirect_to admin_ns_helps_path, :notice => "#{NsHelp.model_name.human} #{t 'flash.notice.was_added'}"
    else
      render 'edit'
    end
  end

  def update
    if @ns_help.update_attributes(params[:ns_help])
      redirect_to admin_ns_helps_path, :notice => "#{NsHelp.model_name.human} #{t 'flash.notice.was_updated'}"
    else
      render 'edit'
    end
  end
  
  def destroy
    @ns_help.destroy
    redirect_to admin_ns_helps_path, :alert => "#{NsHelp.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private
  
  def get_ns_help
    @ns_help = NsHelp.find(params[:id])
  end

  def sort_column
    NsHelp.column_names.include?(params[:sort]) ? params[:sort] : 'processed'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end  
end