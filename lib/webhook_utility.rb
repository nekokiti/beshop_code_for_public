class WebhookUtility
  require 'logger'
  require 'pp'
  require 'date'

  attr_accessor :result
  attr_accessor :product_id
  attr_accessor :size_id
  attr_accessor :target_company
  attr_accessor :input_text
  attr_accessor :group_key
  attr_accessor :quantity

  attr_accessor :messages
  attr_accessor :messages_items_array
  attr_accessor :button_actions_array
  attr_accessor :button_actions_text_array
  attr_accessor :confirm_actions_array
  attr_accessor :confirm_actions_text_array
  attr_accessor :quick_reply_items_array
  attr_accessor :quick_reply_text_array

  SHOPPING_CART = 'cart'.freeze
  RECEIPT = 'receipt'.freeze
  CASHIER = 'cashier'.freeze
  MENU = 'menu'.freeze
  NEXTTAGS = 'next_tags'.freeze
  ADD_CART = 'add_cart'.freeze
  REMOVE = 'remove'.freeze
  ADJUST_QUANTITY = 'adjust_quantity'.freeze
  TAGPRODUCTS = 'tag_products'.freeze
  RECOMMEND = 'recommend'.freeze
  SHOW_MOVIE = 'movie'.freeze
  TIME = 'time'.freeze

  ADDRESS = 'address'.freeze
  SET_ADDRESS = 'set_address'.freeze
  REPLY_REVISE_ITEM = 'reply_revise_item'.freeze
  REVISE_ADDRESS = 'revise_address'.freeze
  REVISE_LAST_NAME = 'revise_last_name'.freeze
  REVISE_FIRST_NAME = 'revise_first_name'.freeze
  REVISE_EMAIL = 'revise_email'.freeze
  REVISE_TEL = 'revise_tel'.freeze
  REVISE_ZIP_CODE = 'revise_zip_code'.freeze
  REVISE_STATE = 'revise_state'.freeze
  REVISE_CITY = 'revise_city'.freeze
  REVISE_STREET = 'revise_street'.freeze
  REVISE_ROOM_NUMBER = 'revise_room_number'.freeze

  HOW_TO_PAY = 'how_to_pay'.freeze
  PAYING_WAY = 'paying_way'.freeze
  ASKING_TIME = 'asking_time'.freeze

  ASKING_RESERVE_DATE = 'asking_reserve_date'.freeze
  ASKING_RESERVE_TIME = 'asking_reserve_time'.freeze
  RESERVE_ORDER_COMPLETED = 'reserve_order_completed'.freeze
  CONFIRM_RESERVE_ORDER = 'confirm_reserve_order'.freeze
  BACK_TO_CART = 'back_to_cart'.freeze

  COMPLETE_CASH_ON_PAY = 'complete_cash_on_pay'.freeze
  COMPLETE_BANK_TRANSFER = 'complete_bank_transfer'.freeze

  TAKE_OUT_COMPLETE = 'teke_out_complete'.freeze

  def initialize
    self.messages = []
    self.messages_items_array = []
    self.button_actions_array = []
    self.button_actions_text_array = []
    self.confirm_actions_array = []
    self.confirm_actions_text_array = []
    self.quick_reply_text_array = []
    self.quick_reply_items_array = []
    self.result = {}
    self.input_text = ""
  end

  def get_data_from_post_back(data)
    split_and = data.split("&")
    split_and.each do |v|
      split_equal = v.split("=")
      self.result.store(split_equal[0], split_equal[1])
    end
  end

  def self.is_zip_code?(zip_code)
    zip_code.scan(/^\d{3}-?\d{4}$/)
  end

  # todo phaseを設定する際に業種を見れば、業種ごとの住所登録設定が可能なはず

  # richメニューの住所ボタンが押された時に返すフェイズごとのメッセージ
  # 基本的に「現在のphase」に聞きたい情報のメッセージを返す
  def set_msg_by_address_phase_from_rich_menu(address_phase)# {{{
    case address_phase.phase
    when AddressPhase::PHASE_ASK_FOR_LAST_NAME then
      self.messages_items_array << I18n.t('.webhook_utility.ask_last_name')
    when AddressPhase::PHASE_ASK_FOR_FIRST_NAME then
      self.messages_items_array << I18n.t('.webhook_utility.ask_first_name')
    when AddressPhase::PHASE_ASK_FOR_EMAIL then
      self.messages_items_array << I18n.t('.webhook_utility.ask_for_email')
    when AddressPhase::PHASE_ASK_FOR_TEL then
      self.messages_items_array << I18n.t('.webhook_utility.ask_for_tel')
    when AddressPhase::PHASE_ASK_FOR_ZIP then
      self.messages_items_array << I18n.t('.webhook_utility.ask_zip_code')
    end
  end #}}}

  # メッセージで住所情報等が送信された時に返すフェイズごとのメッセージ
  # よって基本的に「次のphase」に聞きたい情報のメッセージを返す
  def set_msg_by_address_phase(address_phase)# {{{
    case address_phase.phase
    when AddressPhase::PHASE_ASK_FOR_LAST_NAME then
      self.messages_items_array << I18n.t('webhook_utility.ask_first_name')

    when AddressPhase::PHASE_ASK_FOR_FIRST_NAME then
      if OccupationMst.is_reserve?(company: target_company)
        self.messages_items_array << I18n.t('webhook_utility.ask_for_email_or_blank')
      else
        self.messages_items_array << I18n.t('webhook_utility.ask_for_email')
      end

    when AddressPhase::PHASE_ASK_FOR_EMAIL then
      self.messages_items_array << I18n.t('.webhook_utility.ask_for_tel')

    when AddressPhase::PHASE_ASK_FOR_TEL then
      if OccupationMst.is_hotel?(company: target_company)
        self.messages_items_array << I18n.t('.webhook_utility.ask_room_number')
      else
        self.messages_items_array << I18n.t('.webhook_utility.ask_zip_code')
      end

    when AddressPhase::PHASE_ASK_FOR_ADDRESS_STATE then
      self.messages_items_array << I18n.t('.webhook_utility.ask_address_city')

    when AddressPhase::PHASE_ASK_FOR_ADDRESS_CITY then
      self.messages_items_array << I18n.t('.webhook_utility.ask_address_street')

    when AddressPhase::PHASE_REVISE_FOR_LAST_NAME then
      self.messages_items_array << I18n.t('.webhook_utility.last_name_revised')

    when AddressPhase::PHASE_REVISE_FOR_FIRST_NAME then
      self.messages_items_array << I18n.t('.webhook_utility.first_name_revised')

    when AddressPhase::PHASE_REVISE_FOR_EMAIL then
      self.messages_items_array << I18n.t('webhook_utility.ask_for_email_revised')

    when AddressPhase::PHASE_REVISE_FOR_TEL then
      self.messages_items_array << I18n.t('webhook_utility.ask_for_tel_revised')

    when AddressPhase::PHASE_REVISE_FOR_ADDRESS_CITY then
      self.messages_items_array << I18n.t('.webhook_utility.address_city_revised')

    when AddressPhase::PHASE_REVISE_FOR_ADDRESS_STREET then
      self.messages_items_array << I18n.t('.webhook_utility.address_street_revised')

    when AddressPhase::PHASE_REVISE_FOR_ROOM_NUMBER then
      self.messages_items_array << I18n.t('.webhook_utility.room_number_revised')

    else
      self.messages_items_array << I18n.t('.webhook_utility.ask_last_name')

    end
  end# }}}

  def set_next_address_phase(address_phase)# {{{
    case address_phase.phase
    when AddressPhase::PHASE_ASK_FOR_LAST_NAME then
      address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_FIRST_NAME)

    when AddressPhase::PHASE_ASK_FOR_FIRST_NAME then
      address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_EMAIL)

    when AddressPhase::PHASE_ASK_FOR_EMAIL then
      address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_TEL)

    when AddressPhase::PHASE_ASK_FOR_TEL then
      address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ZIP)
      address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ROOM_NUMBER) \
        if target_company.occupation_mst_id == OccupationMst::HOTEL
      address_phase.set_my_address_phase(AddressPhase::PHASE_CONFIRM_THE_INPUTED_ADDRESS) \
        if target_company.occupation_mst_id == OccupationMst::RESERVE

    when AddressPhase::PHASE_ASK_FOR_ZIP then
      address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ADDRESS_STATE)

    when AddressPhase::PHASE_ASK_FOR_ADDRESS_STATE then
      if self.result.has_key?('by_zip') && self.result['by_zip'].to_i == 1
        # 郵便番号から住所を設定した場合cityは飛ばす
        address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ADDRESS_STREET)
      else
        address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ADDRESS_CITY)
      end

    when AddressPhase::PHASE_ASK_FOR_ADDRESS_CITY then
      address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ADDRESS_STREET)

    when AddressPhase::PHASE_ASK_FOR_ADDRESS_STREET then
      address_phase.set_my_address_phase(AddressPhase::PHASE_CONFIRM_THE_INPUTED_ADDRESS)

    when AddressPhase::PHASE_REVISE_FOR_ZIP then
      address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_ADDRESS_STATE)

    when AddressPhase::PHASE_REVISE_FOR_ADDRESS_STATE then
      if self.result.has_key?('by_zip') && self.result['by_zip'].to_i == 1
        address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_ADDRESS_STREET)
      else
        address_phase.set_my_address_phase(AddressPhase::PHASE_CONFIRM_THE_INPUTED_ADDRESS)
      end

    else
      # 現在のphaseがreviseなら必ず次は登録住所確認フェイズになる
      address_phase.set_my_address_phase(AddressPhase::PHASE_CONFIRM_THE_INPUTED_ADDRESS)
    end
  end# }}}

  def set_phase_and_msg_as_revise_phase(address_phase, revise_phase)# {{{
    case revise_phase
    when REVISE_LAST_NAME then
      address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_LAST_NAME)
      self.messages_items_array << I18n.t('webhook_utility.ask_last_name')
    when REVISE_FIRST_NAME then
      address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_FIRST_NAME)
      self.messages_items_array << I18n.t('webhook_utility.ask_first_name')
    when REVISE_EMAIL then
      address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_EMAIL)
      self.messages_items_array << I18n.t('webhook_utility.ask_for_email')
    when REVISE_TEL then
      address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_TEL)
      self.messages_items_array << I18n.t('webhook_utility.ask_for_tel')
    when REVISE_ZIP_CODE then
      address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_ZIP)
      self.messages_items_array << I18n.t('webhook_utility.ask_zip_code')
    when REVISE_STATE then
      address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_ADDRESS_STATE)
      self.messages_items_array << I18n.t('webhook_utility.ask_address_state')
    when REVISE_CITY then
      address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_ADDRESS_CITY)
      self.messages_items_array << I18n.t('webhook_utility.ask_address_city')
    when REVISE_STREET then
      address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_ADDRESS_STREET)
      self.messages_items_array << I18n.t('.webhook_utility.ask_address_street')
    when REVISE_ROOM_NUMBER then
      address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_ROOM_NUMBER)
      self.messages_items_array << I18n.t('.webhook_utility.ask_room_number')
    end
  end# }}}

# create line_client_array

  def messages_array()# {{{
    self.messages_items_array.each do |message|
      messages_hash = {
        "type" => "text",
        "text" => message,
        "wrap" => true
      }
      self.messages.push(messages_hash)
    end
    self.messages
  end# }}}

  def video_message(product)# {{{
    messages_hash = {
      "type": "video",
      "originalContentUrl": product.movie_path_url,
      "previewImageUrl": product.movie_path_url(:thumb)
    }
    self.messages.push(messages_hash)
  end# }}}

  # TODO create flex template messages for asking date
  def asking_reserve_date(my_cart)# {{{
    company_reserve = my_cart.company.company_reserve

    contents = []
    if company_reserve.enable_flg == CompanyReserve::RESERVE_PETERN_A
      company_reserve.reserve_time_as.each_with_index do |reserve_time_a, index|
        is_time_nil = reserve_time_a.from_time_1.nil? && reserve_time_a.from_time_2.nil?

        contents.push(
          {
            type: "bubble",
            styles: {
            },
            body: {
              type: "box",
              layout: "vertical",
              spacing: 'md',
              contents: [
                {
                  type: 'text',
                  text: I18n.t("webhook_utility.datetime_receipt"),
                  size: 'xs',
                  color: '#1DB446',
                  wrap: true
                },
                {
                  type: 'text',
                  text: I18n.t("webhook_utility.date_receipt"),
                  size: 'xl',
                  weight: "bold",
                  wrap: true
                },
                {
                  type: "separator"
                }
              ]
            }
          }
        )
        (reserve_time_a.end_date - reserve_time_a.start_date + 1).to_i.times do |offset|
          selected_date = reserve_time_a.start_date + offset
          contents[index][:body][:contents].push(
            {
              type: "button",
              style: "link",
              height: "sm",
              action: {
                type: 'postback',
                label: I18n.l(selected_date, format: "%Y/%m/%d (%A)"),
                data: "action=" + (is_time_nil ? CONFIRM_RESERVE_ORDER : ASKING_RESERVE_TIME) + "&index=" + index.to_s + "&date=" + selected_date.to_s
              }
            },
            {
              type: "separator"
            }
          )
        end
      end
    else
      reserve_time = company_reserve.reserve_time_b
      contents.push(
        {
          type: "bubble",
          styles: {
          },
          body: {
            type: "box",
            layout: "vertical",
            spacing: 'md',
            contents: [
              {
                type: 'text',
                text: I18n.t("webhook_utility.datetime_available"),
                size: 'xs',
                color: '#1DB446',
                wrap: true
              },
              {
                type: 'text',
                text: I18n.t("webhook_utility.date_available"),
                size: 'xl',
                weight: "bold",
                wrap: true
              },
              {
                type: "separator"
              }
            ]
          }
        }
      )
      (reserve_time.days_after_to + 1).times do |offset|
        selected_date = DateTime.now + reserve_time.days_after_from + offset
        is_time_nil = reserve_time.from_time_1.nil? && reserve_time.from_time_2.nil?

        contents[0][:body][:contents].push(
          {
            type: "button",
            style: "link",
            height: "sm",
            action: {
              type: 'postback',
              label: I18n.l(selected_date, format: "%Y/%m/%d (%A)"),
              data: "action=" + (is_time_nil ? CONFIRM_RESERVE_ORDER : ASKING_RESERVE_TIME) + "&date=" + selected_date.to_s
            }
          },
          {
            type: "separator"
          }
        )
      end
    end

    messages_hash = {
      type: "flex",
      altText: "受け取り日指定",
      contents: {
        type: "carousel",
        contents: contents
      }
    }
    messages.push(messages_hash)
    messages
  end# }}}

  # @params index 選択されたreserve_time_asは会社毎最大3つなのでその内何番目のasを特定する為のindex
  # ただindexじゃなくて単純にasのidを渡してくれれば良いのだが・・・
  def asking_reserve_time(my_cart, index, selected_date)# {{{
    # TODO set the action with [RESERVE_ORDER_COMPLETED]
    company_reserve = my_cart.company.company_reserve
    enable_flg = company_reserve.enable_flg
    if (enable_flg == CompanyReserve::RESERVE_PETERN_A)
      reserve_time = company_reserve.reserve_time_as[index.to_i]
    else
      reserve_time = company_reserve.reserve_time_b
    end

    contents = {
      type: "bubble",
      styles: {
      },
      body: {
        type: "box",
        layout: "vertical",
        spacing: 'md',
        contents: [
          {
            type: 'text',
            text: I18n.t("webhook_utility.datetime_#{enable_flg == CompanyReserve::RESERVE_PETERN_A ? 'receipt' : 'available'}"),
            size: 'xs',
            color: '#1DB446',
            wrap: true
          },
          {
            type: 'text',
            text: I18n.t("webhook_utility.time_#{enable_flg == CompanyReserve::RESERVE_PETERN_A ? 'receipt' : 'available'}"),
            size: 'xl',
            weight: "bold",
            wrap: true
          },
          {
            type: "separator"
          },
        ]
      }
    }

    times = []
    times.push([reserve_time.from_time_1, reserve_time.end_time_1]) if reserve_time.from_time_1

    times.push([reserve_time.from_time_2, reserve_time.end_time_2]) if reserve_time.from_time_2

    times.each do |selected_time|
      contents[:body][:contents].push(
        {
          type: "button",
          style: "link",
          height: "sm",
          action: {
            type: 'postback',
            label: selected_time[0].strftime('%R') + " ー " + selected_time[1].strftime('%R'),
            data: "action=" + CONFIRM_RESERVE_ORDER + "&date=" + selected_date.to_s + "&from_time=" + selected_time[0].to_s + "&end_time=" + selected_time[1].to_s
          }
        },
        {
          type: "separator"
        },
      )
    end

    messages_hash = {
      type: "flex",
      altText: "受け取り時間指定",
      contents: contents
    }
    messages.push(messages_hash)
    messages
  end# }}}

  def time_action_test(my_cart)# {{{
    initial_time = OtoriokiTime.initial_time(my_cart)
    contents = {
      "type": "bubble",
      "body": {
        "type": "box",
        "layout": "vertical",
        "contents": [
          {
            "type": "button",
            "action": {
              "type" => "datetimepicker",
              "label" => "Select date",
              "data" => "action=" + TAKE_OUT_COMPLETE,
              "mode" => "datetime",
              "initial" => initial_time,
              "max" => "2020-08-15T20:00",
              "min" => initial_time
            },
            "style": "primary",
            "color": "#0000ff"
          }
        ]
      }
    }
    messages_hash = {
      type: "flex",
      altText: "時間",
      contents: contents
    }
    messages.push(messages_hash)
    messages
  end# }}}

  def reply_image()# {{{
    messages_hash = {
        "type" => "image" ,
        "originalContentUrl" => "https://kuroidog.sakura.ne.jp/images/talk_search_test/7wp-kr110h_t1.jpg",
        "previewImageUrl" => "https://kuroidog.sakura.ne.jp/images/talk_search_test/7wp-kr110h_t1.jpg"
    }
    self.messages.push(messages_hash)
  end# }}}

  def buttons_array(altText = 'confirm template', subject_text = 'Are you sure?', title = 'Menu')# {{{
    # todo set default if each text arrays are null.
    button_actions_array.each_with_index do |message, index|
      messages_hash = {
        type: "template",
        altText: button_actions_text_array[index][:altText],
        template: {
          type: "buttons",
          #thumbnailImageUrl: "https://example.com/bot/images/image.jpg",
          #imageAspectRatio: "rectangle",
          #imageSize: "cover",
          #imageBackgroundColor: "#FFFFFF",
          title: button_actions_text_array[index][:title_text],
          text: button_actions_text_array[index][:subject_text],
          actions: message
        }
      }
      self.messages.push(messages_hash)
    end
    self.messages
  end # }}}

  def confirm_flex_array(user)# {{{
    self.messages.push(name_flex_template(user))
  end # }}}

  def confirm_array(altText = 'confirm template', subject_text = 'Are you sure?')# {{{
    self.confirm_actions_array.each_with_index do |message, index|
      messages_hash = {
        type: "template",
        altText: self.confirm_actions_text_array[index][:altText],
        template: {
          type: "confirm",
          text: self.confirm_actions_text_array[index][:subject_text],
          actions: message
        }
      }
      self.messages.push(messages_hash)
    end
    self.messages
  end# }}}

  def quick_reply_array()# {{{
    # each_with_indexはvalueが先でkeyが後ろ
    self.quick_reply_items_array.each_with_index do |message, index|
      messages_hash = {
        type: "text",
        text: self.quick_reply_text_array[index],
        quickReply: {
          items: message
        }
      }
      self.messages.push(messages_hash)
    end
    self.messages
  end# }}}

  def revise_address# {{{
    self.quick_reply_text_array.push(I18n.t('.webhook_utility.choise_the_item_to_revise'))
    self.quick_reply_items_array.push([
      {
        type: "action",
        imageUrl: "https://example.com/sushi.png",
        action: {
            type: "postback",
            label: "姓",
            data: "action=" + REVISE_ADDRESS + "&phase=" + REVISE_LAST_NAME
        }
      },
      {
        type: "action",
        imageUrl: "https://example.com/tempura.png",
        action: {
            type: "postback",
            label: "名",
            data: "action=" + REVISE_ADDRESS + "&phase=" + REVISE_FIRST_NAME
        }
      },
      {
        type: "action",
        imageUrl: "https://example.com/tempura.png",
        action: {
            type: "postback",
            label: "email",
            data: "action=" + REVISE_ADDRESS + "&phase=" + REVISE_EMAIL
        }
      },
      {
        type: "action",
        imageUrl: "https://example.com/tempura.png",
        action: {
            type: "postback",
            label: "電話番号",
            data: "action=" + REVISE_ADDRESS + "&phase=" + REVISE_TEL
        }
      }
    ])
    return if OccupationMst.is_reserve?(company: target_company)

    if target_company.occupation_mst_id == OccupationMst::HOTEL
      self.quick_reply_items_array[0].push(
        {
          type: "action",
          imageUrl: "https://example.com/tempura.png",
          action: {
              type: "postback",
              label: "部屋番号",
              data: "action=" + REVISE_ADDRESS + "&phase=" + REVISE_ROOM_NUMBER
          }
        }
      )
    else
      self.quick_reply_items_array[0].push(
        {
          type: "action",
          imageUrl: "https://example.com/tempura.png",
          action: {
              type: "postback",
              label: "郵便番号",
              data: "action=" + REVISE_ADDRESS + "&phase=" + REVISE_ZIP_CODE
          }
        },
        {
          type: "action",
          imageUrl: "https://example.com/tempura.png",
          action: {
              type: "postback",
              label: "都道府県",
              data: "action=" + REVISE_ADDRESS + "&phase=" + REVISE_STATE
          }
        },
        {
          type: "action",
          imageUrl: "https://example.com/tempura.png",
          action: {
              type: "postback",
              label: "市町村区",
              data: "action=" + REVISE_ADDRESS + "&phase=" + REVISE_CITY
          }
        },
        {
          type: "action",
          imageUrl: "https://example.com/tempura.png",
          action: {
              type: "postback",
              label: "丁番地及びビル番号",
              data: "action=" + REVISE_ADDRESS + "&phase=" + REVISE_STREET
          }
        }
      )
    end
  end# }}}

  def buy_paypal(user)# {{{
    cart = Cart.get_my_cart(user, self.target_company)
    confirm_actions_for_asking_using_paypal_address_or_not(cart.cart_hash.to_s)
  end# }}}

  def asking_paying_way(line_user)# {{{
    cart = Cart.get_my_cart(line_user, target_company)
    contents_acction_array = []

    address = target_company.occupation_mst_id == OccupationMst::HOTEL ?
      line_user.room_number : "#{line_user.address_state}#{line_user.address_city}#{line_user.address_street}"

    zip = target_company.occupation_mst_id == OccupationMst::HOTEL ? "部屋番号" : "#{line_user.zip}"

    if target_company.cash_on_delivery_info.present? && target_company.cash_on_delivery_info.enable_flg

      display_name = target_company.cash_on_delivery_info_display_name

      contents_acction_array.push(
        {
          type: "text",
          text: display_name,
          color: "#0645AD",
          action: {
            type: "postback",
            data: "action=" + PAYING_WAY + "&way=cash_on_delivery"
          },
          align: "center",
          margin: "xl"
        }
      )
    end

    if target_company.paypal_info.present? && target_company.paypal_info.enable_flg
      contents_acction_array.push(
        {
          type: "text",
          text: "paypal払い",
          color: "#0645AD",
          action: {
            type: "postback",
            data: "action=" + PAYING_WAY + "&way=paypal"
          },
          align: "center",
          margin: "xl"
        }
      )
    end

    if target_company.line_pay_info.present? && target_company.line_pay_info.enable_flg
      contents_acction_array.push(
        {
          type: "text",
          text: "LinePay支払い",
          color: "#0645AD",
          action: {
            type: "uri",
            uri: Rails.application.routes.url_helpers.payments_line_reserve_url(cart_hash: cart.cart_hash.to_s)
          },
          align: "center",
          margin: "xl"
        }
      )
    end

    if target_company.pay_pay_info.present? && target_company.pay_pay_info.enable_flg
      contents_acction_array.push(
        {
          type: "text",
          text: "PayPay支払い",
          color: "#0645AD",
          action: {
            type: "uri",
            uri: Rails.application.routes.url_helpers.payments_paypay_reserve_url(cart_hash: cart.cart_hash.to_s)
          },
          align: "center",
          margin: "xl"
        }
      )
    end

    if target_company.paidy_info.present? && target_company.paidy_info.enable_flg
      contents_acction_array.push(
        {
          type: "text",
          text: "あと払い (ペイディ)",
          color: "#0645AD",
          action: {
            type: "uri",
            uri: Rails.application.routes.url_helpers.payments_paidy_checkout_url(cart_hash: cart.cart_hash.to_s)
          },
          align: "center",
          margin: "xl"
        }
      )
    end

    if target_company.try(:bank_transfer_info)&.enable_flg
      contents_acction_array.push(
        {
          type: "text",
          text: "銀行振り込み",
          color: "#0645AD",
          action: {
            type: "postback",
            data: "action=" + PAYING_WAY + "&way=bank_transfer"
          },
          align: "center",
          margin: "xl"
        }
      )
    end

    contents = {
      type: "bubble",
      body: {# {{{
        type: "box",
        layout: "vertical",
          contents: [
          {
            type: "text",
            text: I18n.t('.webhook_utility.choise_the_paying_way'),
            size: "sm",
            color: "#1DB446",
            weight: "bold"
          },
          {
            type: "text",
            text: "配送先住所",
            weight: "bold",
            size: "md",
            margin: "lg"
          },
          {
            type: "text",
            text: zip,
            size: "xs",
            wrap: true,
            margin: "md"
          },
          {
            type: "text",
            text: address,
            size: "xs",
            wrap: true,
            margin: "md"
          },
          {
            type: "separator",
            margin: "xxl"
          },
          {
            type: "box",
            layout: "vertical",
            margin: "xxl",
            spacing: "sm",
            contents: contents_acction_array
          }
        ]
      }# }}}
    }

    messages_hash = {
      type: "flex",
      altText: "登録住所確認",
      contents: contents
    }

    messages.push(messages_hash)
  end# }}}

  def confirm_actions_for_using_zip_to_set_address(address_phase)# {{{
    subject_text = I18n.t('webhook_utility.ask_using_zip_code_for_address')
    if address_phase.phase == AddressPhase::PHASE_REVISE_FOR_ZIP
      subject_text =
        I18n.t('webhook_utility.ask_using_zip_code_for_address_update')
    end
    self.confirm_actions_text_array.push(
      {
        altText: "住所設定",
        subject_text: subject_text
      }
    )
    self.confirm_actions_array.push([
      {
        type: "postback",
        label: "する",
        data: "action=" + WebhookUtility::SET_ADDRESS + "&by_zip=1"
      },
      {
        type: "postback",
        label: "しない",
        data: "action=" + WebhookUtility::SET_ADDRESS + "&by_zip=0"
      }
    ])
  end# }}}

  def confirm_actions_for_reserve_complete # {{{
    subject_text = I18n.t('webhook_utility.confirm_actions_for_reserve_complete')
    confirm_actions_text_array.push(
      {
        altText: "注文確認",
        subject_text: subject_text
      }
    )
    action= + RESERVE_ORDER_COMPLETED + "&date=" + result['date']
    action << "&from_time=" + result['from_time'] + "&end_time=" + result['end_time'] if result['from_time'] && result['end_time']
    confirm_actions_array.push([
      {
        type: "postback",
        label: "はい",
        data: "action=" + action
      },
      {
        type: "postback",
        label: "カートに戻る",
        data: "action=" + WebhookUtility::BACK_TO_CART
      }
    ])
  end# }}}

  def show_receipt(order)# {{{
    order = Order.with_in_one_month(order)if OccupationMst.is_reserve?(company: target_company)
    contents = Array.new
    body_contents = ""
    order.each do |o|
      body_contents = [# {{{
        {
          type: "text",
          text: "RECEIPT",
          weight: "bold",
          color: "#1DB446",
          size: "sm"
        },
        {
          type: "text",
          text: o.company.company_name,
          weight: "bold",
          size: "xxl",
          margin: "md"
        },
        {
          type: "text",
          text: o.updated_at.to_s,
          size: "xs",
          color: "#aaaaaa",
          wrap: true
        },
        {
          type: "separator",
          margin: "xxl"
        }
      ]# }}}
      contents_items = {# {{{
        type: "box",
        layout: "vertical",
        margin: "xxl",
        spacing: "sm",
        contents: Array.new
      }# }}}
      o.order_products.each do |op|# {{{
        next if op.coupon_flg

        items = {
          type: "box",
          layout: "horizontal",
          contents: [
             {
              type: "text",
              text: "#{op.product_name}#{op.size_name}:#{op.quantity}個",
              size: "sm",
              color: "#555555",
              wrap: true,
              flex: 0
            },
            {
              type: "text",
              text: "#{op.product_price}円(税込)",
              size: "sm",
              color: "#111111",
              align: "end"
            }
          ]
        }
        contents_items[:contents].push(items)
      end# }}}
      body_contents.push(contents_items)
      separator = {# {{{
        type: "separator",
        margin: "xxl"
      }# }}}
      body_contents.push(separator)

      unless o.reserve_detail.nil?
        child_contents_reserve_date = {# {{{
          type: "box",
          layout: "horizontal",
          margin: "xxl",
          contents: [
            {
              type: "text",
              text: "お受け取り予定日",
              size: "sm",
              color: "#555555",
              flex: 0
            },
            {
              type: "text",
              text: o.reserve_detail.take_over_date,
              size: "sm",
              color: "#111111",
              align: "end"
            }
          ]
        }# }}}
        body_contents.push(child_contents_reserve_date)
        child_contents_reserve_time = {# {{{
          type: "box",
          layout: "horizontal",
          margin: "xxl",
          contents: [
            {
              type: "text",
              text: "お受け取り予定時間",
              size: "sm",
              color: "#555555",
              flex: 0
            },
            {
              type: "text",
              text: "#{o.reserve_detail.take_over_time_from&.strftime('%R')} ～ #{o.reserve_detail.take_over_time_to&.strftime('%R')}",
              size: "sm",
              color: "#111111",
              align: "end"
            }
          ]
        }# }}}
        body_contents.push(child_contents_reserve_time)
      else
        child_contents_shipping = {# {{{
          type: "box",
          layout: "horizontal",
          margin: "xxl",
          contents: [
            {
              type: "text",
              text: "送料",
              size: "sm",
              color: "#555555",
              flex: 0
            },
            {
              type: "text",
              text: o.mc_shipping.to_s + "円",
              size: "sm",
              color: "#111111",
              align: "end"
            }
          ]
        }# }}}
        body_contents.push(child_contents_shipping)
        child_contents_ex = {# {{{
          type: "box",
          layout: "horizontal",
          margin: "xxl",
          contents: [
            {
              type: "text",
              text: "手数料",
              size: "sm",
              color: "#555555",
              flex: 0
            },
            {
              type: "text",
              text: o.mc_handling.to_s + "円",
              size: "sm",
              color: "#111111",
              align: "end"
            }
          ]
        }# }}}
        body_contents.push(child_contents_ex)
  
        if o.payment_method == Order::CASH_ON_DELIVERY
        display_name = target_company.cash_on_delivery_info.alternative_name.blank? ?
          "代引き" : target_company.cash_on_delivery_info.alternative_name
          child_contents_cash_on_delivery = {# {{{
            type: "box",
            layout: "horizontal",
            margin: "xxl",
            contents: [
              {
                type: "text",
                text: display_name + "手数料",
                size: "sm",
                color: "#555555",
                flex: 0
              },
              {
                type: "text",
                text: o.cash_on_delivery_price.to_s + "円",
                size: "sm",
                color: "#111111",
                align: "end"
              }
            ]
          }# }}}
        body_contents.push(child_contents_cash_on_delivery)
        end

      end
      body_contents.push(separator)
      child_contents_o = {# {{{
        type: "box",
        layout: "horizontal",
        margin: "xxl",
        contents: [
          {
            type: "text",
            text: "TOTAL",
            size: "sm",
            color: "#555555",
            flex: 0
          },
          {
            type: "text",
            text: o.total_price.to_s + "円(税込)",
            size: "sm",
            color: "#111111",
            align: "end"
          }
        ]
      }# }}}
      body_contents.push(child_contents_o)
      body_contents.push(separator)
      if o.reserve_detail.nil?
        child_contents_discount = {# {{{
          type: "box",
          layout: "horizontal",
          margin: "xxl",
          contents: [
            {
              type: "text",
              text: "クーポン利用額",
              size: "sm",
              color: "#555555",
              flex: 0
            },
            {
              type: "text",
              text: o.discount.to_s + "円",
              size: "sm",
              color: "#111111",
              align: "end"
            }
          ]
        }# }}}
        body_contents.push(child_contents_discount)
        body_contents.push(separator)
      end
      child_contents_txn_id = {# {{{
        type: "box",
        layout: "horizontal",
        margin: "xxl",
        contents: [
          {
            type: "text",
            text: "ORDER ID",
            size: "sm",
            color: "#aaaaaa",
            flex: 0
          },
          {
            type: "text",
            text: OccupationMst.is_reserve?(company: o.company) ? "#{o.id}" : o.txn_id,
            wrap: true,
            size: "sm",
            color: "#aaaaaa",
            align: "end"
          }
        ]
      }# }}}
      body_contents.push(child_contents_txn_id)
      contents.push(# {{{
        {
          type: "bubble",
          styles: {
            footer: {
              separator: true
            }
          },
          body: {
          type: "box",
          layout: "vertical",
          contents: body_contents
          }
        }
      )# }}}
    end

    messages_hash = {
      type: "flex",
      altText: "レシート",
      contents: {
        type: "carousel",
        contents: contents
      }
    }

    self.messages.push(messages_hash)

  end# }}}

  def adjust_product_quantity_flex_template(cart_product_id) # {{{
    cart_product = CartProduct.find(cart_product_id)
    product = cart_product.product
    quantity = product.coupon_flg ? 1 : product.quantity
    unless cart_product.size_id.nil?
      quantity = SizeProduct.releated_size(product, cart_product.size_id).quantity
    end
    carousel = quantity > 100 ? 5 : (quantity.to_i / 20.to_f).ceil
    rows = 5
    columns = 4
    contents = Array.new
    carousel.times do |car|
      horizontal_box = []
      rows.times do |r|
        buttons = []
        q = 0
        1.upto columns do |i|
          q = (car * rows * columns) + (r * columns + i)
          break if q.to_i > quantity.to_i

          action = 'action=' + ADD_CART + '&product_id=' + product.id.to_s + '&quantity=' + q.to_s
          unless cart_product.size_id.nil?
            action << '&size_id=' + cart_product.size_id.to_s
          end
          buttons.push({
            type: 'button',
            action: {
              type: 'postback',
              label: q.to_s,
              data: action
            },
            margin: 'sm',
            style: 'secondary'
          })
        end
        if buttons.length > 0
          horizontal_box.push({
            type: 'box',
            layout: 'horizontal',
            contents: ''
          })
          horizontal_box[r][:contents] = buttons
        end
      end
      item = {
        type: 'bubble',
        body: {
          type: 'box',
          layout: 'vertical',
          spacing: 'sm',
          contents: [
            {
              type: 'text',
              text: I18n.t('webhook_utility.select_quantity'),
              size: 'md',
              wrap: true
            }
          ]
        },
        footer: {
          type: 'box',
          layout: 'vertical',
          spacing: 'sm',
          contents: ''
        }
      }
      item[:footer][:contents] = horizontal_box
      contents.push(item)
    end
    messages_hash = {
      type: "flex",
      altText: "個数選択",
      contents: {
        type: "carousel",
        contents: contents
      }
    }
    messages.push(messages_hash)
  end # }}}

  def products_flex_template(gotten_products, tag = nil)# {{{
    contents = Array.new
    gotten_products.each do |product|
      item = {# {{{
        type: 'bubble',
        hero: {# {{{
          type: 'image',
          url: Rails.env.production? ? product.image_path_url : "#{Rails.application.routes.url_helpers.root_url}#{product.image_path_url}",
          size: 'full',
          aspectRatio: '20:13',
          aspectMode: 'fit'
        },# }}}
        body: {# {{{
          type: 'box',
          layout: 'vertical',
          spacing: 'sm',
          contents: [
            {
              type: 'text',
              text: product.name,
              size: 'lg',
              weight: 'bold',
              wrap: true
            },
            {
              type: 'separator'
            },
            {
              type: 'text',
              wrap: true,
              text: product.description,
              size: 'xs'
            },
            {
              type: 'separator'
            },
            {
              type: 'box',
              layout: 'vertical',
              spacing: 'sm',
              contents: [
                {
                  type: 'box',
                  layout: 'baseline',
                  contents: [
                    {
                      type: 'text',
                      text: product.coupon_flg ? '値引価格' : '価格(税込)',
                      weight: 'bold',
                      margin: 'sm',
                      flex: 0
                    },
                    {
                      type: 'text',
                      text: product.coupon_flg ? "#{product.price}円" : "#{price_with_tax(product).to_s}円",
                      size: 'sm',
                      align: 'end',
                      color: '#aaaaaa'
                    }
                  ]
                },
                {
                  type: 'separator'
                }
              ]
            }
          ]
        }, # }}}
        footer: {# {{{
          type: 'box',
          layout: 'vertical',
          spacing: 'xs',
          contents: [
            {
              type: 'spacer',
              size: 'xs'
            }
          ]
        }# }}}
      }# }}}
      if product.disp_inventory_flg
        item[:body][:contents].last[:contents].push(
          show_inventory(product)
        )
        item[:body][:contents].last[:contents].push(
          { type: 'separator' }
        )
      end
      unless product.has_size
        item[:footer][:contents].push(
          create_add_cart_btn(product)
        )
      end
      if product.movie_path_url.present?
        item[:footer][:contents].push(
          create_show_movie_btn(product)
        )
      end
      if product.url.present?
        item[:footer][:contents].push(
          show_web_url(product)
        )
      end
      if tag.nil? &&
         product.recommend_flg &&
         Product.get_recommend_products(gotten_products.last.id, target_company)
        item[:footer][:contents].push(
          show_other_recommend_products(gotten_products)
        )
      elsif tag.present? &&
            Product.get_products_by_tag(tag, gotten_products.last.id, target_company)
        item[:footer][:contents].push(show_other_products(gotten_products, tag))
      end
      if product.has_size
        item[:footer][:contents][1, 0] = hash_for_size(product)
      end
      contents.push(item)
    end
    #↓何故かシングルコーテーションで囲むとapiがエラーを返すので注意
    messages_hash = {
      type: "flex",
      altText: "商品一覧",
      contents: {
        type: "carousel",
        contents: contents
      }
    }
    self.messages.push(messages_hash)
  end# }}}

  def products_flex_template_with_chat_mode(products, line_id)# {{{
    contents = Array.new
    products.each do |product|
      item = {# {{{
        type: 'bubble',
        hero: {# {{{
          type: 'image',
          url: Rails.env.production? ? product.image_path_url : "#{Rails.application.routes.url_helpers.root_url}#{product.image_path_url}",
          size: 'full',
          aspectRatio: '20:13',
          aspectMode: 'fit'
        },# }}}
        body: {# {{{
          type: 'box',
          layout: 'vertical',
          spacing: 'sm',
          contents: [
            {
              type: 'text',
              text: product.name,
              size: 'lg',
              weight: 'bold',
              wrap: true
            },
            {
              type: 'separator'
            },
            {
              type: 'text',
              wrap: true,
              text: product.description,
              size: 'xs'
            },
            {
              type: 'separator'
            },
            {
              type: 'box',
              layout: 'vertical',
              spacing: 'sm',
              contents: [
                {
                  type: 'box',
                  layout: 'baseline',
                  contents: [
                    {
                      type: 'text',
                      text: '価格(税込)',
                      weight: 'bold',
                      margin: 'sm',
                      flex: 0
                    },
                    {
                      type: 'text',
                      text: price_with_tax(product).to_s + '円',
                      size: 'sm',
                      align: 'end',
                      color: '#aaaaaa'
                    }
                  ]
                },
                {
                  type: 'separator'
                }
              ]
            }
          ]
        },# }}}
        footer: {# {{{
          type: 'box',
          layout: 'vertical',
          spacing: 'xs',
          contents: [
            {
              type: 'spacer',
              size: 'xs'
            }
          ]
        }# }}}
      }# }}}
      if product.disp_inventory_flg
        item[:body][:contents].last[:contents].push(
          show_inventory(product)
        )
        item[:body][:contents].last[:contents].push(
          { type: 'separator' }
        )
      end
      if product.url.present?
        item[:footer][:contents].push(
          show_web_url(product)
        )
      end
      if product.has_size
        SizeProduct.check_quantity(product).each do |sp|
          item[:footer][:contents].push(
            create_size_btn(product, sp.size, mode: :chat, line_id: line_id)
          )
        end
      else
        item[:footer][:contents].push(
          create_buy_line_pay_btn(product, line_id)
        )
      end
      contents.push(item)
    end
    #↓何故かシングルコーテーションで囲むとapiがエラーを返すので注意
    messages_hash = {
      type: "flex",
      altText: "商品一覧",
      contents: {
        type: "carousel",
        contents: contents
      }
    }
    self.messages.push(messages_hash)
  end# }}}

  def show_cart_products(my_cart, cash_on_delivery: false, bank_transfer: false)# {{{
    contents = Array.new
    total_price = my_cart.need_extra_fee? ? my_cart.calc_total_price_in_cart : my_cart.calc_total_products_price_in_cart_with_tax
    shipping_fee = my_cart.need_extra_fee? ? my_cart.company.shipping.shipping_fee : 0
    extra_fee =  my_cart.need_extra_fee? ? my_cart.company.shipping.extra_fee : 0
    deffered_payment = cash_on_delivery || bank_transfer
    if cash_on_delivery
      cash_on_delivery_price = target_company.cash_on_delivery_info.price
      total_price += cash_on_delivery_price
      display_name = target_company.cash_on_delivery_info.alternative_name.blank? ?
        "代引き" : target_company.cash_on_delivery_info.alternative_name
    end
    next_action =
      if OccupationMst.is_reserve?(company: target_company)
        ASKING_RESERVE_DATE
      elsif Product.include_otorioki_flg?(my_cart.products) && my_cart.take_over_time.nil?
        ASKING_TIME
      elsif cash_on_delivery
        COMPLETE_CASH_ON_PAY
      elsif bank_transfer
        COMPLETE_BANK_TRANSFER
      else
        HOW_TO_PAY
      end

    my_cart.cart_products.each do |cart_product|
      size_name = cart_product.size.nil? ? "" : "(#{cart_product.size.name}サイズ)"
      caption = I18n.t('webhook_utility.show_cart_products')
      caption = I18n.t('webhook_utility.cash_on_delivery') if cash_on_delivery
      caption = I18n.t('webhook_utility.bank_transfer') if bank_transfer
      item = {# {{{
        type: "bubble",
        styles: {
          footer: {
            backgroundColor: "#EEEEEE"
          }
        },
        hero: {# {{{
          type: "image",
          url: Rails.env.production? ? cart_product.product.image_path_url : "#{Rails.application.routes.url_helpers.root_url}#{cart_product.product.image_path_url}",
          size: "full",
          aspectRatio: '20:13',
          aspectMode: 'fit'
        },# }}}
        body: {# {{{
          type: "box",
          layout: "vertical",
          spacing: "md",
          action: {
            type: "uri",
            uri: "https://linecorp.com"
          },
          contents: [
            {
              type: "separator"
            },
            {
              type: "text",
              text: caption,
              size: "xs",
              wrap: true
            },
            {
              type: "text",
              text: "カート内のすべての商品の総額は税込み#{total_price}円です。" \
                    << (!OccupationMst.is_reserve?(company: target_company) ? "\n(クーポン利用額:#{my_cart.calc_coupon_price_in_cart}円)" : "") \
                    << (!OccupationMst.is_reserve?(company: target_company) ? "\n(配送料:#{shipping_fee}円)" : "") \
                    << (!OccupationMst.is_reserve?(company: target_company) ? "\n(手数料:#{extra_fee}円)" : "") \
                    << (cash_on_delivery ? "\n(#{display_name}手数料:#{cash_on_delivery_price}円)" : "") ,
              size: "xs",
              color: "#ff0000",
              wrap: true
            },
            {
              type: "separator"
            },
            {
              type: "text",
              text: "#{cart_product.product.name}#{size_name}(#{cart_product.quantity}個)",
              size: "lg",
              weight: "bold",
              wrap: true
            },
            {
              type: "separator"
            },
            {
              type: "text",
              wrap: true,
              text: cart_product.product.description,
              size: "xs"
            },
            {
              type: "separator"
            },
            {
              type: "box",
              layout: "vertical",
              spacing: "sm",
              contents: [
                {
                  type: "box",
                  layout: "baseline",
                  contents: [
                    {
                      type: "text",
                      text: cart_product.product.coupon_flg ? '値引価格' : '価格(税込)',
                      weight: "bold",
                      margin: "sm",
                      flex: 0
                    },
                    {
                      type: "text",
                      text: cart_product.product.coupon_flg ? "#{cart_product.product.price}円" : "#{price_with_tax(cart_product.product).to_s}円",
                      size: "sm",
                      align: "end",
                      color: "#aaaaaa"
                    }
                  ]
                },
                {
                  type: "separator"
                }
              ]
            }
          ]
        },# }}}
        footer: {# {{{
          type: "box",
          layout: "vertical",
          spacing: "md",
          contents: [
            {
              type: "spacer",
              size: "xs"
            },
            {
              type: "button",
              style: "primary",
              action: {
                type: 'postback',
                label: deffered_payment ? I18n.t('webhook_utility.buy_complete') : I18n.t('webhook_utility.go_register'),
                data: "action=" + next_action
              }
            }
          ]
        }# }}}
      }# }}}
      unless deffered_payment # {{{
        item[:footer][:contents].push(
          {
            type: "button",
            style: "secondary",
            action: {
              type: 'postback',
              label: I18n.t('webhook_utility.change_quantity'),
              data: 'action=' + ADJUST_QUANTITY + '&cart_product_id=' + cart_product.id.to_s
            }
          },
          {
            type: "button",
            style: "secondary",
            action: {
              type: 'postback',
              label: I18n.t('webhook_utility.remove'),
              data: 'action=' + REMOVE + '&cart_product_id=' + cart_product.id.to_s
            }
          }
        )
      else
        item[:footer][:contents].push(
          {
            type: "text",
            text: "(一度だけ押してください。\n完了後メッセージが返信されますので暫くお待ち下さい。)",
            size: "md",
            align: "center",
            color: "#aaaaaa",
            wrap: true
          }
        )
      end # }}}
      if cart_product.product.disp_inventory_flg # {{{
        item[:body][:contents].last[:contents].push(
          show_inventory(cart_product.product)
        )
        item[:body][:contents].last[:contents].push(
          { type: 'separator' }
        )
      end # }}}
      contents.push(item)
    end

    messages_hash = {
      type: "flex",
      altText: "カートの中の商品",
      contents: {
        type: "carousel",
        contents: contents
      }
    }
    self.messages.push(messages_hash)
  end# }}}

  def get_tags_as_category(tags)# {{{
    bubbles = Array.new
    contents = ""
    carousel_flg = false
    tags.each_with_index do |tag, index|# {{{
      tag_image_url =  ""
      if tags.first == tag || is_division_remainder_zero?(index, 5)
        carousel_flg = true
        contents = {
          type: "bubble",
          header: {
            type: "box",
            layout: "horizontal",
            contents: [
              {
                type: "text",
                text: "CATEGORIES",
                weight: "bold",
                color: "#aaaaaa",
                size: "sm"
              }
            ]
          },
          body: {
            type: "box",
            layout: "horizontal",
            spacing: "md",
            contents: [
              {
                type: "box",
                layout: "vertical",
                flex: 1,
                contents: Array.new #set categories(tags) image
              },
              {
                "type": "box",
                "layout": "vertical",
                "flex": 2,
                contents: Array.new #set categories(tags) name
              }
            ]
          }
        }
        if Tag.getMyTags(target_company, tags.last.id)
          contents[:footer] = {
            type: "box",
            layout: "horizontal",
            contents: [
              {
                type: "button",
                action: {
                  type: "postback",
                  label: I18n.t('webhook_utility.more'),
                  data: "action=" + WebhookUtility::NEXTTAGS + "&tag=" + tags.last.id.to_s #set dynamic var
                }
              }
            ]
          }
        end
      else
        carousel_flg = false
      end
      if tag.image_path_url.nil?
        # タグの画像が無い場合はなにか適当にサンプルを入れておく
        tag_image_url = "https://scdn.line-apps.com/n/channel_devcenter/img/fx/02_1_news_thumbnail_1.png"
      else
        if Rails.env.production?
          tag_image_url = tag.image_path_url
        else
          tag_image_url = "#{Rails.application.routes.url_helpers.root_url}#{tag.image_path_url}"
        end
      end
      contents[:body][:contents][0][:contents].push(
        {
          type: "image",
          url: tag_image_url,
          action: {
            type: "postback",
            data: "action=" + WebhookUtility::TAGPRODUCTS + "&product_id=0&tag=" + tag.id.to_s
          },
          aspectMode: "fit",
          aspectRatio: "4:3",
          margin: "md",
          size: "sm",
          gravity: "center",
          flex: 1
        }
      )
      contents[:body][:contents][1][:contents].push(
        {
          type: "text",
          text: tag.tag_name,
          action: {
            type: "postback",
            data: "action=" + WebhookUtility::TAGPRODUCTS + "&product_id=0&tag=" + tag.id.to_s
          },
          gravity: "center",
          size: "xs",
          flex: 1
        }
      )
      if tag.url.present?
        contents[:body][:contents][0][:contents].last[:action].delete(:data)
        contents[:body][:contents][0][:contents].last[:action][:type] = "uri"
        contents[:body][:contents][0][:contents].last[:action][:uri] = tag.url
        contents[:body][:contents][1][:contents].last[:action].delete(:data)
        contents[:body][:contents][1][:contents].last[:action][:type] = "uri"
        contents[:body][:contents][1][:contents].last[:action][:uri] = tag.url
      end
      if carousel_flg
        bubbles.push(contents)
      end
    end# }}}

    messages_hash = {
      type: "flex",
      altText: "this is a flex message",
      contents: {
        type: "carousel",
        contents: bubbles
      }
    }
    self.messages.push(messages_hash)
  end# }}}

  private

  def price_with_tax(product)# {{{
    product.calc_price_with_tax
  end# }}}

    def confirm_actions_for_asking_using_paypal_address_or_not(cart_hash)# {{{
      self.confirm_actions_text_array.push(
        {
          altText: "住所選択", #どんなメッセージが適切か分からないのでとりあえず直書き
          subject_text: I18n.t('webhook_utility.choise_using_address')
        }
      )
      self.confirm_actions_array.push([
        {
          type: "uri",
          label: "paypal",
          uri: Rails.application.routes.url_helpers.payments_paypal_payment_url(cart_hash: cart_hash, use_app_address: 0)
        },
        {
          type: "uri",
          label: "本アプリ",
          uri: Rails.application.routes.url_helpers.payments_paypal_payment_url(cart_hash: cart_hash, use_app_address: 1)
        }
      ])
    end# }}}

    def is_division_remainder_zero?(index, i)# {{{
      return index % i == 0
    end# }}}

    def name_flex_template(line_user) # {{{
      contents = {
        type: "bubble",
        body: {# {{{
          type: "box",
          layout: "vertical",
              spacing: "md",
              action: {
                type: "uri",
                uri: "https://linecorp.com"
            },
            contents: [
            {
              type: "text",
              text: "設定したお客様情報",
              size: "xl",
              weight: "bold"
            },
            {
              type: "separator"
            },
            {
              type: "box",
              layout: "vertical",
              spacing: "sm",
              contents: create_name_flex_template_boxes(line_user)
            }
          ]
        },# }}}
        footer: { # {{{
          type: "box",
          layout: "horizontal",
          spacing: "md",
          contents: [
            {
              type: "spacer",
              size: "xs"
            },
            {
              type: "button",
              style: "secondary",
              action: {
                type: "postback",
                label: "修正",
                data: "action=" + WebhookUtility::REPLY_REVISE_ITEM
              }
            }
          ]
        } #}}}
      }
      messages_hash = {
        type: "flex",
        altText: "登録住所確認",
        contents: contents
      }
    end #}}}

    def show_other_products(gotten_products, tag) # {{{
      res = {
        type: 'button',
        action: {
          type: 'postback',
          label: I18n.t('webhook_utility.show_other_products'),
          data: 'action=' + TAGPRODUCTS + '&product_id=' + gotten_products.last.id.to_s + '&tag=' + tag
        }
      }
      res
    end #}}}

    def show_web_url(product) # {{{
      res = {
        type: 'button',
        height: 'sm',
        action: {
          type: 'uri',
          label: I18n.t('webhook_utility.show_web_url'),
          uri: product.url
        }
      }
      res
    end #}}}

    def show_other_recommend_products(gotten_products) # {{{
      res = {
        type: 'button',
        height: 'sm',
        action: {
          type: 'postback',
          label: I18n.t('webhook_utility.show_other_products'),
          data: 'action=' + RECOMMEND + '&product_id=' + gotten_products.last.id.to_s
        }
      }
      res
    end #}}}

    def hash_for_size(product) # {{{
      res = {
              type: 'text',
              text: 'カートに入れるサイズを選択してください。',
              size: 'xs'
            },
            {
              type: 'separator'
            },
            {
              type: 'box',
              layout: 'horizontal',
              contents: []
            }

      sep = {
        type: 'separator',
        margin: 'sm',
        color: '#FFFFFF'
      }

      SizeProduct.check_quantity(product).each do |sp|
        button = create_size_btn(product, sp.size)
        res[2][:contents].push(button).push(sep)
      end
      res
    end #}}}

    def create_add_cart_btn(product) # {{{
      {
        type: 'button',
        height: 'sm',
        style: 'primary',
        action: {
          type: 'postback',
          label: I18n.t('.webhook_utility.add_cart'),
          data: 'action=' + ADD_CART + '&product_id=' + product.id.to_s + '&quantity=1'
        }
      }
    end #}}}

    def create_buy_line_pay_btn(product, line_id) # {{{
      {
        type: 'button',
        style: 'primary',
        action: {
          type: 'uri',
          label: '購入(LINE PAY)',
          uri: Rails.application.routes.url_helpers.payments_reserve_by_one_to_one_url(
            product_id: product.id, line_id: line_id, size_id: Size::NO_SIZE
          )
        }
      }
    end #}}}

    def create_show_movie_btn(product) # {{{
      {
        type: 'button',
        height: 'sm',
        action: {
          type: 'postback',
          label: I18n.t('.webhook_utility.show_movie'),
          data: 'action=' + SHOW_MOVIE + '&product_id=' + product.id.to_s
        }
      }
    end #}}}

    def create_name_flex_template_boxes(line_user)
      name_flex_template_boxes = [
                { # {{{
                  type: "box",
                  layout: "horizontal",
                  contents: [
                    {
                      type: "text",
                      text: "姓:",
                      size: "sm",
                      color: "#555555",
                      flex: 1,
                      align: "end",
                      weight: "bold"
                    },
                    {
                      type: "filler"
                    },
                    {
                      type: "text",
                      text: line_user.last_name,
                      wrap: true,
                      size: "sm",
                      color: "#111111",
                      flex: 1,
                      align: "start"
                    }
                  ]
                }, #}}}
                { # {{{
                  type: "box",
                  layout: "horizontal",
                  contents: [
                    {
                      type: "text",
                      text: "名:",
                      size: "sm",
                      color: "#555555",
                      flex: 1,
                      align: "end",
                      weight: "bold"
                    },
                    {
                      type: "filler"
                    },
                    {
                      type: "text",
                      wrap: true,
                      text: line_user.first_name,
                      size: "sm",
                      color: "#111111",
                      flex: 1,
                      align: "start"
                    }
                  ]
                }, #}}}
                { # {{{
                  type: "box",
                  layout: "horizontal",
                  contents: [
                    {
                      type: "text",
                      text: "email:",
                      size: "sm",
                      color: "#555555",
                      flex: 1,
                      align: "end",
                      weight: "bold"
                    },
                    {
                      type: "filler"
                    },
                    {
                      type: "text",
                      wrap: true,
                      text: line_user.email,
                      size: "sm",
                      color: "#111111",
                      flex: 1,
                      align: "start"
                    }
                  ]
                }, #}}}
                { # {{{
                  type: "box",
                  layout: "horizontal",
                  contents: [
                    {
                      type: "text",
                      text: "電話番号:",
                      size: "sm",
                      color: "#555555",
                      flex: 1,
                      align: "end",
                      weight: "bold"
                    },
                    {
                      type: "filler"
                    },
                    {
                      type: "text",
                      wrap: true,
                      text: line_user.tel,
                      size: "sm",
                      color: "#111111",
                      flex: 1,
                      align: "start"
                    }
                  ]
                } #}}}
      ]
      return name_flex_template_boxes if OccupationMst.is_reserve?(company: target_company)

      if target_company.occupation_mst_id == OccupationMst::HOTEL
        name_flex_template_boxes.push(
                { # {{{
                  type: "box",
                  layout: "horizontal",
                  contents: [
                    {
                      type: "text",
                      text: "部屋番号:",
                      size: "sm",
                      color: "#555555",
                      flex: 1,
                      align: "end",
                      weight: "bold"
                    },
                    {
                      type: "filler"
                    },
                    {
                      type: "text",
                      wrap: true,
                      text: line_user.room_number,
                      size: "sm",
                      color: "#111111",
                      flex: 1,
                      align: "start"
                    }
                  ]
                } #}}}
        )
      else
        name_flex_template_boxes.push(
                { # {{{
                  type: "box",
                  layout: "horizontal",
                  contents: [
                    {
                      type: "text",
                      text: "郵便番号:",
                      size: "sm",
                      color: "#555555",
                      flex: 1,
                      align: "end",
                      weight: "bold"
                    },
                    {
                      type: "filler"
                    },
                    {
                      type: "text",
                      wrap: true,
                      text: line_user.zip,
                      size: "sm",
                      color: "#111111",
                      flex: 1,
                      align: "start"
                    }
                  ]
                }, #}}}
                { # {{{
                  type: "box",
                  layout: "horizontal",
                  contents: [
                    {
                      type: "text",
                      text: "都道府県:",
                      size: "sm",
                      color: "#555555",
                      flex: 1,
                      align: "end",
                      weight: "bold"
                    },
                    {
                      type: "filler"
                    },
                    {
                      type: "text",
                      text: line_user.address_state,
                      wrap: true,
                      size: "sm",
                      color: "#111111",
                      flex: 1,
                      align: "start"
                    }
                  ]
                }, #}}}
                { # {{{
                  type: "box",
                  layout: "horizontal",
                  contents: [
                    {
                      type: "text",
                      text: "市町村区:",
                      size: "sm",
                      color: "#555555",
                      flex: 1,
                      align: "end",
                      weight: "bold"
                    },
                    {
                      type: "filler"
                    },
                    {
                      type: "text",
                      text: line_user.address_city,
                      wrap: true,
                      size: "sm",
                      color: "#111111",
                      flex: 1,
                      align: "start"
                    }
                  ]
                }, #}}}
                { # {{{
                  type: "box",
                  layout: "horizontal",
                  contents: [
                    {
                      type: "text",
                      text: "丁番地及びビル番号:",
                      size: "sm",
                      color: "#555555",
                      flex: 1,
                      align: "end",
                      weight: "bold"
                    },
                    {
                      type: "filler"
                    },
                    {
                      type: "text",
                      text: line_user.address_street,
                      wrap: true,
                      size: "sm",
                      color: "#111111",
                      flex: 1,
                      align: "start"
                    }
                  ]
                } #}}}
        )
      end
        return name_flex_template_boxes
    end

    def show_inventory(product) # {{{
      title = '在庫'
      quantity = product.quantity.to_s
      if product.has_size?
        quantity = ''
        SizeProduct.check_quantity(product).each do |sp|
          size = sp.size
          title << "(#{size.name})"
          quantity << "(#{SizeProduct.releated_size(product, size).quantity.to_s})"
        end
      end
      contents =
        {
          type: 'box',
          layout: 'baseline',
          contents: [
            {
              type: 'text',
              text: title,
              weight: 'bold',
              margin: 'sm',
              flex: 0
            },
            {
              type: 'text',
              text: "#{quantity}個",
              size: 'sm',
              align: 'end',
              color: '#aaaaaa'
            }
          ]
        }
      contents
    end
    #}}}

    def create_size_btn(product, size, mode: nil, line_id: nil) # {{{
      size_product = SizeProduct.releated_size(product, size)
      size_id = size_product.size.id.to_s
      contents = {
        type: 'button',
        action: '',
        height: 'sm',
        style: 'primary'
      }
      action = {
        type: 'postback',
        label: size.name,
        data: 'action=' + ADD_CART + '&product_id=' + product.id.to_s + '&quantity=1' + '&size_id=' + size_id
      }
      unless mode.nil?
        action = {
          type: "uri",
          label: "#{size.name}購入(LINE PAY)",
          uri: Rails.application.routes.url_helpers.payments_reserve_by_one_to_one_url(product_id: product.id, line_id: line_id, size_id: size)
        }
      end
      contents[:action] = action
      contents
    end #}}}

end
