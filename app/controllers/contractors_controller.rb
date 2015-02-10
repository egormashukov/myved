class ContractorsController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :check_contacts, only: :show

  def show
    @authorization = Contractor::Authorization.find(@contractor.id).decorate
  end

  def home
    set_projects
    set_messages
    @help_items = HelpItem.visible_by_position.includes(:help_slides).decorate
  end

  def messages
    @contractor = current_contractor
    @messages = Message.for_current_contractor(current_contractor.id).ordered.grouped_and_sorted_by_contractor(current_contractor)
    @receivers = @contractor.contact_contractors
  end

  def edit
    
  end

  def find_suppliers

  end

  private

  def set_messages
    @not_read_messages = Message.to_current_contractor(current_contractor).not_read.to_a
  end

  def set_projects
    projects = current_contractor.project_contractors.includes(:projectable).visible.order('created_at DESC')
    @quotation_projects = projects.quotations.decorate
    @execution_projects = projects.executions.decorate
  end

  def check_contacts
    @contractor = Contractor.find(params[:id])
    unless @contractor == current_contractor || @contractor.in_contacts?(current_contractor) || current_contractor.ns? || current_contractor.china? || current_contractor.ved_contractor?  || @contractor.ved_contractor?
      redirect_to root_path, notice: I18n.t("notice.contractors.havent_access")
    end
  end
end
