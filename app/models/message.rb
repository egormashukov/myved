# encoding: utf-8

class Message < ActiveRecord::Base
  attr_accessible :body, :messagable_id, :messagable_type, :receiver_id, :sender_id, :title, :read
  attr_readonly :receiver_id, :sender_id

  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  belongs_to :messagable, polymorphic: true

  belongs_to :sender, class_name: 'Contractor', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'Contractor', foreign_key: 'receiver_id'
  validates_presence_of :receiver_id, :sender_id, :body

  scope :for_current_contractor, ->(current_contractor) { where('receiver_id = ? OR sender_id = ?', current_contractor, current_contractor) }

  scope :ordered, -> { order('created_at DESC') }

  scope :dialogue, ->(first_contractor, second_contractor) { for_current_contractor(first_contractor).for_current_contractor(second_contractor)}

  scope :to_current_contractor, ->(current_contractor) { where(receiver_id: current_contractor).order('created_at DESC') }

  # scope :from_current_contractor, ->(current_contractor) { where(sender_id: current_contractor).order('created_at DESC') }

  scope :not_read, -> { where(read: false) }
  after_create :send_email

  def receiver_locale
    receiver.language
  end

  def with_contractor(current_contractor)
    if receiver == current_contractor
      sender
    else
      receiver
    end
  end

  def self.grouped_and_sorted_by_contractor(current_contractor)
    scoped.includes(:sender, :receiver).group_by{|m| m.with_contractor(current_contractor)}.sort{|a,b| b[1][0]['created_at']<=> a[1][0]['created_at']}
  end

  def self.invitation_from_contractor(contractor, part)
    if part == :title
      "Invitation to myVED"
    elsif part == :body
      "I’d like to invite you to myVED <br/>
      Your invitation code: <b>#{contractor.invitation_cod}</b> <br/>
      <a href=\'/contractors/sign_up?ic=#{contractor.invitation_cod}&profile=#{contractor.opposite_profile}/\' >Link to registration </a><br/>
      Best regards, <br/>
      #{contractor.title}"
    end
  end

  def self.greetings_message(part, contractor)
    if contractor.buyer?
      if part == :title
        ["Добро пожаловать на myVED."]
      elsif part == :body
        ["
        <p>В период тестового запуска, Вы можете воспользоваться следующим функционалом:</p>
        <ul>
          <li>Пригласить иностранных продавцов и устроить торги среди них;</li>
          <li>Просчитать себестоимость импорта-экспорта;</li>
          <li>Устроить торги по морской доставке контейнеров</li>
        <p>Для того, чтобы воспользоваться полным функционалом данных сервисов Вам дополнительно необходимо авторизоваться </p>
        <p>Желаем хорошей работы и мы очень надеемся на Вашу обратную связь - она поможет нам улучшить сервис, чтобы он был полезен Вам в работе и экономил Ваши время и деньги.</p>
        "]
      end  
    elsif contractor.supplier?
      if part == :title
        ["Welcome to myVED", "Добро пожаловать на myVED."]
      elsif part == :body
        [" <p>With help from myVED you can:</p>
          <ul>
            <li> receive requests from Russian clients and participate in the bidding.</li>
            <li>help your client deliver goods to the warehouse in Russia.</li>
            <li>solve any issues related to import-export operations in your country.</li>
          </ul>
          <p> At present, our site is taking its first steps and your feedback will help us improve our service to ensure that it is beneficial to you and helps you economize your time and money.
          <p/>", 
          "<p>При помощи myVED Вы сможете:</p>
          <ul>
            <li> получать запросы от клиентов из России и участвовать в торгах.</li>
            <li> помочь клиенту доставить товар на склад в Россию.</li>
            <li> решить любые вопросы импорта и экспорта товаров в Вашей стране.</li>
          </ul>
          <p> В настоящий момент наш сайт делает первые шаги и Ваша обратная связь поможет нам улучшить сервис, чтобы он был полезен Вам в работе и экономил Ваши время и деньги.<p/>"]
      end
    elsif contractor.ved_contractor?
      if part == :title
        ["Welcome to myVED", "Добро пожаловать на myVED."]
      elsif part == :body
        ["<p>With help from myVED you can:</p>
          <ul>
            <li> to receive requests from Russian clients directly.</li>
            <li> to make offers and participate in the biddings</li>
            <li>to execution of orders.</li>
          </ul>
          <p> At present, our site is taking its first steps and your feedback will help us improve our service to ensure that it is beneficial to you and helps you economize your time and money.
          <p/>", 
          "<p>При помощи myVED Вы сможете:</p>
          <ul>
            <li> получать запросы от клиентов из России напрямую;</li>
            <li> делать предложения и участвовать в торгах;</li>
            <li> вести исполнение поручений.</li>
          </ul>
          <p> В настоящий момент наш сайт делает первые шаги и Ваша обратная связь поможет нам улучшить сервис, чтобы он был полезен Вам в работе и экономил Ваши время и деньги.<p/>"]
      end
    end
  end

  def new_certification_request(certification_request)
    self.assign_attributes(
      title: "Новый запрос на сертификацию",
      body: "
      Название: #{certification_request.title}
      <br/>
      Описание: #{certification_request.body}
      <br/>
      Вложенные файлы: #{certification_request.attachments.count}
      <br/>
      <a href=\'/admin/certification_requests/#{certification_request.id}/certification_responses/new\'>ответить</a>
      ")
    save
  end

  def new_certification_request_to_contractor(certification_request)
    self.assign_attributes(
      title: "Разрешительные документы \"#{certification_request.title}\"",
      body: "
      Ваш запрос принят и передан экспертам. Вы получите ответ в течение одного рабочего дня.
      <br/>
      #{certification_request_link(certification_request)}
      ")
    save
  end

  def new_certification_response(certification_request)
    self.assign_attributes(
      title: "Разрешительные документы \"#{certification_request.title}\"",
      body: "
        Пришел ответ по запросу \"#{certification_request.title}\"
        #{certification_request_link(certification_request)}
      ")
    save
  end

  def certification_instructions(certification_request)
    self.assign_attributes(
      title: "Разрешительные документы \"#{certification_request.title}\"",
      body: "
        Вам были высланы инструкции по оформлению разрешительных документов:
        #{certification_request_link(certification_request)}
      ")
    save
  end

  def certification_completed(certification_request)
    self.assign_attributes(
      title: "Разрешительные документы \"#{certification_request.title}\"",
      body: "
        Вам выслан скан разрешительного документа. Просмотреть его Вы можете, перейдя по ссылке:
        #{certification_request_link(certification_request)}
        <br/>
        Оригинал документа и документы для бухгалтерии будут высланы Вам на почту, указанную в <a href=\'/contractors/#{certification_request.contractor.id}\'>Профиле</a>.
      ")
    save
  end

  def new_certification_data_to_myved(certification_request)
    self.assign_attributes(
      title: "Разрешительные документы \"#{certification_request.title}\"",
      body: "
        Запрос на оформление разрешительного документа #{certification_request.title} получен.
        #{certification_request_link(certification_request)}
      ")
    save
  end

  def new_certification_data(certification_request)
    self.assign_attributes(
      title: "Разрешительные документы \"#{certification_request.title}\"",
      body: "
        Скан разрешительного документа будет выслан в ближайшее время при условии поступления оплаты. Статус оплаты Вы можете проверить в <a href=\'/pages/finances\'>разделе Финансы</a>.
        #{certification_request_link(certification_request)}
      ")
    save
  end

  def certification_paid(certification_request)
    self.assign_attributes(
      title: "Разрешительные документы \"#{certification_request.title}\"",
      body: "
        Принята оплата по запросу #{certification_request.title}
        #{certification_request_link(certification_request)}
      ")
    save
  end

  def certification_request_acceptance_to_contractor(certification_request)
    self.assign_attributes(
      title: "Разрешительные документы \"#{certification_request.title}\"",
      body: "
        Вы приняли условия по оформлению разрешительных документов. Ожидайте получения дальнейших инструкций.
        #{certification_request_link(certification_request)}
      ")
    save
  end

  def certification_request_acceptance_to_myved(certification_request)
    self.assign_attributes(
      title: "Разрешительные документы \"#{certification_request.title}\"",
      body: "
        Клиент #{certification_request.contractor.try(:title)} принял условия по запросу #{certification_request.title}.
        <br/>
        Вышлите счет и макет для оформления.
        #{certification_request_link(certification_request)}
      ")
    save
  end

  def certification_request_refusal_to_myved(certification_request)
    self.assign_attributes(
      title: "Разрешительные документы \"#{certification_request.title}\"",
      body: "
        Клиент #{certification_request.contractor.title} отклонил запрос \"#{certification_request.title}\"
        #{certification_request_link(certification_request)}
      ")
    save
  end

private
  def tender_link(tender)
    if receiver_locale == 'ru'
      "(<a href=\'/tenders/#{tender.id}\'>перейти к торгам</a>)"
    else
      "(<a href=\'/tenders/#{tender.id}\'>go to bidding</a>)"
    end
  end

  def certification_request_link(certification_request)
    "<br/><a href=\'/certification_requests/#{certification_request.id}\'>просмотреть</a>"
  end

  def contractor_link(contractor)
    "(<a href=\'/contractors/#{contractor.id}\'>#{contractor.title}</a>)"
  end

  def send_email
    MessageMailer.new_message(self).deliver
  end
end
