# encoding: utf-8

class NotificationsController < ApplicationController
  before_filter :authenticate_contractor!

  def index
    set_scope
  end

  def show
    set_notification
    @notify_notifications = @notification.notifiable.notifications.where(contractor_id: current_contractor.id).where('id NOT IN (?)', @notification.id).includes(:notifiable).by_created.decorate
    @notification.update_attributes(read: true)
    @notification = @notification.decorate
  end

  private

  def set_scope
    @notifications = current_contractor.notifications.includes(:notifiable).by_created.decorate
  end

  def set_notification
    set_scope
    @notification = @notifications.find(params[:id])
  end

  def check_owner
    return '' if @notification.owner? current_contractor
    redirect_to deals_path, notice: I18n.t(:havent_access)
  end
end
