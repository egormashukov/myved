# encoding: utf-8

class Contractor::AuthorizationsController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :set_authorization

  include Wicked::Wizard
  steps :general_info, :legacy_info, :documents

  def index
    @page = HelpItem.where(title: "description_#{current_contractor.profile_type.underscore}", category: 'Contractor::Authorization').first
  end

  def show
    @step = step
    @steps = steps.size
    render_wizard
  end

  def edit

  end

  def update
    params[:contractor_authorization][:step] = step.to_s
    if step == steps.last
      params[:contractor_authorization][:step] = 'active'
    end
    if @authorization.authorized == true
      params[:contractor_authorization].select! { |p| ['email', 'password', 'password_confirmation', 'current_password', 'first_name', 'last_name', 'telephone_number', 'appointment', 'email_lists_attributes'].include?(p) }
    end
    if @authorization.update_attributes(params[:contractor_authorization])
      if step == steps.last
        @authorization.to_execution
        redirect_to contractor_authorization_execution_path(@authorization.authorization_execution, autorun: true)
      else
        @authorization.to_form
        render_wizard @authorization
      end
    else
      render_wizard @authorization
    end
  end

  private

  def finish_wizard_path
    contractor_authorization_execution_path(@authorization.authorization_execution)
  end

  def set_authorization
    @authorization = Contractor::Authorization.find(current_contractor.id).decorate
  end
end
