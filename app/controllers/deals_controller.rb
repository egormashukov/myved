# encoding: utf-8

class DealsController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :check_owner, :except => [:index, :archive, :create, :new, :toggle_supplier_archive]

  def complete_deal
    @deal.success
    redirect_to :back, notice: I18n.t("notice.deal.complete_deal")
  end

  def remove_deal
    @deal.update_attributes(successful: false)
    redirect_to deals_path, notice: I18n.t("notice.deal.remove_deal")
  end

  def toggle_archive
    @deal = Deal.find(params[:id])
    @deal.toggle(:archive)
    @deal.save
    redirect_to :back
  end

  def toggle_supplier_archive
    @deal = Deal.find(params[:id])
    @deal.toggle(:supplier_archive)
    @deal.save
    redirect_to :back
  end

  def set_supplier
    @deal.update_attributes(supplier_id: params[:supplier_id])
    redirect_to :back, notice: 'поставщик выбран'
  end

  def index
    @projects = current_contractor.project_contractors.order('created_at DESC').decorate
  end

  def archive
    contractor_deals = current_contractor.buyer_deals
    
    if current_contractor.supplier?
      @deals = Deal.archived_for_supplier(current_contractor)
    else
      @deals = contractor_deals.archived
    end
  end

  def destroy
    @deal.destroy
    redirect_to :back
  end


private

  def check_owner
    @deal = Deal.find(params[:id])
    unless @deal.owner == current_contractor
      redirect_to deals_path, notice: I18n.t(:havent_access)
    end
  end

end
