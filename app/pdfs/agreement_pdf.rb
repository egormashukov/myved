# encoding: utf-8
require 'prawn'

class AgreementPdf < Prawn::Document
  include ActionView::Helpers::TextHelper

  def initialize(sea_freight, best_response)
    super(top_margin: 50, left_margin: 40, page_size: 'A4')

    @sea_freight = sea_freight
    @best_response = best_response
    @client = @sea_freight.contractor
    @contragent = @best_response.contractor

    create_watarmark
    add_fonts

    stamp_at 'watermark1', [50, 0]
    header
    agreement_info
    trade_results
    main_info_route
    transport_units
    static_pagination 1
    start_new_page

   
    stamp_at 'watermark1', [50, 0]
    proposal
    general_provisions
    agreement_subject
    shipping_cost
    contacts
    static_pagination 2
  end

  def add_fonts
    font_families.update(
      'main' => {
        normal: "#{Rails.root}/app/assets/stylesheets/fonts/Trebuchet MS.ttf",
        bold: "#{Rails.root}/app/assets/stylesheets/fonts/Trebuchet MS Bold.ttf"
      }
    )
    font_size 12
    font(:main, style: :normal)
  end

  def create_watarmark
    create_stamp('watermark1') do
      transparent(0.15, 0.15) do
        image Rails.root.join('app', 'assets', 'images', 'myved-logo.jpg'), at: [0, 540], width: 400
      end
    end
  end

  def header
    text 'СОГЛАШЕНИЕ', align: :center
    move_down 3
    text "НА ОКАЗАНИЕ ТРАНСПОРТНО-ЭКСПЕДИЦИОННЫХ УСЛУГ № <b>#{@sea_freight.id}</b>", align: :center, inline_format: true
    move_down 20
    font_size 8
    text 'г. Москва', indent_paragraphs: 15
    bounding_box([300, 710], width: 200) do
      text "#{Russian.strftime(@sea_freight.end_date, '%d %B')} <b>#{@sea_freight.end_date.year} г.</b>", inline_format: true
    end
  end

  def agreement_info
    move_down 15
    text "(1) #{@client.title} («<b>Клиент</b>»), #{@client.signer}, действующий на основании #{@client.signer_document};
          (2) #{@contragent.title} («<b>Экспедитор</b>»), #{@contragent.signer},
          действующий на основании #{@client.signer_document}; и ", leading: 3, inline_format: true
    move_down 10
    text '(3)'
    bounding_box([18, 656], width: 800, height: 61) do
      text 'по-отдельности именуемые «Сторона», совместно -«Стороны», а также
            <b>общество с ограниченной ответственностью «MyVed»</b> («<b>Оператор торгов</b>»), в лице генерального директора Харькова
            Александра Юрьевича, действующего на основании устава,
            согласовали настоящее Соглашение на оказание транспортно-экспедиционных услуг («Соглашение») на нижеследующих
            условиях:', inline_format: true, leading: 3
    end
  end

  def trade_results
    font_size 12
    text '1. РЕЗУЛЬТАТ ТОРГОВ', indent_paragraphs: 50
    move_down 16
    font_size 7
    table([['дата окончания торгов', @sea_freight.end_date.strftime('%d.%m.%Y')],
           ['оператор торгов', 'ООО "майВЭД"'],
           ['место проведения', 'http://myved.com (http://myved.com)'],
           ['клиент', "#{@client.title} (/contractors/#{@client.id})"],
           ['контрагент', "#{@contragent.title} (/contractors/#{@contragent.id})"]], column_widths: [180, 295], position: :center, cell_style: {inline_format: true}) do |t|
      t.before_rendering_page do |page|
        page.column(1).align = :center
      end
    end
  end


  def shipping_cost
    font_size 12
    text '4. СТОИМОСТЬ ПЕРЕВОЗКИ', indent_paragraphs: 46

    font_size 8
    table [['4.1', 'При проведении Оператором Торгов взаиморасчетов между Клиентом и Экспедитором Оператор Торгов не приобретает никаких прав на денежные средства, поступившие ему на счет. '],
           ['4.2', 'Гражданско-правовые риски возникновения курсовых разниц при осуществлении расчетов между Клиентом и Экспедитором несут соответственно Клиент и Экспедитор.'],
           ['4.3', 'Клиент обязуется оплатить 100% от стоимости перевозки по выставленным счетам Организатора Торгов не менее чем за 5 (пять) рабочих дней до прибытия груза в место назначение, если иное не указанно в счете. Организатор Торгов обязуется перевести полученные средства Экспедитору в полном объеме.'],
          ], cell_style: {borders: [], leading: 3, padding: 3} do |t|
      t.before_rendering_page do |page|
        page.column(1).align = :justify
      end
    end
  end

  def general_provisions
    font_size 12
    move_down 0
    text '2. ОБЩИЕ ПОЛОЖЕНИЯ', indent_paragraphs: 46
    font_size 8
    table [['2.1', 'К Соглашению применимы общие правила оказания транспортно-экспедиционных услуг («Общие правила»), согласованные Сторонами и Оператором Торгов и являются частью Соглашения.'],
           ['2.2', 'Термины, указанные в Соглашении с заглавной буквы, употребляются в том значении, в каком они употреблены в Общих правилах, если из Соглашения не следует иное.'],
           ['2.3', 'Информационный обмен Клиента и Экспедитора организован на базе автоматизированной системы Оператора Торгов, представляющей собой совокупность технических и организационных средств, обеспечивающей оптимизацию взаимодействия Экспедитора с Клиентом, Оператором торгов и третьими лицами, и размещенная во всемирной компьютерной сети Интернет по адресу www.myved.com. («Система»).'],
           ['2.4', 'Документы, оформляющие факты хозяйственной жизни в соответствии с Федеральным законом Российской Федерации от 06.12.11 № 402-ФЗ «О бухгалтерском учете», составляются на бумажном носителе и передаются Клиентом и Экспедитором непосредствен- но друг другу без участия Оператора Торгов.']], cell_style: {borders: [], leading: 3, padding: 3} do |t|
      t.before_rendering_page do |page|
        page.column(1).align = :justify
      end
    end
  end

  def agreement_subject
    font_size 12
    move_down 5
    text '3. ПРЕДМЕТ ДОГОВОРА', indent_paragraphs: 46
    font_size 8
    table [['3.1', 'Экспедитор обязуется за счет Клиента и за вознаграждение оказать Клиенту Транспортно-экспедиционные услуги по перевозке груза на условиях согласованных в рамках проведенных торгов.'],
           ['3.2', 'Оператор Торгов обязуется оказывать следующие юридические и фактические действия, обеспечивающие надлежащее исполнение Клиентом и Экспедитором своих обязательств:']], cell_style: {borders: [], leading: 3, padding: 3} do |t|
      t.before_rendering_page do |page|
        page.column(1).align = :justify
      end
    end

    text '<b>(а)</b> обеспечивать информационный обмен, включая документооборот между Клиентом и Экспедитором путем подготовки проектов и шаблонов документов, необходимых для исполнения Клиентом и Экспедитором своих обязательств;
<b>(б)</b> проводить взаиморасчеты между Клиентом и Экспедитором. При проведении взаиморасчетов вещи и права, поступившие к Оператору Торгов от Стороны, являются собственностью этой Стороны.
<b>(в)</b> содействовать в досудебном разрешении спорных ситуаций, возникающих между Экспедитором и Клиентом в процессе или в связи с оказанием Транспортно-экспедиционных услуг.', inline_format: true, leading: 3, align: :justify

  end

  def main_info_route
    move_down 16
    font_size 14
    table([['Основная информация', 'Маршрут'], []], position: :center, column_widths: [228, 248], cell_style: {
        height: 145, border_lines: [:dotted]
    }) do |t|
      t.before_rendering_page do |page|
        page.column(1).padding_left = 8
        page.column(0).border_left_width = 0
        page.column(-1).border_right_width = 0
      end
    end
    trade_main_info
    trade_route
  end

  def trade_main_info
    font_size 7
    bounding_box([20, 448], width: 400) do
      table [['клиент', "#{@client.title} (/contractors/#{@client.id})"],
             ['наименование групп товаров', @sea_freight.title],
             ['<b>тип перевозки</b>', @sea_freight.transport_string],
             ['дата готовности к погрузке', @sea_freight.loading_date],
             ['класс опасности', @sea_freight.hazard_string],
             ['требования', @sea_freight.requirements_string]],
            column_widths: [70, 180], cell_style: {inline_format: true, leading: 3, padding: 5, borders: []}
    end
  end

  def trade_route
    bounding_box([254, 448], width: 400) do
      table [['условия поставки Incoterms', @sea_freight.incoterms],
             ['порт отгрузки',  @sea_freight.shipping_port],
             ['место таможенного оформления', @sea_freight.customs_clearance],
             ['место доставки', @sea_freight.destination]],
            column_widths: [73, 160], cell_style: {inline_format: true, leading: 3, padding: 5, borders: []}
    end
  end

  def transport_units
    move_down 50
    font_size 14
    text 'Транспортные единицы', indent_paragraphs: 22
    font_size 9
    move_down 5
    table [['количество', 'тип контейнера', 'max вес груза в контейнере']] +
           @sea_freight.transport_units.map{|tranport_unit| [tranport_unit.quantity, tranport_unit.transport, "#{tranport_unit.max_weight} #{tranport_unit.weight_units}"]}, position: :center,
          column_widths: [105, 140, 230], cell_style: {padding: 4, align: :center}
  end

  def proposal
    font_size 14
    text 'Предложение', indent_paragraphs: 21
    move_down 2
    table([['Общая информация', 'Условия'], []], position: :center, column_widths: [240, 260], cell_style: {
        padding: 10, height: 160, border_lines: [:dotted], align: :left
    }) do |t|
      t.before_rendering_page do |page|
        page.column(0).border_width = 0
        page.column(0).border_right_width = 1
        page.column(1).border_width = 0
      end
    end
    font_size 7
    proposal_main_info
    proposal_conditions
  end

  def proposal_main_info
    bounding_box([20, 705], width: 300, height: 250) do
      table [['морская доставка (FILO)', @best_response.filo_currecied],
             ['рекорды по экспедированию', strip_tags(@best_response.port_charges_currecied)],
             ['автодоставка', @best_response.tracking_currecied],
             ['ж/д доставка', @best_response.railway_charges_currecied],
             ['итого', @best_response.total_currecied]],
            column_widths: [125, 95], cell_style: {inline_format: true, padding: 5} do |t|
        t.before_rendering_page do |page|
          page.column(1).align = :center
        end
      end
    end
  end

  def proposal_conditions
    bounding_box([260, 705], width: 400, height: 150) do
      table [['порт доставки', @best_response.destination_port],
             ['транзитное время', @best_response.transit],
             ['бесплатное использование контейнера (dem/det)', @best_response.free_container],
             ['бесплатное хранение в порту', @best_response.free_port],
             ['бесплатное использование машины', @best_response.free_car],
             ['простои автотранспорта в сутки', @best_response.stoppage],
             ['доставка за перевес повара в', @best_response.overbalance]],
            column_widths: [130, 90], cell_style: {inline_format: true, padding: 5} do |t|
        t.before_rendering_page do |page|
          page.column(1).align = :center
        end
      end
    end
  end

  def static_pagination(number = 1)
    font_size 10
    bounding_box([220, 20], width: 100, height: 10) do
      text "Страница #{number} из 2"
    end
  end

  def contacts
    font_size 12
    move_down 10
    text 'КОНТАКТЫ СТОРОН', indent_paragraphs: 60

    font_size 10
    # data = ['<b>Клиент</b>', '', '<b>Экспедитор</b>', '', '<b>Оператор торгов</b>', '']]

    # [:legal_address, :register_number, :contact_person, :appointment, :telephone_number, :email].each do |field|
    #   data << [
    #     Contractor.human_attribute_name(field),
    #     @client.try(field),
    #     Contractor.human_attribute_name(field),
    #     @contractor.try(field),
    #     Contractor.human_attribute_name(field),
    #     Contractor.ns.try(field),
    #   ]
    # end

    data = [['', '<b>Клиент</b>', '<b>Экспедитор</b>', '<b>Оператор торгов</b>']]
    [:legal_address, :register_number, :signer, :signer_appointment, :number, :email].each do |field|
      data << [
        Contractor.human_attribute_name(field),
        @client.try(field),
        @contractor.try(field),
        Contractor.ns.try(field)
      ]
    end

    font_size 8
    move_down 10
    table data, column_widths: [100, 135, 135, 135], position: :center, cell_style: {inline_format: true, padding: 3}
  end
end
