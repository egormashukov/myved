class RegistrationsController < Devise::RegistrationsController

  # def after_sign_up_path_for(resource)
  #   edit_contractor_registration_path
  # end

  def after_sign_up_path_for(resource)
    page_path(Page.find_by_slug("contractor_confirmation"))
  end

  def after_inactive_sign_up_path_for(resource)
    page_path(Page.find_by_slug("contractor_confirmation"))
  end

  def after_update_path_for(resource)
    edit_contractor_registration_path
  end

  def update
    @contractor = Contractor.find(current_contractor.id)
    if @contractor.authorized?
      params[:contractor].select! { |p| ['email', 'password', 'password_confirmation', 'current_password', 'first_name', 'last_name', 'telephone_number', 'appointment', 'email_lists_attributes'].include?(p) }
    end
    successfully_updated = if needs_password?(@contractor, params)
      @contractor.update_with_password(params[:contractor])
    else
      # remove the virtual current_password attribute update_without_password
      # doesn't know how to ignore it
      params[:contractor].delete(:current_password)
      @contractor.update_without_password(params[:contractor])
    end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the contractor bypassing validation in case his password changed
      sign_in @contractor, :bypass => true
      redirect_to after_update_path_for(@contractor)
    else
      render 'edit'
    end
  end

  private
  # check if we need password to update contractor data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(contractor, params)
    contractor.email != params[:contractor][:email] ||
      params[:contractor][:password].present?
  end
end
