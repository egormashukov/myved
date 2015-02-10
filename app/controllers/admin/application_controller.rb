#coding: utf-8
class Admin::ApplicationController < ActionController::Base 
  protect_from_forgery
  before_filter :authenticate_user!
  before_filter :find_admin_contractor
  before_filter :set_locale

  layout 'admin'

  def find_admin_contractor
    @admin_contractor = Contractor.ns
  end
  def set_locale
    I18n.locale = :ru
  end
end