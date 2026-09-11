require 'rails_helper'
require 'json'

RSpec.describe "WebhookUtility" do
  include GetAddressUtility
  create_sample_order
  let(:address_phase) { AddressPhase.create_address_phase(line_user) }
  let(:replyToken) { 'replyToken' }
  let(:webhook_utility) { WebhookUtility.new }
  let!(:line_pay_info) { create(:line_pay_info, company: company) }
  let!(:pay_pay_info) { create(:pay_pay_info, company: company) }
  let!(:paypal_info) { create(:paypal_info, company: company) }
  let!(:paidy_info) { create(:paidy_info, company: company) }
  let!(:cash_on_delivery_info) { create(:cash_on_delivery_info, company: company, price:500) }

  before do
    webhook_utility.target_company = company
    @client = LineClient.new(company.channel_access_token)
  end

  describe 'WebhookUtility#adjust_product_quantity_flex_template' do
    context 'cart_products has not size' do
      it 'creates flex template for adjust quantity of product in cart' do
        cart_product_id = CartProduct.my_cart_product(cart, products.first).id
        res = webhook_utility.adjust_product_quantity_flex_template(
          cart_product_id
        )
        expect(res.to_s).to include Product.find(products.first.id).quantity.to_s
      end
    end
    context 'cart_products has size' do
      it 'creates flex template for adjust quantity of product in cart' do
        cart_product_id = CartProduct.my_cart_product(
          cart, products_has_size.first.id, Size::S
        ).id
        res = webhook_utility.adjust_product_quantity_flex_template(
          cart_product_id
        )
        expect(res.to_s).to include SizeProduct.releated_size(
          products_has_size.first.id, Size::S
        ).quantity.to_s
      end
    end
  end

  describe 'WebhookUtility#name_flex_template' do
    context 'default occupation' do
      it 'creates flex template for address' do
        line_user.set_zip('1710031')
        line_user.set_last_name('斉藤')
        line_user.set_first_name('三助')
        line_user.set_city('東京都豊島区目白')
        line_user.set_street('1-45-6-435')
        res = @client.reply(
          replyToken,
          webhook_utility.confirm_flex_array(line_user)
        )
        expect(res.to_s).to include line_user.zip
      end
    end
    context 'occupation is hotel' do
      let(:line_user2) { create(:line_user, company: company) }
      let(:address_phase) { AddressPhase.create_address_phase(line_user2) }
      it 'creates flex template for address' do
        company.update(occupation_mst_id: OccupationMst::HOTEL)
        line_user2.set_last_name('斉藤')
        line_user2.set_first_name('三助')
        line_user2.set_email('test@mail.com')
        line_user2.set_tel('09055555555')
        line_user2.set_room_number('350')
        line_user2.set_address_set_flg
        res = @client.reply(
          replyToken,
          webhook_utility.confirm_flex_array(line_user2)
        )
        expect(res.to_s).to include line_user2.room_number
      end
    end
  end

  describe 'WebhookUtility#confirm_array' do
    context '郵便番号による住所検索を行うかを確認' do
      it 'creates confirm template and asks whether using zip for address' do
        address_phase.set_my_address_phase(AddressPhase::PHASE_ASK_FOR_ZIP)
        webhook_utility.confirm_actions_for_using_zip_to_set_address(
          address_phase
        )
        res = @client.reply(replyToken, webhook_utility.confirm_array)
        expect(res.to_s).to include I18n.t('webhook_utility.ask_using_zip_code_for_address')
      end
    end
    context '支払い方法を確認' do
      it 'creates confirm template and asks about paying way' do
        webhook_utility.asking_paying_way(line_user)
        res = @client.reply(replyToken, webhook_utility.buttons_array)
        expect(res.to_s).to include I18n.t('webhook_utility.choise_the_paying_way')
        expect(res.to_s).to include 'paypal払い'
        expect(res.to_s).to include 'PayPay支払い'
        expect(res.to_s).to include 'LinePay支払い'
        expect(res.to_s).to include 'あと払い (ペイディ)'
      end
    end
    context 'PAYPAL支払いを選択した場合' do
      it 'creates confirm_template to ask using registered address on paypal' do
        webhook_utility.buy_paypal(line_user)
        res = @client.reply(replyToken, webhook_utility.confirm_array)
        expect(res.to_s).to include I18n.t('webhook_utility.choise_using_address')
      end
    end
  end

  describe 'WebhookUtility#reply_image' do
    it 'replies image template' do
      webhook_utility.reply_image
      res = @client.reply(replyToken, webhook_utility.messages)
      expect(res.to_s).to include "image"
    end
    it 'replies template with image with messages' do
      webhook_utility.messages_items_array << 'hogehoge'
      webhook_utility.messages_items_array << 'hugahuga'
      webhook_utility.messages_array
      webhook_utility.reply_image
      res = @client.reply(replyToken, webhook_utility.messages)
      expect(res.to_s).to include "image"
      expect(res.to_s).to include "hogehoge"
      expect(res.to_s).to include "hugahuga"
    end
  end

  describe 'WebhookUtility#products_flex_template' do
    before do
      products.each do |p|
        p.update_attribute(:recommend_flg, true)
      end
      products_has_size.each do |p|
        p.update_attribute(:recommend_flg, true)
      end
    end
    context 'タグに紐づくその他の商品がこれ以上存在しない場合' do
      it 'creates flex template for recommended product' do
        gotten_products = Product.get_recommend_products(
          0,
          webhook_utility.target_company
        )
        res = @client.reply(
          replyToken,
          webhook_utility.products_flex_template(
            gotten_products
          )
        )
        expect(res.to_s).to include products_has_size.first.name
        expect(res.to_s).not_to include I18n.t('webhook_utility.show_other_products')
      end
    end
    context 'タグに紐づくその他の商品がまだ存在する場合' do
      it 'creates flex template for recommended product' do
        5.times do
          create(:product, company: company, tags: tags, recommend_flg: true)
        end
        gotten_products = Product.get_recommend_products(
          0,
          webhook_utility.target_company
        )
        res = @client.reply(
          replyToken,
          webhook_utility.products_flex_template(
            gotten_products
          )
        )
        expect(res.to_s).to include "商品一覧"
        expect(res.to_s).to include I18n.t('webhook_utility.show_other_products')
      end
    end
  end

  describe 'WebhookUtility#products_flex_template' do
    context 'タグに紐づくその他の商品がこれ以上存在しない場合' do
      it 'creates flex template for product and does not have show other product' do
        gotten_products = Product.get_products_by_tag(tags[0], 0, company)
        res = @client.reply(
          replyToken,
          webhook_utility.products_flex_template(
            gotten_products, tags[0].id.to_s
          )
        )
        expect(res.to_s).to include "商品一覧"
        expect(res.to_s).not_to include I18n.t('webhook_utility.show_other_products')
      end
    end
    context 'タグに紐づくその他の商品がまだ存在する場合' do
      it 'creates flex template for product and has show other product' do
        5.times do
          create(:product, company: company, tags: tags)
        end
        gotten_products = Product.get_products_by_tag(tags[0], 0, company)
        res = @client.reply(
          replyToken,
          webhook_utility.products_flex_template(
            gotten_products, tags[0].id.to_s
          )
        )
        expect(res.to_s).to include "商品一覧"
        expect(res.to_s).to include I18n.t('webhook_utility.show_other_products')
      end
    end
  end

  describe 'WebhookUtility#show_receipt' do
    let(:order_histories) do
      Order.order_histories(line_user,
                            company,
                            WebhookController::RECEIPT_MAX_NUMS)
    end
    before do
      order.update!(verified: true)
      order.update!(txn_id: 'txnid12345')
    end
    context "occupation is default" do
      it 'creats flex template for receipt' do
        res = @client.reply(
          replyToken, webhook_utility.show_receipt(order_histories)
        )
        expect(res.to_s).to include "レシート"
        expect(res.to_s).to include "送料"
        expect(res.to_s).to include "手数料"
        expect(res.to_s).to include "クーポン利用額"
        expect(res.to_s).to include order.txn_id
      end
    end
    context "occupation is reserve" do
      context "the reserve time is within one month" do
        it 'creates flex template for receipt but not include shipping fee' do
          company.update!(occupation_mst_id: OccupationMst::RESERVE)
          reserve_times = [Time.current.strftime("%Y-%m-%d"), '09:00', '21:00']
          ReserveDetail.upsert(cart, order, reserve_times)
          res = @client.reply(
            replyToken, webhook_utility.show_receipt(order_histories)
          )
          expect(res.to_s).to include "レシート"
          expect(res.to_s).to include "お受け取り予定日"
          expect(res.to_s).to include "お受け取り予定時間"
          expect(res.to_s).not_to include "送料"
          expect(res.to_s).not_to include "手数料"
          expect(res.to_s).not_to include "クーポン利用額"
          expect(res.to_s).not_to include order.txn_id
          expect(res.to_s).to include order.id.to_s
        end
      end
      context "the reserve time is before than one month" do
        it 'dose not create receipt' do
          company.update!(occupation_mst_id: OccupationMst::RESERVE)
          reserve_times = [Time.current.ago(1.month).strftime("%Y-%m-%d"), '09:00', '21:00']
          ReserveDetail.upsert(cart, order, reserve_times)
          res = @client.reply(
            replyToken, webhook_utility.show_receipt(order_histories)
          )
          expect(res.first[:contents][:contents]).to eq []
        end
      end
    end
    context "mixture reserve order and normal order" do
      let(:order_2) do
        cart.destroy!
        cart_2 = Cart.create_cart(line_user, company)
        CartProduct.update_cart_product(cart_2, products.first.id, 1)
        order_2 = Order.create_order(cart_2, Order::LINE_PAY)
        OrderProduct.create_order_product(order_2, order_2.cart)
        order_2
      end
      it 'creats flex template of receipt that has reserve and normal' do
        reserve_times = [Time.current.strftime("%Y-%m-%d"), '09:00', '21:00']
        ReserveDetail.upsert(cart, order, reserve_times)
        order_2.update!(verified: true)
        res = @client.reply(
          replyToken, webhook_utility.show_receipt(order_histories)
        )
        expect(res.to_s).to include "レシート"
        expect(res.to_s).to include "お受け取り予定日"
        expect(res.to_s).to include "お受け取り予定時間"
        expect(res.to_s).to include "送料"
        expect(res.to_s).to include "手数料"
        expect(res.to_s).to include "クーポン利用額"
      end
    end
  end

  describe 'WebhookUtility#show_cart_products' do

    context 'take out product is in cart and action is ASKING_TIME' do
      it 'creats flex template for cart' do
        # テスト様にここはお取り置きフラグを全てtrueにしてしまう。
        cart.products.each do |p|
          p.update!(otorioki_flg: true)
        end
        res = @client.reply(replyToken, webhook_utility.show_cart_products(cart))
        expect(
          res[0][:contents][:contents][0][:footer][:contents][1][:action][:data]
        ).to eq "action=#{WebhookUtility::ASKING_TIME}"
        expect(res.to_s).to include "カートの中の商品"
      end
    end

    context 'take out product is not in cart' do
      it 'creats flex template for cart and action is HOW_TO_PAY' do
        time = '2017-12-25t21:30'
        TakeOverTime.create_take_over_time(time, cart)
        res = @client.reply(replyToken, webhook_utility.show_cart_products(cart))
        expect(
          res[0][:contents][:contents][0][:footer][:contents][1][:action][:data]
        ).to eq "action=#{WebhookUtility::HOW_TO_PAY}"
        expect(res.to_s).to include "カートの中の商品"
      end
    end
  end

  describe 'WebhookUtility#get_tags_as_category' do
    context 'the tags is less than 50' do
      it 'creates flex template for tag without next button' do
        tags = Tag.getMyTags(company, 0)
        res = @client.reply(
          replyToken, webhook_utility.get_tags_as_category(tags)
        )
        expect(res.to_s).to include tags.first.tag_name
        expect(res.to_s).to include "sample.jpg"
        expect(res.to_s).not_to include I18n.t('webhook_utility.more')
      end
    end
    context 'the tags is more than 50' do
      it 'creates flex template for tag with next button' do
        more_tags = []
        50.times do
          more_tags << create(:tag, company: company)
        end
        create(:product, company: company, tags: more_tags)
        tags = Tag.getMyTags(company, 0)
        res = @client.reply(
          replyToken, webhook_utility.get_tags_as_category(tags)
        )
        expect(res.to_s).to include I18n.t('webhook_utility.more')
      end
    end
  end

  describe 'Destroy Carts Product' do
    it 'delets cart product' do
      sample_cart_product = cart.cart_products.first
      data =
        'action=' +
        WebhookUtility::REMOVE +
        '&cart_product_id=' +
        sample_cart_product.id.to_s
      webhook_utility.get_data_from_post_back(data)
      cart_product_id = webhook_utility.result['cart_product_id']
      webhook_utility.messages_items_array \
        << CartProduct.del_cart_products(cart_product_id)
      res = @client.reply(replyToken, webhook_utility.messages_items_array)
      expect(cart.reload.cart_products).not_to include sample_cart_product
      expect(webhook_utility.messages_items_array[0]).to eq \
        CartProduct::DESTROY_CART_PRODUCT_MSG
      expect(res.to_s).to include "商品を削除しました"
    end
  end

  describe 'ask address' do
    it 'asks lastname' do
      webhook_utility.set_msg_by_address_phase_from_rich_menu(address_phase)
      res = @client.reply(replyToken, webhook_utility.messages_array)
      expect(res[0]['text']).to include webhook_utility.messages_items_array[0]
    end
    it 'sets address by messages' do
      webhook_utility.input_text = '豊島区'
      line_user.set_city(webhook_utility.input_text)
      webhook_utility.messages_items_array \
        << I18n.t('webhook_utility.ask_address_street')
      res = @client.reply(replyToken, webhook_utility.messages_array)
      expect(line_user.address_city).to eq webhook_utility.input_text
      expect(res[0]['text']).to \
        include webhook_utility.messages_items_array[0]
    end
    it 'sets address by post code' do
      line_user.set_address_with_hash(get_address('1710031'))
      webhook_utility.messages_items_array \
        << I18n.t('webhook_utility.response_of_setaddress_with_zip') \
        + ':' \
        + line_user.address_state
      webhook_utility.messages_items_array \
        << I18n.t('webhook_utility.ask_address_street')
      res = @client.reply(replyToken, webhook_utility.messages_array)
      expect(line_user.address_street_by_postal_code).to eq '目白'
      expect(res[0]['text']).to \
        include webhook_utility.messages_items_array[0]
    end
  end

  describe 'WebhookUtility::revise_address' do
    it 'creates flex template with address items to revise address' do
      webhook_utility.revise_address
      res = @client.reply(replyToken, webhook_utility.quick_reply_array)
      expect(res[0][:text]).to \
        eq webhook_utility.quick_reply_text_array[0]
    end
  end

  describe 'is_zip_code?' do
    context do "zip is valid"
      it "checks is arg zip?" do
        zip_code = '1710031'
        zip_code_hyphen = '171-0031'
        res = WebhookUtility.is_zip_code?(zip_code)
        res2 = WebhookUtility.is_zip_code?(zip_code_hyphen)
        expect(res.first).to eq zip_code
        expect(res2.first).to eq zip_code_hyphen
      end
    end
    context do "zip is invalid"
      it "returns array with null" do
        zip_code = '171123456'
        zip_code_character = '171あいうえお'
        res = WebhookUtility.is_zip_code?(zip_code)
        res2 = WebhookUtility.is_zip_code?(zip_code_character)
        expect(res.first).to eq nil
        expect(res2.first).to eq nil
      end
    end
  end
  describe 'get_data_from_post_back' do
    it "create paroperly hash" do
      webhook_utility.get_data_from_post_back("action=add_cart&product_id=5&quantity=1")
      expected_hash = { "action" => "add_cart", "product_id" => "5", "quantity" => "1" }
      expect(webhook_utility.result).to eq expected_hash
    end
  end
  describe 'products_flex_template_with_chat_mode' do
    context "the product has no size" do
      it "create paroperly hash" do
        res = webhook_utility.products_flex_template_with_chat_mode(
          Product.my_products(company).where(
            id: products.first.id
          ),
          line_user
        )
        expect(res.to_s).to include "購入(LINE PAY)"
      end
    end
    context "the product has size" do
      it "create paroperly hash" do
        p_with_s = products_has_size.first
        res = webhook_utility.products_flex_template_with_chat_mode(
          Product.my_products(company).where(
            id: p_with_s.id
          ),
          line_user
        )
        SizeProduct.check_quantity(p_with_s).each do |sp|
          expect(res.to_s).to include "#{sp.size.name}購入(LINE PAY)"
        end
      end
    end
  end
end
