# encoding: utf-8

class Admin::TendersController < Admin::ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :china?, except: :index

  def toggle_approved
    @tender = Tender.find(params[:id])
    @tender.approve
    @tender.save_with_callbacks
    notice = 'тендер одобрен'
    redirect_to :back, notice: notice
  end

  def index
    @tenders = Tender.without_new.order(sort_column + " " + sort_direction).order('created_at DESC')
    if current_user.china?
      @tenders = @tenders.where(need_help: true)
    end
    @tenders = @tenders.decorate
  end

  def new
    @tender = Tender.new
    render 'edit'
  end

  def edit
    @tender = Tender.find(params[:id])
    @messages = @tender.messages.order("created_at DESC")
    @tender_responses = @tender.tender_responses
  end

  def create
    @tender = Tender.new(params[:tender])
    if @tender.save
      redirect_to admin_tenders_path, :notice => "#{Tender.model_name.human} #{t 'flash.notice.was_added'}"
    else
      render 'edit'
    end
  end

  def update
    @tender = Tender.find(params[:id])
    if @tender.update_attributes(params[:tender])
      redirect_to admin_tenders_path, :notice => "#{Tender.model_name.human} #{t 'flash.notice.was_updated'}"
    else
      render 'edit'
    end
  end

  def destroy
    @tender = Tender.find(params[:id])
    @tender.destroy
    redirect_to admin_tenders_path, :alert => "#{Tender.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private

  def china?
    if current_user.china?
      redirect_to [:admin, :ns_helps]
    end
  end

  def sort_column
    Tender.column_names.include?(params[:sort]) ? params[:sort] : 'state'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
