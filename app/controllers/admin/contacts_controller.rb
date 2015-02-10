# encoding: utf-8

class Admin::ContactsController < Admin::ApplicationController

  def create
    @contact = Contact.new(params[:contact])
    @tender = Tender.find(params[:tender_id])
    @tender.tender_contractors.create(contractor_id: @contact.contractor_contact_id)

    unless @tender.waiting?
      @tender.messages.new(receiver_id: @contact.contractor_contact_id, sender_id: Contractor.ns.id).approve_tender_message_to_supplier(@tender)
    end

    if @contact.save
      redirect_to :back, :notice => "Контакт успешно добавлен"
    else
      redirect_to :back, :alert => "Контакт уже существует"
    end
  end
  
  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy
    redirect_to :back, :alert => "#{Contact.model_name.human} #{t 'flash.notice.was_deleted'}"
  end


end