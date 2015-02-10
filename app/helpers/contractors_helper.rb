module ContractorsHelper
  def contractor_logo(contractor, classes='')
    image_tag(contractor.logo_url(:icon), alt: contractor.title, class: classes)
  end

  def profile_visible_for_contractor?(contractor)
    sf_response = SeaFreightResponse.where(id: params[:sea_freight_response_id]).try(:first)
    current_contractor.id == contractor.id ||
    current_contractor.ns? ||
    (sf_response.try(:best?) && sf_response.sea_freight.contractor_id == current_contractor.id) ||
    (sf_response.try(:contractor_id) == current_contractor.id && sf_response.try(:best?))
  end
end
