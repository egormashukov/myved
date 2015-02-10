module RegistrationsHelper

  def sign_up_profile(profile_type)
    profile_type.presence ? profile_type : 'buyer'
  end

  def invite_link(contractor, tender = nil)
    # if tender.presence
    #   new_contractor_registration_url(invitation_tender_id: tender.id, profile: 'supplier')
    # else
    #   new_contractor_registration_url(invitation_contrator_id: contractor.id, profile: 'supplier')
    # end
    contractor.try(:invitation_cod)
  end
  
end
