require 'rails_helper'
require 'json'

RSpec.describe 'Webhook', type: :request do
  create_sample_order
  let(:utility) { WebhookUtility.new }
  let(:webhook_callback_url_with_company_uuid) do
    "#{webhook_callback_url}?company=#{company.unique_id}"
  end
  let(:post_value) { { events: [] } }

  def create_message_type_sticker
    post_value[:events].push(
      { "type": "message",
        "source": {
          "userId": line_user.line_id, "type": "user"
        },
        "message": { "type": "sticker", "id": "12345" }
      }
    )
    post_value
  end

  def create_text_message_data(message)
    post_value[:events].push(
      { "type": "message",
        "source": {
          "userId": line_user.line_id, "type": "user"
        },
        "message": { "type": "text", "text": message }
      }
    )
    post_value
  end

  def create_post_back_event_data(action)
    post_value[:events].push(
      { "type": "postback",
        "source": {
          "userId": line_user.line_id, "type": "user"
        },
        "postback": { data: "action=" + action }
      }
    )
    post_value
  end

  def create_post_back_event_data_with_date_time(action, datetime)
    post_value[:events].push(
      { "type": "postback",
        "source": {
          "userId": line_user.line_id, "type": "user"
        },
        "postback": {
          data: "action=" + action,
          "params": { "datetime": datetime }
        }
      }
    )
    post_value
  end

  describe 'sent message that type is not text ' do
    it "return out of time messges" do
      post webhook_callback_url_with_company_uuid,
           params: create_message_type_sticker
      # テスト実行の時間によって結果が変わるので注意
        msg =I18n.t('webhook.callback.refuse_no_text_type')
        expect(JSON.parse(response.body)[0]["text"]).to eq msg
    end
  end

  describe 'over the business hour' do
    create_business_hour
    it "return out of time messges" do
      post webhook_callback_url_with_company_uuid,
           params: create_text_message_data("menu")
      # テスト実行の時間によって結果が変わるので注意
      if Time.current > open_time && Time.current < close_time
        msg =I18n.t('webhook.callback.get_tags_as_category')
      else
        msg =I18n.t('webhook.callback.out_of_business')
      end
        expect(JSON.parse(response.body)[0]["text"]).to eq msg
    end
  end

  describe 'returns proper message about address by postback depend on phase' do
    include GetAddressUtility
    let!(:address_phase) { AddressPhase.create_address_phase(line_user) }

    describe 'accepted the message by post_back' do
      describe 'for asking time of take out' do
        let(:next_action) { WebhookUtility::ASKING_TIME }
        context 'the users address has already setted' do
          it 'returns the asking message for for the time of take out' do
            line_user.update!(address_set_flg: true)
            cart.products.each do |p|
              p.update!(otorioki_flg: true)
              create(:otorioki_time, product: p, min_time: 30)
            end
            post webhook_callback_url_with_company_uuid,
                 params: create_post_back_event_data(next_action)
            expect(JSON.parse(response.body)[0]["altText"]).to eq '時間'
          end
        end
        context 'the users address has not setted yet' do
          it 'returns the asking message for for set the address' do
            line_user.update!(address_set_flg: false)
            post webhook_callback_url_with_company_uuid,
                 params: create_post_back_event_data(next_action)
            expect(JSON.parse(response.body)[0]["text"].to_s).to eq I18n.t('.webhook.callback.request_address')
          end
        end
      end

      describe 'create order with daibiki' do
        let!(:cash_on_delivery_info) { create(:cash_on_delivery_info, company: company, price: 500) }
          context "enough quantity" do
            it 'creates order and returns order complete message of cash_on_delivery' do
              data = WebhookUtility::COMPLETE_CASH_ON_PAY
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(data)
              display_name = I18n.t('.webhook.callback.complete_cash_on_delivery_order').gsub(/display_name/, company.cash_on_delivery_info_display_name)
              expect(Order.last.payment_method).to eq Order::CASH_ON_DELIVERY
              expect(Order.last.cash_on_delivery_price).to eq cash_on_delivery_info.price
              expect(JSON.parse(response.body)[0]["text"]).to eq display_name
          end
          context "less quantity" do
            it 'returns the message for out of quantity' do
              data = WebhookUtility::COMPLETE_CASH_ON_PAY
              p_without_size = cart.products.where(has_size: false).first
              p_without_size.update!(quantity: 0)
              p_with_size = cart.products.where(has_size: true).first
              SizeProduct.releated_size(p_with_size, s_size).update!(quantity: 0)
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(data)
              expect(JSON.parse(response.body)[0]["text"]).to eq '在庫が不足している商品があります'
              expect(JSON.parse(response.body)[1]["text"]).to include p_without_size.name
              expect(JSON.parse(response.body)[1]["text"]).to include p_with_size.name
            end
          end
        end
      end

      describe 'create order with bank_transfer' do
        let!(:bank_transfer_info) { create(:bank_transfer_info, company: company) }
          context "enough quantity" do
            it 'creates order and returns order complete message of bank_transfer' do
              data = WebhookUtility::COMPLETE_BANK_TRANSFER
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(data)
              expect(Order.last.payment_method).to eq Order::BANK_TRANSFER
              expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('.webhook.callback.complete_bank_transfer_order')
          end
          context "less quantity" do
            it 'returns the message for out of quantity' do
              data = WebhookUtility::COMPLETE_BANK_TRANSFER
              p_without_size = cart.products.where(has_size: false).first
              p_without_size.update!(quantity: 0)
              p_with_size = cart.products.where(has_size: true).first
              SizeProduct.releated_size(p_with_size, s_size).update!(quantity: 0)
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(data)
              expect(JSON.parse(response.body)[0]["text"]).to eq '在庫が不足している商品があります'
              expect(JSON.parse(response.body)[1]["text"]).to include p_without_size.name
              expect(JSON.parse(response.body)[1]["text"]).to include p_with_size.name
            end
          end
        end
      end

      describe 'set take out tiem to cart' do
        let(:next_action) { WebhookUtility::TAKE_OUT_COMPLETE }
        let(:datetime) { '2017-12-25t21:30' }
        it 'sets take out time to cart and return proper messages' do
          cart.products.each do |p|
            p.update!(otorioki_flg: true)
          end
          post webhook_callback_url_with_company_uuid,
               params: create_post_back_event_data_with_date_time(next_action, datetime)
          expect(JSON.parse(response.body)[0]["text"].to_s).to eq I18n.t('.webhook.callback.complete_take_out_order')
        end
      end

      describe 'set take out tiem to cart' do
        let(:next_action) { WebhookUtility::TAKE_OUT_COMPLETE }
        let(:datetime) { '2017-12-25t21:30' }
        it 'sets take out time to cart and return proper messages' do
          cart.products.each do |p|
            p.update!(otorioki_flg: true)
          end
          post webhook_callback_url_with_company_uuid,
               params: create_post_back_event_data_with_date_time(next_action, datetime)
          expect(JSON.parse(response.body)[0]["text"].to_s).to eq I18n.t('.webhook.callback.complete_take_out_order')
        end
      end

      describe 'for set address' do
  
        before do
          utility.input_text = WebhookUtility::ADDRESS
        end
  
        context '住所テンプレートの修正ボタンを押した時' do
          context 'default occupation' do
            it 'returns the asking message which items you want to revise' do
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(WebhookUtility::REPLY_REVISE_ITEM)
              expect(JSON.parse(response.body)[0]["text"]).to eq \
                I18n.t('webhook_utility.choise_the_item_to_revise')
            end
          end
          context 'occupation is hotel' do
            it 'returns the asking message which items you want to revise' do
              company.update!(occupation_mst_id: OccupationMst::HOTEL)
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(WebhookUtility::REPLY_REVISE_ITEM)
              expect(JSON.parse(response.body)[0]["quickReply"]["items"].last["action"]["label"]).to eq \
                '部屋番号'
            end
          end
          context 'occupation is reserve' do
            it 'returns the asking message which items you want to revise but not included addresses' do
              company.update!(occupation_mst_id: OccupationMst::RESERVE)
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(WebhookUtility::REPLY_REVISE_ITEM)
              JSON.parse(response.body)[0]["quickReply"]["items"].each do |item|
                expect(item["action"]["label"]).to_not eq "郵便番号"
                expect(item["action"]["label"]).to_not eq "都道府県"
                expect(item["action"]["label"]).to_not eq "市町村区"
                expect(item["action"]["label"]).to_not eq "丁番地及びビル番号"
              end
            end
          end
        end
  
        context '住所の修正を行う時' do
          context '名字の修正を行う場合' do
            it 'returns the message to revise the lastname' do
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(WebhookUtility::REVISE_ADDRESS +
                                               "&phase=" +
                                               WebhookUtility::REVISE_LAST_NAME)
              expect(JSON.parse(response.body)[0]["text"]).to eq \
                I18n.t('webhook_utility.ask_last_name')
            end
          end
  
          context '名前の修正を行う場合' do
            it 'returns the message to revise the firstname' do
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(WebhookUtility::REVISE_ADDRESS +
                                               "&phase=" +
                                               WebhookUtility::REVISE_FIRST_NAME)
              expect(JSON.parse(response.body)[0]["text"]).to eq \
                I18n.t('webhook_utility.ask_first_name')
            end
          end
  
          context 'メアドの修正を行う場合' do
            it 'returns the message to revise the email' do
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(WebhookUtility::REVISE_ADDRESS +
                                               "&phase=" +
                                               WebhookUtility::REVISE_EMAIL)
              expect(JSON.parse(response.body)[0]["text"]).to eq \
                I18n.t('webhook_utility.ask_for_email')
            end
          end
  
          context '電話番号の修正を行う場合' do
            it 'returns the message to revise the tel' do
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(WebhookUtility::REVISE_ADDRESS +
                                               "&phase=" +
                                               WebhookUtility::REVISE_TEL)
              expect(JSON.parse(response.body)[0]["text"]).to eq \
                I18n.t('webhook_utility.ask_for_tel')
            end
          end
  
          context '郵便番号の修正を行う場合' do
            it 'returns the message to revise the zipcode' do
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(WebhookUtility::REVISE_ADDRESS +
                                               "&phase=" +
                                               WebhookUtility::REVISE_ZIP_CODE)
              expect(JSON.parse(response.body)[0]["text"]).to eq \
                I18n.t('webhook_utility.ask_zip_code')
            end
          end
  
          context '都道府県の修正を行う場合' do
            it 'returns the message to revise the address_state' do
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(WebhookUtility::REVISE_ADDRESS +
                                               "&phase=" +
                                               WebhookUtility::REVISE_STATE)
              expect(JSON.parse(response.body)[0]["text"]).to eq \
                I18n.t('webhook_utility.ask_address_state')
            end
          end
  
          context '市町村区の修正を行う場合' do
            it 'returns the message to revise the address_city' do
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(WebhookUtility::REVISE_ADDRESS +
                                               "&phase=" +
                                               WebhookUtility::REVISE_CITY)
              expect(JSON.parse(response.body)[0]["text"]).to eq \
                I18n.t('webhook_utility.ask_address_city')
            end
          end
  
          context '町番地その他マンション名等の修正を行う場合' do
            it 'returns the message to revise the address_street' do
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(WebhookUtility::REVISE_ADDRESS +
                                               "&phase=" +
                                               WebhookUtility::REVISE_STREET)
              expect(JSON.parse(response.body)[0]["text"]).to eq \
                I18n.t('webhook_utility.ask_address_street')
            end
          end

          context '部屋番号の修正を行う場合' do
            it 'returns the message to revise the room_number' do
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(WebhookUtility::REVISE_ADDRESS +
                                               "&phase=" +
                                               WebhookUtility::REVISE_ROOM_NUMBER)
              expect(JSON.parse(response.body)[0]["text"]).to eq \
                I18n.t('webhook_utility.ask_room_number')
            end
          end
        end
  
        describe "address btn on the rich menu is pushed" do
  
          context 'まだ住所設定が完了していない時' do
  
            context '初回住所設定を開始する時' do
              it 'returns the message that asks users last_name' do
                post webhook_callback_url_with_company_uuid,
                     params: create_text_message_data(WebhookUtility::ADDRESS)
                expect(JSON.parse(response.body)[0]["text"]).to eq \
                  I18n.t('webhook_utility.ask_last_name')
              end
            end
  
            context '名前を聞く時' do
              it 'returns the message that asks users first name' do
                utility.set_next_address_phase(address_phase)
                post webhook_callback_url_with_company_uuid,
                     params: create_text_message_data(WebhookUtility::ADDRESS)
                expect(JSON.parse(response.body)[0]["text"]).to eq \
                  I18n.t('webhook_utility.ask_first_name')
              end
            end
  
            context '郵便番号を聞く時' do
              it 'retuns the message that asks users zip' do
                address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_TEL)
                utility.target_company = company
                utility.set_next_address_phase(address_phase)
                post webhook_callback_url_with_company_uuid,
                     params: create_text_message_data(WebhookUtility::ADDRESS)
                expect(JSON.parse(response.body)[0]["text"]).to eq \
                  I18n.t('webhook_utility.ask_zip_code')
              end
            end
          end
  
          context '住所設定が完了している場合' do
            before do
              address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ADDRESS_STREET)
              utility.set_next_address_phase(address_phase)
              line_user.set_address_set_flg
            end
            context "default" do
              it 'retuns the message of name_template with own address' do
                post webhook_callback_url_with_company_uuid,
                     params: create_text_message_data(WebhookUtility::ADDRESS)
                expect(JSON.parse(response.body)[0]["altText"]).to eq \
                  "登録住所確認"
                items = JSON.parse(response.body)[0]["contents"]["body"]["contents"][2]["contents"]
                expect(items[0]["contents"][0]["text"]).to eq "姓:"
                expect(items[1]["contents"][0]["text"]).to eq "名:"
                expect(items[2]["contents"][0]["text"]).to eq "email:"
                expect(items[3]["contents"][0]["text"]).to eq "電話番号:"
                expect(items[4]["contents"][0]["text"]).to eq "郵便番号:"
                expect(items[5]["contents"][0]["text"]).to eq "都道府県:"
                expect(items[6]["contents"][0]["text"]).to eq "市町村区:"
                expect(items[7]["contents"][0]["text"]).to eq "丁番地及びビル番号:"
              end
            end
            context "reserve" do
              it 'retuns the message of name_template without address' do
                company.update!(occupation_mst_id: OccupationMst::RESERVE)
                post webhook_callback_url_with_company_uuid,
                     params: create_text_message_data(WebhookUtility::ADDRESS)
                expect(JSON.parse(response.body)[0]["altText"]).to eq \
                  "登録住所確認"
                JSON.parse(response.body)[0]["contents"]["body"]["contents"][2]["contents"].each do | item |
                  expect(item["contents"][0]["text"]).not_to eq "郵便番号:"
                  expect(item["contents"][0]["text"]).not_to eq "都道府県:"
                  expect(item["contents"][0]["text"]).not_to eq "市町村区:"
                  expect(item["contents"][0]["text"]).not_to eq "丁番地及びビル番号:"
                end
              end
            end
          end
        end
      end
    end
    describe "set the client_information(by msg)" do

      context "initializing address" do# {{{
        describe "check the sets method for address_street" do

          context "予め郵便番号から自動設定されたstreetが存在しない" do
            it 'sets the address_street sent_by_user' do
              message_text = "5-13-8 フォレント池田302"
              address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ADDRESS_STREET)
              post webhook_callback_url_with_company_uuid,
                   params: create_text_message_data(message_text)
              expect(JSON.parse(
                response.body)[0]["contents"]["body"]["contents"][2]["contents"]
                .last["contents"].last["text"])
                .to eq message_text
            end
          end

          context "予め郵便番号から自動設定されたstreetが存在する" do
            it 'sets the address_street sent_by_user' do
              street_by_postal = "高田馬場"
              message_text = "5-13-8 フォレント池田302"
              line_user.set_street_by_postal_code(street_by_postal)
              address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ADDRESS_STREET)
              post webhook_callback_url_with_company_uuid,
                   params: create_text_message_data(message_text)
              expect(JSON.parse(
                response.body)[0]["contents"]["body"]["contents"][2]["contents"]
                .last["contents"].last["text"])
                .to eq street_by_postal + message_text
            end
          end
        end

        it 'sets the last_name sent by user' do
          message_text = "坂上"
          # defaultがPHASE_ASK_FOR_LASTNAMEなのでここでにset_my_address_phaseは不要
          post webhook_callback_url_with_company_uuid,
               params: create_text_message_data(message_text)
          expect(line_user.reload.last_name).to eq message_text
          expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.ask_first_name')
        end
        it 'sets the first_name sent by user' do
          message_text = "次郎"
          address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_FIRST_NAME)
          post webhook_callback_url_with_company_uuid,
               params: create_text_message_data(message_text)
          expect(line_user.reload.first_name).to eq message_text
          expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.ask_for_email')
          expect(address_phase.reload.phase).to eq AddressPhase::PHASE_ASK_FOR_EMAIL
        end
        it 'sets the email sent by user' do
          message_text = "kuroidog2000@gmail.com"
          address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_EMAIL)
          post webhook_callback_url_with_company_uuid,
               params: create_text_message_data(message_text)
          expect(line_user.reload.email).to eq message_text
          expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.ask_for_tel')
          expect(address_phase.reload.phase).to eq AddressPhase::PHASE_ASK_FOR_TEL
        end
        describe "branch by occupation" do
          let(:message_text) { "09012345678" }
          before do
            address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_TEL)
          end
          context "default" do
            it 'sets the tel sent by user and set next phase to ask_for_zip' do
              post webhook_callback_url_with_company_uuid,
                   params: create_text_message_data(message_text)
              expect(line_user.reload.tel).to eq message_text
              expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.ask_zip_code')
              expect(address_phase.reload.phase).to eq AddressPhase::PHASE_ASK_FOR_ZIP
            end
          end
          context "hotel" do
            it 'sets the tel sent by user and set next phase to ask_for_room number' do
              company.update!(occupation_mst_id: OccupationMst::HOTEL)
              post webhook_callback_url_with_company_uuid,
                   params: create_text_message_data(message_text)
              expect(line_user.reload.tel).to eq message_text
              expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.ask_room_number')
              expect(address_phase.reload.phase).to eq AddressPhase::PHASE_ASK_FOR_ROOM_NUMBER
            end
          end
          context "reserve" do
            before do
              company.update!(occupation_mst_id: OccupationMst::RESERVE)
            end
            it 'sets the first_name sent by user' do
              message_text = "次郎"
              address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_FIRST_NAME)
              post webhook_callback_url_with_company_uuid,
                   params: create_text_message_data(message_text)
              expect(line_user.reload.first_name).to eq message_text
              expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.ask_for_email_or_blank')
              expect(address_phase.reload.phase).to eq AddressPhase::PHASE_ASK_FOR_EMAIL
            end
            it 'sets the tel sent by user and set next phase to phase confirm inputed address' do
              post webhook_callback_url_with_company_uuid,
                   params: create_text_message_data(message_text)
              expect(line_user.reload.tel).to eq message_text
              expect(JSON.parse(response.body)[1]["text"]).to eq I18n.t('webhook.callback.complete_set_up')
              expect(address_phase.reload.phase).to eq AddressPhase::PHASE_CONFIRM_THE_INPUTED_ADDRESS
            end
          end
        end
        it 'sets address with zip_code' do
          message_text ="set_address&by_zip=1"
          line_user.set_zip('1710031')
          address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ADDRESS_STATE)
          post webhook_callback_url_with_company_uuid,
               params: create_post_back_event_data(message_text)
          expect(line_user.reload.address_state).to eq "東京都"
          expect(line_user.reload.address_city).to eq "豊島区"
          expect(line_user.reload.address_street_by_postal_code).to eq "目白"
          expect(address_phase.reload.phase).to eq AddressPhase::PHASE_ASK_FOR_ADDRESS_STREET
        end
        it 'sets address without zip_code' do
          message_text ="set_address&by_zip=0"
          address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ADDRESS_STATE)
          post webhook_callback_url_with_company_uuid,
               params: create_post_back_event_data(message_text)
          expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.ask_address_state')
          expect(address_phase.reload.phase).to eq AddressPhase::PHASE_ASK_FOR_ADDRESS_STATE
        end
        it 'sets address street' do
          message_text = "テスト街3-2-1"
          address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ADDRESS_STREET)
          post webhook_callback_url_with_company_uuid,
               params: create_text_message_data(message_text)
          expect(line_user.reload.address_street).to eq message_text
          expect(JSON.parse(response.body)[0]["altText"]).to eq '登録住所確認'
          expect(line_user.reload.address_set_flg).to be_truthy
        end
        it 'sets room number' do
          message_text = "305"
          address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ROOM_NUMBER)
          post webhook_callback_url_with_company_uuid,
               params: create_text_message_data(message_text)
          expect(line_user.reload.room_number).to eq message_text
          expect(JSON.parse(response.body)[0]["altText"]).to eq '登録住所確認'
          expect(line_user.reload.address_set_flg).to be_truthy
        end
        it 'returns null' do
          address_phase.delete
          message_text ="hogehoge"
          post webhook_callback_url_with_company_uuid,
               params: create_text_message_data(message_text)
          expect(response.body).to eq 'null'
        end
      end# }}}
      context "if revising address" do # {{{
        it 'revise address with zip_code' do
          message_text ="set_address&by_zip=1"
          line_user.set_zip('1560043')
          address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_ADDRESS_STATE)
          post webhook_callback_url_with_company_uuid,
               params: create_post_back_event_data(message_text)
          expect(line_user.reload.address_state).to eq "東京都"
          expect(line_user.reload.address_city).to eq "世田谷区"
          expect(line_user.reload.address_street_by_postal_code).to eq "松原"
          expect(address_phase.reload.phase).to eq AddressPhase::PHASE_REVISE_FOR_ADDRESS_STREET
        end
		    it 'revise address without zip_code' do
          message_text ="set_address&by_zip=0"
          address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_ADDRESS_STATE)
          post webhook_callback_url_with_company_uuid,
               params: create_post_back_event_data(message_text)
		      expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.response_after_set_zip')
          expect(address_phase.reload.phase).to eq AddressPhase::PHASE_CONFIRM_THE_INPUTED_ADDRESS
        end
        it 'revise the last_name sent by user' do
          message_text ="高橋"
          address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_LAST_NAME)
          post webhook_callback_url_with_company_uuid,
               params: create_text_message_data(message_text)
          expect(line_user.reload.last_name).to eq message_text
		      expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.last_name_revised')
          expect(address_phase.reload.phase).to eq AddressPhase::PHASE_CONFIRM_THE_INPUTED_ADDRESS
        end
        it 'revise the fist_name sent by user' do
          message_text ="太郎"
          address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_FIRST_NAME)
          post webhook_callback_url_with_company_uuid,
               params: create_text_message_data(message_text)
          expect(line_user.reload.first_name).to eq message_text
		      expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.first_name_revised')
          expect(address_phase.reload.phase).to eq AddressPhase::PHASE_CONFIRM_THE_INPUTED_ADDRESS
        end
        it 'revise the email sent by user' do
          message_text ="leon1999@ivy.ocn.ne.jp"
          address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_EMAIL)
          post webhook_callback_url_with_company_uuid,
               params: create_text_message_data(message_text)
          expect(line_user.reload.email).to eq message_text
		      expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.ask_for_email_revised')
          expect(address_phase.reload.phase).to eq AddressPhase::PHASE_CONFIRM_THE_INPUTED_ADDRESS
        end
        it 'revise the tel sent by user' do
          message_text ="0333245123"
          address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_TEL)
          post webhook_callback_url_with_company_uuid,
               params: create_text_message_data(message_text)
          expect(line_user.reload.tel).to eq message_text
		      expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.ask_for_tel_revised')
          expect(address_phase.reload.phase).to eq AddressPhase::PHASE_CONFIRM_THE_INPUTED_ADDRESS
        end
        it 'revise the address city sent by user' do
          message_text ="新宿区"
          address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_ADDRESS_CITY)
          post webhook_callback_url_with_company_uuid,
               params: create_text_message_data(message_text)
          expect(line_user.reload.address_city).to eq message_text
		      expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.address_city_revised')
          expect(address_phase.reload.phase).to eq AddressPhase::PHASE_CONFIRM_THE_INPUTED_ADDRESS
        end
        describe "check the revise method for address_street" do
          context "the address street by postal code is not existed" do
            it 'revise the address street sent by user' do
              message_text ="5-14-12 フォレント城田225"
              line_user.set_zip('1560043')
              address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_ADDRESS_STREET)
              post webhook_callback_url_with_company_uuid,
                   params: create_text_message_data(message_text)
              expect(line_user.reload.address_street).to eq message_text
              expect(line_user.reload.address_street_by_postal_code).to eq ""
		          expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.address_street_revised')
              expect(address_phase.reload.phase).to eq AddressPhase::PHASE_CONFIRM_THE_INPUTED_ADDRESS
            end
          end
          context "the address street by postal code is existed" do
            it 'revise the address street sent by user' do
              message_text = "5-14-12 フォレント城田225"
              street_by_postal_code = "東京都新宿区"
              line_user.set_street_by_postal_code(street_by_postal_code)
              address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_ADDRESS_STREET)
              post webhook_callback_url_with_company_uuid,
                   params: create_text_message_data(message_text)
              expect(line_user.reload.address_street).to eq street_by_postal_code + message_text
              expect(line_user.reload.address_street_by_postal_code).to eq ""
		          expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.address_street_revised')
              expect(address_phase.reload.phase).to eq AddressPhase::PHASE_CONFIRM_THE_INPUTED_ADDRESS
            end
          end
          it 'revise the room_number sent by user' do
              message_text = "503"
              address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_ROOM_NUMBER)
              post webhook_callback_url_with_company_uuid,
                   params: create_text_message_data(message_text)
              expect(line_user.reload.room_number).to eq message_text
		          expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook_utility.room_number_revised')
              expect(address_phase.reload.phase).to eq AddressPhase::PHASE_CONFIRM_THE_INPUTED_ADDRESS
          end
        end
      end# }}}
      describe "check the method for setting zip" do
        context "initial_setting for zip" do
          it 'sets zip and returns the messege that asks whehter using zip_code to set the address' do
            message_text ="1710031"
            address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ZIP)
            post webhook_callback_url_with_company_uuid,
                 params: create_text_message_data(message_text)
            expect(line_user.reload.zip).to eq message_text
		        expect(JSON.parse(response.body)[0]["altText"]).to eq "住所設定"
            expect(address_phase.reload.phase).to eq AddressPhase::PHASE_ASK_FOR_ADDRESS_STATE
          end
        end
        context "revise_setting for zip" do
          it 'revises zip and returns the messege that asks whehter using zip_code to set the address' do
            message_text ="1710031"
            address_phase.set_my_address_phase(AddressPhase::PHASE_REVISE_FOR_ZIP)
            post webhook_callback_url_with_company_uuid,
                 params: create_text_message_data(message_text)
            expect(line_user.reload.zip).to eq message_text
		        expect(JSON.parse(response.body)[0]["altText"]).to eq "住所設定"
            expect(address_phase.reload.phase).to eq AddressPhase::PHASE_REVISE_FOR_ADDRESS_STATE
          end
        end
      end
    end
  end

  describe 'acceppted message' do
    describe 'show cart products' do
      context 'occupation is reserve' do
        it 'returns products in users carts without some fees' do
          company.update(occupation_mst_id: OccupationMst::RESERVE)
          post webhook_callback_url_with_company_uuid,
               params: create_text_message_data(WebhookUtility::SHOPPING_CART)
          expect(response.body).not_to include 'クーポン利用額'
          expect(response.body).not_to include '配送料'
          expect(response.body).not_to include '手数料'
          expect(response.body).to \
            include (WebhookUtility::ASKING_RESERVE_DATE)
        end
      end
      context 'with extrafee' do
        it 'returns products in users carts' do
          post webhook_callback_url_with_company_uuid,
               params: create_text_message_data(WebhookUtility::SHOPPING_CART)
          res_text = JSON.parse(response.body)[0]["contents"]["contents"][0]["body"]["contents"][1]["text"]
          expect(res_text).to eq I18n.t('webhook_utility.show_cart_products')
        end
      end
      context 'with no extrafee' do
        let(:products_has_no_extra_fee) do
          create(:product, company: company, no_extra_fee: true)
        end
        it 'returns products in users carts but no extrafee' do
          cart.cart_products.each do |cp|
            CartProduct.del_cart_products(cp.id)
          end
          cart.add_cart(products_has_no_extra_fee.id, 1)
          post webhook_callback_url_with_company_uuid,
               params: create_text_message_data(WebhookUtility::SHOPPING_CART)
          res = JSON.parse(response.body)[0]["contents"]["contents"][0]["body"]["contents"][2]["text"]
          expect(res).to include "カート内のすべての商品の総額は税込み#{cart.reload.calc_total_products_price_in_cart_with_tax}円です。"
		      expect(res).to include "配送料:0円"
		      expect(res).to include "手数料:0円"
        end
      end
    end
    describe 'get_tags_as_category' do
      it 'returns tags for when menu pushed' do
        post webhook_callback_url_with_company_uuid,
             params: create_text_message_data(WebhookUtility::MENU)
		    expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook.callback.get_tags_as_category')
      end
    end
  end

  describe 'acceppted postback' do
    let!(:paypal_info) { create(:paypal_info, company: company) }
    let!(:line_pay_info) { create(:line_pay_info, company: company) }
    let!(:pay_pay_info) { create(:pay_pay_info, company: company) }
    let!(:cash_on_delivery_info) { create(:cash_on_delivery_info, company: company, price: 500) }
    let!(:bank_transfer_info) { create(:bank_transfer_info, company: company) }
    describe 'add products to cart from url' do
      context 'the product has size' do
        it 'add products with quantity to cart' do
          action = "add_cart&product_id=#{products_has_size.first.id}&quantity=1&size_id=#{Size::M}"
          post webhook_callback_url_with_company_uuid,
               params: create_post_back_event_data(action)
	        expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('activerecord.models.cart.add_cart')
          expect(cart.reload.cart_products.last.size).to eq Size.find(Size::M)
        end
      end
      context 'the product dose not have size' do
        it 'adds cart product and quantity' do
          action = "add_cart&product_id=#{products.first.id}&quantity=1"
          post webhook_callback_url_with_company_uuid,
               params: create_post_back_event_data(action)
	        expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('activerecord.models.cart.change_quantity')
          expect(cart.reload.cart_products.find_by(product_id: products.first).size).to eq nil
        end
      end
    end
    describe 'returns a message about paying way' do
      context "user finished address setting" do
        create_coupon
        context "coupon price less than product total price" do
          it 'creates a array for confirm_template(paying way)' do
            coupon.update(price: 1)
            cart.add_cart(coupon.id, 1)
            line_user.set_address_set_flg
            post webhook_callback_url_with_company_uuid,
                 params: create_post_back_event_data(WebhookUtility::HOW_TO_PAY)
            JSON.parse(response.body)[0]["contents"]["body"]["contents"][5]["contents"].each_with_index do |v, i|
              expect(v["text"]).to eq '代引き払い' if i == 0
              expect(v["text"]).to eq 'paypal払い' if i == 1
              expect(v["text"]).to eq 'LinePay支払い' if i == 2
              expect(v["text"]).to eq 'PayPay支払い' if i == 3
              expect(v["text"]).to eq '銀行振り込み' if i == 4
            end
            expect(JSON.parse(response.body)[0]["altText"]).to eq '登録住所確認'
          end
        end
        context "coupon price more than product total price" do
          it 'creates a array for confirm_template(paying way)' do
            coupon.update(price: 100000)
            cart.add_cart(coupon.id, 1)
            line_user.set_address_set_flg
            post webhook_callback_url_with_company_uuid,
                 params: create_post_back_event_data(WebhookUtility::HOW_TO_PAY)
            expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('.webhook.callback.price_less_than_zero')
          end
        end
        context "the lowest price has been set" do
          context "the total price is less than lowest price" do
            let!(:minimum_price) { create(:minimum_price, price: 100000, company: company) }
            it 'returns a alert messages' do
              line_user.set_address_set_flg
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(WebhookUtility::HOW_TO_PAY)
              expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('.webhook.callback.less_than_minimum_price')
            end
          end
          context "the total price is more than lowest price" do
            let!(:minimum_price) { create(:minimum_price, price: 1, company: company) }
            it 'returns a alert messages' do
              line_user.set_address_set_flg
              post webhook_callback_url_with_company_uuid,
                   params: create_post_back_event_data(WebhookUtility::HOW_TO_PAY)
              expect(JSON.parse(response.body)[0]["altText"]).to eq '登録住所確認'
            end
          end
        end
      end
      context "user dose not finish address setting" do
        it 'replys request address' do
          line_user.update!(address_set_flg: false)
          post webhook_callback_url_with_company_uuid,
               params: create_post_back_event_data(WebhookUtility::HOW_TO_PAY)
          expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('.webhook.callback.request_address')
        end
      end
    end
    describe 'returns a message asking about using paypal address' do
      it 'creates a array for confirm_template(for asking use paypal address)' do
        data = WebhookUtility::PAYING_WAY + "&way=paypal"
        line_user.update!(address_set_flg: true)
        post webhook_callback_url_with_company_uuid,
             params: create_post_back_event_data(data)
        expect(JSON.parse(response.body)[0]["template"]["text"]).to eq I18n.t('.webhook_utility.choise_using_address')
      end
    end
    describe 'returns a message with cart products template with daibiki fee' do
      it 'creates a array for cart products template with daibiki fee' do
        data = WebhookUtility::PAYING_WAY + "&way=cash_on_delivery"
        line_user.update!(address_set_flg: true)
        post webhook_callback_url_with_company_uuid,
             params: create_post_back_event_data(data)
        expect(JSON.parse(response.body)[1]["contents"]["contents"][0]["body"]["contents"][2]["text"]).to include "代引き手数料:500円"
      end
    end
    describe 'returns a message with cart products template with bank_transfer' do
      it 'creates a array for cart products template with bank_transfer' do
        data = WebhookUtility::PAYING_WAY + "&way=bank_transfer"
        line_user.update!(address_set_flg: true)
        post webhook_callback_url_with_company_uuid,
             params: create_post_back_event_data(data)
        expect(JSON.parse(response.body)[0]["text"]).to eq I18n.t('webhook.callback.show_cart_products_with_bank_transfer')
      end
    end
    describe 'for compnays occupation is reserve' do
      let!(:company_reserve) { create(:company_reserve, company: company, enable_flg: CompanyReserve::RESERVE_PETERN_A) }
      before do
        line_user.update!(address_set_flg: true)
      end
      context "has time" do
        describe 'asking reserve date' do
          it 'returns a message for asking reserve time' do
            data = WebhookUtility::ASKING_RESERVE_DATE
            post webhook_callback_url_with_company_uuid,
                 params: create_post_back_event_data(data)
            expect(response.body).to \
              include I18n.l(company_reserve.reserve_time_as.first.start_date, format: "%Y/%m/%d (%A)")
            expect(response.body).to \
              include I18n.l(company_reserve.reserve_time_as.first.end_date, format: "%Y/%m/%d (%A)")
            expect(response.body).to \
              include (WebhookUtility::ASKING_RESERVE_TIME)
          end
        end
      end
      context "has not time" do
        describe 'asking reserve date' do
          it 'returns a message about reserve order completed directly' do
            company.company_reserve.reserve_time_as.first.update!(from_time_1: nil, end_time_1: nil)
            data = WebhookUtility::ASKING_RESERVE_DATE
            post webhook_callback_url_with_company_uuid,
                 params: create_post_back_event_data(data)
            expect(response.body).to \
              include I18n.l(company_reserve.reserve_time_as.first.start_date, format: "%Y/%m/%d (%A)")
            expect(response.body).to \
              include I18n.l(company_reserve.reserve_time_as.first.end_date, format: "%Y/%m/%d (%A)")
            expect(response.body).to \
              include (WebhookUtility::CONFIRM_RESERVE_ORDER)
          end
        end
      end
      describe 'asking reserve time' do
        it 'returns a message about asking reserve time' do
          data = "#{WebhookUtility::ASKING_RESERVE_TIME}&index=0&date=#{company_reserve.reserve_time_as.first.start_date.to_s}"
          post webhook_callback_url_with_company_uuid,
               params: create_post_back_event_data(data)
          expect(response.body).to \
            include company_reserve.reserve_time_as.first.from_time_1.strftime('%R')
          expect(response.body).to \
            include company_reserve.reserve_time_as.first.end_time_1.strftime('%R')
          expect(response.body).to \
            include company_reserve.reserve_time_as.first.start_date.to_s
          # next_action
          expect(response.body).to \
            include (WebhookUtility::CONFIRM_RESERVE_ORDER)
        end
      end
      describe 'confirm about reserve order complete' do
        context "has time" do
          it 'returns a message about reserve order complete' do
            data = "#{WebhookUtility::CONFIRM_RESERVE_ORDER}&date=#{company_reserve.reserve_time_as.first.start_date.to_s}"
            data << "&from_time=#{company_reserve.reserve_time_as.first.from_time_1.to_s}"
            data << "&end_time=#{company_reserve.reserve_time_as.first.end_time_1.to_s}"
            post webhook_callback_url_with_company_uuid,
                 params: create_post_back_event_data(data)
            expect(response.body).to \
              include company_reserve.reserve_time_as.first.from_time_1.strftime('%R')
            expect(response.body).to \
              include company_reserve.reserve_time_as.first.end_time_1.strftime('%R')
            expect(response.body).to \
              include company_reserve.reserve_time_as.first.start_date.to_s
            # next_action
            expect(response.body).to \
              include (WebhookUtility::RESERVE_ORDER_COMPLETED)
            expect(response.body).to \
              include (WebhookUtility::BACK_TO_CART)
          end
        end
        context "has not time" do
          it 'returns a message about reserve order complete' do
            data = "#{WebhookUtility::CONFIRM_RESERVE_ORDER}&index=0&date=#{company_reserve.reserve_time_as.first.start_date.to_s}"
            post webhook_callback_url_with_company_uuid,
                 params: create_post_back_event_data(data)
            expect(response.body).to \
              include company_reserve.reserve_time_as.first.start_date.to_s
            expect(response.body).to \
              include (WebhookUtility::RESERVE_ORDER_COMPLETED)
            expect(response.body).to \
              include (WebhookUtility::BACK_TO_CART)
          end
        end
      end
      describe 'choose back to cart as reserve order completed' do
        it 'returns a cart' do
        company.update(occupation_mst_id: OccupationMst::RESERVE)
        data = WebhookUtility::BACK_TO_CART
        post webhook_callback_url_with_company_uuid,
             params: create_post_back_event_data(data)
        expect(response.body).not_to include 'クーポン利用額'
        expect(response.body).not_to include '配送料'
        expect(response.body).not_to include '手数料'
        expect(response.body).to \
          include (WebhookUtility::ASKING_RESERVE_DATE)
        end
      end
      describe 'asking reserve time' do
        it 'returns a message about order completed and create reserve order' do
          data = "#{WebhookUtility::RESERVE_ORDER_COMPLETED}&date=#{company_reserve.reserve_time_as.first.start_date.to_s}"
          data << "&from_time=#{company_reserve.reserve_time_as.first.from_time_1.to_s}"
          data << "&end_time=#{company_reserve.reserve_time_as.first.end_time_1.to_s}"
          post webhook_callback_url_with_company_uuid,
               params: create_post_back_event_data(data)
          expect(response.body).to \
            include company_reserve.reserve_time_as.first.start_date.to_s
          expect(response.body).to \
            include company_reserve.reserve_time_as.first.from_time_1.strftime('%R')
          expect(response.body).to \
            include company_reserve.reserve_time_as.first.end_time_1.strftime('%R')
          expect(response.body).to include I18n.t('webhook.callback.complete_take_out_order')
          expect(company.orders.last.reserve_detail).not_to eq nil
          expect(company.orders.last.reserve_detail.take_over_date).to eq company_reserve.reserve_time_as.first.start_date
          expect(company.orders.last.reserve_detail.take_over_time_from).to eq company_reserve.reserve_time_as.first.from_time_1
          expect(company.orders.last.reserve_detail.take_over_time_to).to eq company_reserve.reserve_time_as.first.end_time_1
        end
      end
    end
  end
end
