class WebhookController < ApplicationController
  include GetAddressUtility
  include OrderConfirmMail
  # Lineからのcallback or 認証
  require 'pp'
  protect_from_forgery with: :null_session

  #messaging_api ではサーバーホワイトリストは不要になった。(ただしLinePayでは必要)
  #OUTBOUND_PROXY = ENV['OUTBOUND_PROXY']
  RECEIPT_MAX_NUMS = 10
  OUT_OF_BUSINESS = "close_business"

  def callback
    target_company = Company.get_company_with_uuid(params['company'])
    unless Rails.env.test? ||
           is_validate_signature(target_company.channel_secret)
      render body: nil
    end

    event = params['events'][0]
    head :ok && return if event.nil?

    @replyToken = event['replyToken']
    user_id = event['source']['userId']
    user = LineUser.create_line_user(user_id, target_company)
    @utility = WebhookUtility.new
    @utility.target_company = target_company
    @client = LineClient.new(target_company.channel_access_token)
    event_type = is_check_open?(target_company) ? event['type'] : OUT_OF_BUSINESS

    case event_type

    when OUT_OF_BUSINESS
      @utility.messages_items_array << t('.out_of_business')
      res = @client.reply(@replyToken, @utility.messages_array)

    when 'follow'
      @utility.messages_items_array << 'thank you following!!'
      res = @client.reply(@replyToken, @utility.messages_array)

    when 'postback'# {{{
      data = event['postback']['data']
      @utility.get_data_from_post_back(data)

      if @utility.result['action'] == WebhookUtility::TAGPRODUCTS
        gotten_products = Product.get_products_by_tag(
          @utility.result['tag'],
          @utility.result['product_id'],
          @utility.target_company
        )
        res = @client.reply(
          @replyToken,
          @utility.products_flex_template(
            gotten_products, @utility.result['tag']
          )
        )

      elsif @utility.result['action'] == WebhookUtility::RECOMMEND
        gotten_products = Product.get_recommend_products(
          @utility.result['product_id'],
          @utility.target_company
        )
        res = @client.reply(
          @replyToken,
          @utility.products_flex_template(
            gotten_products
          )
        )

      elsif @utility.result['action'] == WebhookUtility::NEXTTAGS
        tags = Tag.getMyTags(@utility.target_company, @utility.result['tag'])
        res = @client.reply(@replyToken, @utility.get_tags_as_category(tags))

      elsif @utility.result['action'] == WebhookUtility::REVISE_ADDRESS
        address_phase = AddressPhase.get_my_address_phase(user)
        @utility.set_phase_and_msg_as_revise_phase(address_phase, @utility.result['phase'])
        res = @client.reply(@replyToken, @utility.messages_array)

      elsif @utility.result['action'] == WebhookUtility::REPLY_REVISE_ITEM
        @utility.revise_address
        res = @client.reply(@replyToken, @utility.quick_reply_array)

      elsif @utility.result['action'] == WebhookUtility::SET_ADDRESS
        address_phase = AddressPhase.get_my_address_phase(user)
        if @utility.result['by_zip'].to_i == 1
          user.set_address_with_hash(get_address(user.zip.to_s))
          @utility.messages_items_array <<
            t('webhook_utility.response_of_setaddress_with_zip') +
            ":" +
            user.address_state + user.address_city +
            user.address_street_by_postal_code
          @utility.messages_items_array << t(
            'webhook_utility.ask_address_street'
          )
          # 郵便番号からの住所設定の場合messagesを介さず、ここで住所(state/city/street_by_postal)を設定し、
          # フェイズを(stateとcityを飛ばして)address_streetへ進める
          @utility.set_next_address_phase(address_phase)
        else
          # zip設定の際にset_next_address_phaseで
          # PHASE_ASK_FOR_ADDRESS_STATE(OR RIVESE_FOR_ADDRESS_STATE)に進んでいるので
          # set_msg_by_address_phaseは使わないで直接messageを設定する
          if address_phase.phase ==
             AddressPhase::PHASE_ASK_FOR_ADDRESS_STATE
            @utility.messages_items_array <<
              t('webhook_utility.ask_address_state')
          elsif address_phase.phase ==
                AddressPhase::PHASE_REVISE_FOR_ADDRESS_STATE
            @utility.set_next_address_phase(address_phase)
            @utility.messages_items_array <<
              t('webhook_utility.response_after_set_zip')
          end
        end
        res = @client.reply(@replyToken, @utility.messages_array)

      elsif @utility.result['action'] == WebhookUtility::ADD_CART
        @utility.product_id = @utility.result['product_id']
        @utility.size_id = @utility.result['size_id']
        @utility.quantity = @utility.result['quantity']
        cart = Cart.create_cart(user, @utility.target_company)
        @utility.messages_items_array << cart.add_cart(@utility.product_id,
                                                      @utility.quantity,
                                                      @utility.size_id)
        res = @client.reply(@replyToken, @utility.messages_array)

      elsif @utility.result['action'] == WebhookUtility::ADJUST_QUANTITY
        cart_product_id = @utility.result['cart_product_id']
        res = @client.reply(
          @replyToken,
          @utility.adjust_product_quantity_flex_template(cart_product_id)
        )

      elsif @utility.result['action'] == WebhookUtility::REMOVE
        cart_products_id = @utility.result['cart_product_id']
        @utility.messages_items_array <<
          CartProduct.del_cart_products(cart_products_id)
        res = @client.reply(@replyToken, @utility.messages_array)

      elsif @utility.result['action'] == WebhookUtility::HOW_TO_PAY
        if user.is_address_set?
          my_cart = Cart.get_my_cart(user, @utility.target_company)
          res = check_cart_price(cart: my_cart, user: user)
        else
          @utility.messages_items_array << t('.request_address')
          res = ask_address(user)
        end

      elsif @utility.result['action'] == WebhookUtility::PAYING_WAY
        if @utility.result['way'] == Order::PAYPAL
          @utility.buy_paypal(user)
          res = @client.reply(@replyToken, @utility.confirm_array)
        elsif @utility.result['way'] == Order::CASH_ON_DELIVERY
          @utility.messages_items_array << t('.show_cart_products_with_cash_on_delivery')
          @utility.messages_array
          my_cart = Cart.get_my_cart(user, @utility.target_company)
          res = @client.reply(@replyToken, @utility.show_cart_products(my_cart, cash_on_delivery: true))
        elsif @utility.result['way'] == Order::BANK_TRANSFER
          @utility.messages_items_array << t('.show_cart_products_with_bank_transfer')
          @utility.messages_array
          my_cart = Cart.get_my_cart(user, @utility.target_company)
          res = @client.reply(@replyToken, @utility.show_cart_products(my_cart, bank_transfer: true))
        end

      elsif @utility.result['action'] == WebhookUtility::SHOW_MOVIE
        product_id = @utility.result['product_id']
        @utility.video_message(Product.find(product_id))
        res = @client.reply(@replyToken, @utility.messages_array)

      elsif @utility.result['action'] == WebhookUtility::ASKING_RESERVE_DATE
        if !user.is_address_set?
          @utility.messages_items_array << t('.request_address')
          res = @client.reply(@replyToken, @utility.messages_array)
        else
          my_cart = Cart.get_my_cart(user, @utility.target_company)
          res = @client.reply(@replyToken, @utility.asking_reserve_date(my_cart))
        end

      elsif @utility.result['action'] == WebhookUtility::ASKING_RESERVE_TIME
        my_cart = Cart.get_my_cart(user, @utility.target_company)
        index = @utility.result['index']
        # エンドユーザーが選択した日
        selected_date = @utility.result['date']

        res = @client.reply(@replyToken, @utility.asking_reserve_time(my_cart, index, selected_date))

      elsif @utility.result['action'] == WebhookUtility::CONFIRM_RESERVE_ORDER
        @utility.confirm_actions_for_reserve_complete
        res = @client.reply(@replyToken, @utility.confirm_array)

      elsif @utility.result['action'] == WebhookUtility::BACK_TO_CART
        my_cart = Cart.get_my_cart(user, @utility.target_company)
        res = @client.reply(@replyToken, @utility.show_cart_products(my_cart))

      elsif @utility.result['action'] == WebhookUtility::RESERVE_ORDER_COMPLETED
        # TODO  CREATE ORDER
        my_cart = Cart.get_my_cart(user, @utility.target_company)
        reserve_times = [@utility.result['date'], @utility.result['from_time'], @utility.result['end_time']]

        reserve_order_service = CreateReserveOrderService.new(my_cart, reserve_times)

        if Product.check_inventory(my_cart)
          reserve_order_service.excute
          send_confirm_mail(hash: my_cart.cart_hash)
          order_histories = Order.order_histories(user, @utility.target_company, RECEIPT_MAX_NUMS)
          @utility.show_receipt(order_histories)

          if @utility.result['from_time'].nil? && @utility.result['end_time'].nil?
            @utility.messages_items_array << t('.complete_take_out_order_without_time')
          else
            @utility.messages_items_array << t('.complete_take_out_order')
          end

          @utility.messages_array
          res = @client.reply(@replyToken, @utility.messages)
        else
          out_of_inventory = Cart.out_of_inventory(my_cart)
          @utility.messages_items_array << out_of_inventory_message(my_cart)
          res = @client.reply(@replyToken, @utility.messages_array)
        end

      elsif @utility.result['action'] == WebhookUtility::ASKING_TIME
        if !user.is_address_set?
          @utility.messages_items_array << t('.request_address')
          res = @client.reply(@replyToken, @utility.messages_array)
        else
          my_cart = Cart.get_my_cart(user, @utility.target_company)
          res = @client.reply(@replyToken, @utility.time_action_test(my_cart))
        end

      elsif @utility.result['action'] == WebhookUtility::COMPLETE_CASH_ON_PAY
          my_cart = Cart.get_my_cart(user, @utility.target_company)
          cash_ond_delivery_service = CreateCashOnDeliveryOrderService.new(my_cart)
          if Product.check_inventory(my_cart)
            cash_ond_delivery_service.excute
            send_confirm_mail(hash: my_cart.cart_hash)
            @utility.messages_items_array << t('.complete_cash_on_delivery_order').gsub(/display_name/, @utility.target_company.cash_on_delivery_info_display_name)
            res = @client.reply(@replyToken, @utility.messages_array)
          else
            out_of_inventory = Cart.out_of_inventory(my_cart)
            @utility.messages_items_array << out_of_inventory_message(my_cart)
            res = @client.reply(@replyToken, @utility.messages_array)
          end

      elsif @utility.result['action'] == WebhookUtility::COMPLETE_BANK_TRANSFER
          my_cart = Cart.get_my_cart(user, @utility.target_company)
          bank_transfer_service = CreateBankTransferOrderService.new(my_cart)
          if Product.check_inventory(my_cart)
            bank_transfer_service.excute
            send_confirm_mail(hash: my_cart.cart_hash)
            @utility.messages_items_array << t('.complete_bank_transfer_order')
            res = @client.reply(@replyToken, @utility.messages_array)
          else
            out_of_inventory = Cart.out_of_inventory(my_cart)
            @utility.messages_items_array << out_of_inventory_message(my_cart)
            res = @client.reply(@replyToken, @utility.messages_array)
          end

      elsif @utility.result['action'] == WebhookUtility::TAKE_OUT_COMPLETE
        my_cart = Cart.get_my_cart(user, @utility.target_company)
        if my_cart.products.where(otorioki_flg: false).exists?
          @utility.messages_items_array << I18n.t('activerecord.models.cart.mix_in_error_with_take_over')
          res = @client.reply(@replyToken, @utility.messages_array)
        else
          time = event['postback']['params']['datetime']
          TakeOverTime.create_take_over_time(time, my_cart)
          teke_out_service = CreateTakeoutOrderService.new(my_cart)
          teke_out_service.create
          @utility.messages_items_array << t('.complete_take_out_order')
          @utility.messages_array
          order_histories = Order.order_histories(user, @utility.target_company, RECEIPT_MAX_NUMS)
          @utility.show_receipt(order_histories)
          res = @client.reply(@replyToken, @utility.messages)
        end
      end
    # }}}
    when 'message' # {{{
      if event['message']['type'] != 'text'
        @utility.messages_items_array << t('.refuse_no_text_type')
        res = @client.reply(@replyToken, @utility.messages_array)
      else
        @utility.input_text = event['message']['text']
        # menuやcart,お会計などの特殊なコマンドの場合
        if @utility.input_text == WebhookUtility::SHOPPING_CART# {{{
          my_cart = Cart.get_my_cart(user, @utility.target_company)
          res = @client.reply(@replyToken, @utility.show_cart_products(my_cart))

        elsif @utility.input_text == WebhookUtility::RECOMMEND
          # recommend でオススメ商品一覧を返す
          gotten_products = Product.get_recommend_products(
            0,
            @utility.target_company
          )
          res = @client.reply(
            @replyToken,
            # 10を5つ並べたければ以下を5回繰り返し、以下の引数をself.messagesにすれば良い
            @utility.products_flex_template(
              gotten_products
            )
          )

        elsif @utility.input_text == WebhookUtility::MENU
          # menu でタグ一覧を返す
          tags = Tag.getMyTags(@utility.target_company, 0)
          @utility.messages_items_array << t('.get_tags_as_category')
          @utility.messages_array
          # 一枚のflexに5つのタグが有り、curouselで横に最大10、合計50取り出せる
          res = @client.reply(@replyToken, @utility.get_tags_as_category(tags))

        elsif @utility.input_text == WebhookUtility::ADDRESS
          if !user.is_address_set?
            # リッチメニュー→addressが来たら最初に名字を送信してもらうメッセージを返す
            # todo 一旦普通に「address」と送られてきた場合は考慮しないがこの場合はphaseに応じて
            # 適切なメッセージを返してやれば良いだけ。以下のメソッドにその「適切なメッセージ」を追加する
            res = ask_address(user)
          else
            # ただし、既に住所登録フェーズが完了していた場合は登録されている住所情報を返す
            res = @client.reply(@replyToken, @utility.confirm_flex_array(user))
          end

        elsif @utility.input_text == WebhookUtility::RECEIPT
          # receipt 直近10件の購入情報を返す
          order_histories = Order.order_histories(user, @utility.target_company, RECEIPT_MAX_NUMS)
          @utility.show_receipt(order_histories)
          res = @client.reply(@replyToken, @utility.messages)

        elsif @utility.input_text == WebhookUtility::CASHIER
          # お会計
          url = "http://byte-road.com"
          res = @client.imagemap_message(@replyToken, url)

  #     for test メインのコンテンツの前後にサブのコンテンツ(補足等)を送れるかテスト。
  #     elsif @utility.input_text == "image"
  #       # messagesはバブリングで最大5つまで設定可能。
  #       # curousel(横に10)もバブリングの1つなので最大で50コンテンツ設定可能
  #       # 下の例ではメッセージ２、画像1の3つのバブリング。
  #       @utility.messages_items_array << "hogehoge"
  #       @utility.messages_items_array << "hugahuga"
  #       @utility.messages_array
  #       @utility.reply_image
  #       res = @client.reply(@replyToken, @utility.messages)# }}}

        else #{{{ 住所設定(と仮定)
          # (find_or_create_byだと適当な文字でもフェイズが出来てしまうのでここでは使わない)
          address_phase = AddressPhase.get_my_address_phase(user)

          # address_phaseが存在しない場合は、
          # 住所設定フェーズではなく適当に文字を投げているだけ
          case address_phase.try(:phase)

          when AddressPhase::PHASE_ASK_FOR_LAST_NAME,
            AddressPhase::PHASE_REVISE_FOR_LAST_NAME then
            user.set_last_name(@utility.input_text)
            @utility.set_msg_by_address_phase(address_phase)

          when AddressPhase::PHASE_ASK_FOR_FIRST_NAME,
            AddressPhase::PHASE_REVISE_FOR_FIRST_NAME then
            user.set_first_name(@utility.input_text)
            @utility.set_msg_by_address_phase(address_phase)

          when AddressPhase::PHASE_ASK_FOR_EMAIL,
            AddressPhase::PHASE_REVISE_FOR_EMAIL then
            user.set_email(@utility.input_text)
            @utility.set_msg_by_address_phase(address_phase)

          when AddressPhase::PHASE_ASK_FOR_TEL,
            AddressPhase::PHASE_REVISE_FOR_TEL then
            user.set_tel(@utility.input_text)
            if OccupationMst.is_reserve?(company: @utility.target_company) &&
               address_phase.phase == AddressPhase::PHASE_ASK_FOR_TEL
              user.set_address_set_flg
              @utility.messages_items_array << t('.complete_set_up')
              @utility.confirm_flex_array(user)
            else
              @utility.set_msg_by_address_phase(address_phase)
            end

          when AddressPhase::PHASE_ASK_FOR_ZIP,
            AddressPhase::PHASE_REVISE_FOR_ZIP then
            if WebhookUtility.is_zip_code?(@utility.input_text).first
              user.set_zip(@utility.input_text)
              # 郵便番号から住所を検索するかどうかの確認メッセージ
              @utility.confirm_actions_for_using_zip_to_set_address(address_phase)
            else
              @utility.messages_items_array << t('.no_postal_code')
              res = @client.reply(@replyToken, @utility.messages_array)
            end

          when AddressPhase::PHASE_ASK_FOR_ADDRESS_STATE,
            AddressPhase::PHASE_REVISE_FOR_ADDRESS_STATE then
            user.set_state(@utility.input_text)
            @utility.set_msg_by_address_phase(address_phase)

          when AddressPhase::PHASE_ASK_FOR_ADDRESS_CITY,
            AddressPhase::PHASE_REVISE_FOR_ADDRESS_CITY then
            user.set_city(@utility.input_text)
            @utility.set_msg_by_address_phase(address_phase)

          when AddressPhase::PHASE_ASK_FOR_ADDRESS_STREET,
            AddressPhase::PHASE_REVISE_FOR_ADDRESS_STREET then
            # 郵便番号から自動設定されたstreetが存在すればそれを頭に付ける(無ければ空文字)
            user.set_street(user.address_street_by_postal_code +
                            @utility.input_text)
            # あろうが無かろうが自動設定された住所を退避するカラムは常にクリアする
            user.set_street_by_postal_code("")
            if address_phase.phase == AddressPhase::PHASE_ASK_FOR_ADDRESS_STREET
              user.set_address_set_flg
              # type: text_messageのみを格納するのがmessages_items_array
              # messages_items_arrayはmessages_arrayが呼ばれた段階で初めてmessaging_api用の配列に変換される
              @utility.messages_items_array << t('.complete_set_up_address')
              # ↓こちらは直接messagesにpushしている。
              @utility.confirm_flex_array(user)
            else
              @utility.set_msg_by_address_phase(address_phase)
            end

          when AddressPhase::PHASE_ASK_FOR_ROOM_NUMBER,
            AddressPhase::PHASE_REVISE_FOR_ROOM_NUMBER then
            user.set_room_number(@utility.input_text)
            if address_phase.phase == AddressPhase::PHASE_ASK_FOR_ROOM_NUMBER
              user.set_address_set_flg
              @utility.messages_items_array << t('.complete_set_up_address')
              @utility.confirm_flex_array(user)
            else
              @utility.set_msg_by_address_phase(address_phase)
            end

          end

          if @utility.messages_items_array.size.positive?
            res = @client.reply(@replyToken, @utility.messages_array)
          elsif @utility.confirm_actions_array.size.positive?
            res = @client.reply(@replyToken, @utility.confirm_array)
          end

          if @utility.messages.size > 0 then
            @utility.set_next_address_phase(address_phase)
          else
            #@utility.messages_items_array << t('.error')
            #res = @client.reply(@replyToken, @utility.messages_array)
          end
        end# }}}
      end
    end

    if !Rails.env.test? && res.present? && res.status == 200
      logger.info({success: res})
    else
      logger.info({fail: res})
    end

    render json: res if Rails.env.test?

    head :ok unless Rails.env.test?

  end

  private

  def ask_address(user)
    address_phase = AddressPhase.create_address_phase(user)
    @utility.set_msg_by_address_phase_from_rich_menu(address_phase)
    @client.reply(@replyToken, @utility.messages_array)
  end

  # verify access from LINE
  def is_validate_signature(channel_secret)
    signature = request.headers['X-LINE-Signature']
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, channel_secret, http_request_body)
    signature_answer = Base64.strict_encode64(hash)
    signature == signature_answer
  end

  def check_cart_price(cart: target_cart, user: target_user)
    price = cart.calc_total_products_price_in_cart_without_tax
    company = @utility.target_company
    if price.positive?
      if company.minimum_price.nil? || price >= company.minimum_price.price
        res = @client.reply(@replyToken, @utility.asking_paying_way(user))
      else
        @utility.messages_items_array << t('.less_than_minimum_price')
        @utility.messages_items_array << "カート内の商品の合計が税抜#{company.minimum_price.price}円以上になる様に調整してください"
        res = @client.reply(@replyToken, @utility.messages_array)
      end
    else
      @utility.messages_items_array << t('.price_less_than_zero')
      res = @client.reply(@replyToken, @utility.messages_array)
    end
    res
  end

  def out_of_inventory_message(my_cart)
    out_of_inventory = Cart.out_of_inventory(my_cart)
    @utility.messages_items_array << "在庫が不足している商品があります"
    info = ''
    out_of_inventory.each do |cart_product|
      info += "在庫切れ商品:#{cart_product.product.name}"
      info += cart_product.product.size_name.nil? ? "" : "(#{cart_product.product.size_name}サイズ)"
      info += "\n商品在庫数:"
      info += cart_product.product.size_name.nil? ? cart_product.product.quantity.to_s : view_context.quantity_with_size(cart_product).to_s
      info += "\nカートに入っている数:"
      info += cart_product.quantity.to_s
      info += "\n------------------------\n"
    end
    info
  end

  def is_check_open?(target_company)
    BusinessHour.is_shop_open?(company: target_company)
  end
end
