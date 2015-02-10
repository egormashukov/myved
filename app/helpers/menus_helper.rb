module MenusHelper
  def profile_link
    link_to t(:profile), current_contractor, class: 'profile'
  end

  def blog_link
    link_to t(:blog), 'http://blog.myved.com/', class: 'blog', target: "_blank"
  end

  def contacts_link
    html ||=  link_to(t(:contacts), contractor_contacts_path(current_contractor), class: 'contacts')
    if Contact.not_approved.where(contractor_contact_id: current_contractor.id).presence
      html << content_tag(:div, Contact.not_approved.where(contractor_contact_id: current_contractor.id).size, class: 'not_read_messages')
    end
    raw html
  end

  def projects_link
    link_to t(:projects), deals_path, class: 'projects'
  end

  def finances_link
    link_to t(:finances), finances_path, class: 'finances'
  end

  def signout_link
    link_to t(:sign_out), destroy_contractor_session_path, method: :delete, class: 'signout'
  end

  def buy_product_pth
    [:find_suppliers, :contractors]
  end

  def ved_request_pth
    cost_calculations_building_path(window: true)
  end

  def ved_tender_pth
    sea_freights_building_path(window: true)
  end

  def participate_tender_pth
    deals_path
  end

  def solve_import_problems_pth
    '#'
  end

  def notifications_link(notifies)
    html ||= link_to(bell_iconed_txt, notifications_path)
    html << content_tag(:div, notifies.try(:count), class: 'not_read_messages') if notifies.any?
    raw html
  end

  def bell_iconed_txt
    raw (t(:notifications_link) + content_tag(:i, '', class: 'fa fa-bell'))
  end
end
