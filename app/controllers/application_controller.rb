class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :find_admin_contractor
  before_filter :set_notifications
  before_filter :set_locale
  before_filter :basic_authentication
  before_filter :set_http_refer

  layout :layout_by_resource
  # rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def from_abroad?
    I18n.locale != :ru
  end

  def set_http_refer
    session[:http_referer] ||= request.referer
  end

  private

  def render_404
    redirect_to '/404'
  end

  def set_notifications
    return '' unless contractor_signed_in?
    @notifications = current_contractor.notifications.not_read.by_created.to_a
  end

  def set_locale
    #very big!!
    logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
    session[:locale] ||= params[:locale]
    if contractor_signed_in? && current_contractor.buyer?
      I18n.locale = :ru
    else
      if params[:locale].presence
        I18n.locale = params[:locale]
        session[:locale] = params[:locale]
      elsif session[:locale].presence
        I18n.locale = session[:locale]
      else
        I18n.locale = extract_locale_from_accept_language_header
      end
    end
    logger.debug "* Locale set to '#{I18n.locale}'"
  end

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first if request.env['HTTP_ACCEPT_LANGUAGE'].presence
  end

  def after_sign_up_path_for(resource)
    edit_contractor_registration_path
  end

  def layout_by_resource
    if devise_controller? && resource_name == :user
      'login'
    elsif !contractor_signed_in? && !devise_controller? && params[:controller] != 'help_items'
      'landing'
    else
      'application'
    end
  end

  def find_admin_contractor
    @admin_contractor = Contractor.ns
    @contractor = current_contractor
  end

  def basic_authentication
    if Rails.env == 'pre_production'
      authenticate_or_request_with_http_basic do |username, password|
        username == 'nscor' && password == '4inat0wn'
      end
    end
  end
end
