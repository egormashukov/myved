class TenderContractorsController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :check_contractor

  def confirm
    @tender_contractor.update_attributes(confirmed: true)
    redirect_to @tender_contractor.tender, notice: I18n.t("notice.tender_contractor.confirm")
  end

  def decline
    @tender_contractor.update_attributes(confirmed: false)
    redirect_to :back, notice: I18n.t("notice.tender_contractor.decline")
  end

private

  def check_contractor
    @tender_contractor = TenderContractor.find(params[:id])
    unless @tender_contractor.contractor == current_contractor
      redirect_to :back, notice: I18n.t(:havent_access)
    end
  end

end
