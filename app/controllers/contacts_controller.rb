class ContactsController < ApplicationController
  before_filter :authenticate_contractor!

  def approve
    @contact = Contact.find(params[:id])
    if @contact.contractor_contact_id == current_contractor.id && @contact.update_attributes(approved: true)
      redirect_to :back, notice: I18n.t("notice.contacts.approve")
    else
      redirect_to :back, notice: I18n.t("notice.contacts.impossible")
    end
  end
  def send_invitations
    begin
      MessageMailer.send_invitations(params[:emails], current_contractor).deliver
      notice = I18n.t("notice.contacts.send_invitations")
    rescue
      notice = I18n.t("notice.contacts.impossible")
    end  
    redirect_to [current_contractor, :contacts], notice: notice
  end

  def index
    contacts_pairs = current_contractor.contacts_pairs
    contactors_ids = contacts_pairs.collect{|c| c[0]}
    contacts_ids = contacts_pairs.collect{|c| c[1]}
    
    @contractors = Contractor.find(contactors_ids)
    @contacts = Contact.find(contacts_ids)
  end

  def show
    @contact = Contact.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @contact }
    end
  end

  def create
    @contact = Contact.new(params[:contact])
    @contact.contractor_id = current_contractor.id
    added = Contractor.find_by_invitation_cod(params[:contact][:invitation_cod])
    if added.presence
      @contact.contractor_contact_id = added.id
      if @contact.save    
        redirect_to :back, notice: I18n.t("notice.contacts.create")
      else
        redirect_to :back, notice: I18n.t("notice.contacts.impossible")
      end
    else
      redirect_to :back, notice: I18n.t("notice.contacts.not_found")
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    if @contact.is_current_user?(current_contractor.id)
      @contact.destroy
      redirect_to :back, notice: I18n.t("notice.contacts.destroy")
    else
      redirect_to :back, notice: I18n.t("notice.contacts.impossible")
    end
  end
end
