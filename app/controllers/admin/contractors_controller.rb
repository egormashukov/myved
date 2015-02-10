#coding: utf-8
class Admin::ContractorsController < Admin::ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :china?, except: :index

  def index
    @contractors = Contractor.order('authorized DESC').order('created_at DESC').includes(:myved_documents)
    if current_user.china?
      @contractors = @contractors.suppliers
    end
  end

  def new
    @contractor = Contractor.new
    render 'edit'
  end

  def edit
    @contractor = Contractor.find(params[:id])
  end

  def create
    @contractor = Contractor.new(params[:contractor])
    if @contractor.save
      redirect_to admin_contractors_path, :notice => "#{Contractor.model_name.human} #{t 'flash.notice.was_added'}"
    else
      render 'edit'
    end
  end

  def update
    @contractor = Contractor.find(params[:id])
    if @contractor.update_attributes(params[:contractor])
      redirect_to admin_contractors_path, :notice => "#{Contractor.model_name.human} #{t 'flash.notice.was_updated'}"
    else
      render 'edit'
    end
  end

  def destroy
    @contractor = Contractor.find(params[:id])
    @contractor.destroy
    redirect_to admin_contractors_path, :alert => "#{Contractor.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private

  def china?
    if current_user.china?
      redirect_to [:admin, :ns_helps]
    end
  end

  def sort_column
    Contractor.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
