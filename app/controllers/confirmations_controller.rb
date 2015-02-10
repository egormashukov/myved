class ConfirmationsController < Devise::ConfirmationsController
  private

  def after_confirmation_path_for(resource_name, resource)
    if signed_in?(resource_name)
      root_path(hello: true)
    else
      new_session_path(resource_name)
    end
  end
end