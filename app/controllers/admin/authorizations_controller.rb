#coding: utf-8
class Admin::AuthorizationsController < Admin::ApplicationController

  def index
    @authorizations = Contractor::Authorization.sent.includes(:myved_documents)
  end

  def authorize
    @contractor = Contractor::Authorization.find(params[:id])
    @contractor.authorize
   
    @contractor.save
    redirect_to :back
  end
end
