# encoding: utf-8

class Contractor::AuthorizationExecutionsController < ApplicationController
  before_filter :check_contractor, except: [:new, :create]

  def update
    @ved_request.update_attributes(params[:authorization])
    redirect_to :back
  end

  def next_step
    @ved_request.to_next_step
    redirect_to :back, notice: 'вы перешли на следующий шаг'
  end

  def show
    @ved_message = VedMessage.new
  end

  private

  def check_admin
    @ved_request = Contractor::AuthorizationExecution.find(params[:id]).decorate
    unless current_contractor.ns?
      redirect_to root_path, notice: I18n.t(:havent_access)
    end
  end

  def check_contractor
    @ved_request = Contractor::AuthorizationExecution.find(params[:id]).decorate
    unless @ved_request.contractor == current_contractor || current_contractor.ns?
      redirect_to root_path, notice: I18n.t(:havent_access)
    end
  end
end