#coding: utf-8
class Admin::CertificationRequestsController < Admin::ApplicationController
  helper_method :sort_column, :sort_direction
  def pay
    @certification_request = CertificationRequest.find(params[:id])
    @certification_request.pay
  end

  def index
    @certification_requests = CertificationRequest.order(sort_column + " " + sort_direction)
  end
  
  def new
    @certification_request = CertificationRequest.new
    render 'edit'
  end
  
  def edit
    @certification_request = CertificationRequest.find(params[:id])
  end
  
  def create
    @certification_request = CertificationRequest.new(params[:certification_request])
    if @certification_request.save
      redirect_to admin_certification_requests_path, :notice => "#{CertificationRequest.model_name.human} #{t 'flash.notice.was_added'}"
    else
      render 'edit'
    end
  end

  def update
    @certification_request = CertificationRequest.find(params[:id])
    if @certification_request.update_attributes(params[:certification_request])
      redirect_to admin_certification_requests_path, :notice => "#{CertificationRequest.model_name.human} #{t 'flash.notice.was_updated'}"
    else
      render 'edit'
    end
  end
  
  def destroy
    @certification_request = CertificationRequest.find(params[:id])
    @certification_request.destroy
    redirect_to admin_certification_requests_path, :alert => "#{CertificationRequest.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private

  def sort_column
    CertificationRequest.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end  
end