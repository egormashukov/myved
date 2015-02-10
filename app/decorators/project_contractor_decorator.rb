# encoding: utf-8
class ProjectContractorDecorator < MainDecorator
  delegate_all

  def messages_count(messages)
    begin
      messages_count = messages.select{|m| m.messagable_type == projectable_type && m.messagable_id == projectable_id}.count
      return '' if messages_count == 0
      link_to project_pth, class: 'project_icon_link' do
        raw(content_tag(:i, '', class: 'fa fa-envelope') + content_tag(:i, messages_count, class: 'project_notread_messages'))
      end
    rescue
      ''
    end
  end

  def notifications_count(notifications)
    begin
      notifications_projects = notifications.select{ |n| n.notifiable_type == projectable_type && n.notifiable_id == projectable_id }
      notifications_count = notifications_projects.count
      return '' if notifications_count == 0
      link_to notifications_projects.first, class: 'project_icon_link' do
        raw(content_tag(:i, '', class: 'fa fa-bell') + content_tag(:i, notifications_count, class: 'project_notread_messages'))
      end
    rescue
      ''
    end
  end

  def client
    return '' unless current_contractor.ved_contractor?
    content_tag :td do
      link_to projectable.contractor.try(:title), projectable.contractor
    end
  end

  def project_link
    projectable.decorate.project_link
  end

  def project_pth
    projectable.decorate.project_pth
  end

  def project_title
    projectable.decorate.try(:project_title).presence
  end

  def project_status
    projectable.decorate.project_status
  end

  def action_link
    destroy_project || decide_link || archive_project_link
  end

  def decide_link
    return nil unless projectable.decorate.wait_decision?
    link_to t('actions.decide'), projectable.decorate.project_pth
  end

  def archive_project_link
    return nil unless projectable.completed?
    link_to archive_title, self, method: :put
  end

  def archive_title
    archived? ? t('actions.show_on_main') : t('actions.remove_from_main')
  end

  def destroy_project
    return nil unless projectable.decorate.form?
    link_to t('actions.delete'), self, method: :delete, confirm: 'Вы уверены, что хотите удалить проект?'
  end
end
