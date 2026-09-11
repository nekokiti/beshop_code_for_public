class Payments::PaypayController < ApplicationController
  before_action :set_confirm_url, only: %i[reserve]
  before_action :set_cart, only: %i[reserve]

  def reserve
    api_helper = create_api_helper_and_set_headers('/paypay')
    res = nil
    order = nil
    begin
      Order.transaction do
        order = Order.create_order(@cart, Order::PAYPAY)
        #paypayの購入画面で離脱されてもmerchantPaymentIdは常に刷新されるのでdeleteQR必要ない?
        #codeIDは持っているので、以前のqrをdeleteする事もできなくはない。
        api_helper.params = {
          #以下は当然会社ごとにDBに入れたものを使う。暗号化したままが好ましいか?
          "clientId" => @cart.company.pay_pay_info.client_id,
          "clientSecret" => @cart.company.pay_pay_info.decrypt_keys,
          "orderDescription" => "#{order.company.company_name}でのお買い物",
          "merchantId" => @cart.company.pay_pay_info.merchant_id,
          "merchantPaymentId" => order.random_order_id,
          "amount" => order.total_price,
          "redirectUrl" => "#{@confirm_url}/#{order.random_order_id}"
          # ↓ 商品画像 paypayに該当するものはあるか?
          # "productImageUrl" => @cart.products.first.image_path_url(:line_pay)
        }

        res = api_helper.post
        # paypayはcodeIdをtransaction-idとして使う
        order.update!(txn_id: res.body['data']['codeId'])
      end
      unless Rails.env.test?
        #下記がpaypayの決済url
        if Product.check_inventory(@cart)
          redirect_to res.body['data']['url']
        else
          redirect_to controller: 'payments/common',
                      action: 'inventory_error',
                      cart_hash: params[:cart_hash]
          return
        end
      else
        render json: res
      end
    rescue => e
      logger.debug(e.message)
    end
  end

  # paypayはGet Payment Detailsで決済完了を確認する。nodejsを介する
  def confirm
    random_order_id = params[:merchantPaymentId]
    order = Order.find_by(random_order_id: random_order_id)
    if order.verified
      cart_hash = Cart.get_cart_by_id_with_deleted(order.cart_id).cart_hash
      return redirect_to controller: 'payments/common', action: 'complete', cart_hash: cart_hash, skip_email: true
    end
    api_helper = create_api_helper_and_set_headers(
      '/paypay_confirm'
    )
    client_secret = order.company.pay_pay_info.decrypt_keys
    # paypayで支払い情報の問合せに必要な情報は以下
    api_helper.params = {
      "clientId" => order.company.pay_pay_info.client_id,
      "clientSecret" => client_secret,
      "merchantId" => order.company.pay_pay_info.merchant_id,
      "merchantPaymentId" => order.random_order_id
    }
    res = api_helper.post
    if Rails.env.test?
      render json: res
    else
      if res.body['code'] == "SUCCESS" && res.body['status'] == "COMPLETED"
        cart_hash = order.cart.cart_hash
        # set discount manually for test
        # res.body['info']['payInfo'].push(
        #  {"method" => "DISCOUNT", "amount" => "100"}
        # )
        # Rails.logger.debug("confirm_response:#{res.inspect}")
        begin
          ActiveRecord::Base.transaction do
            OrderProduct.create_order_product(order, order.cart)
            Product.decrement_inventory(order.cart)
            order.verify(order.txn_id)
            order.set_address_with_pay_pay
            order.cart.destroy!
          end
        rescue => e
          logger.debug(e.message)
          render_500
        end
        redirect_to controller: 'payments/common', action: 'complete', cart_hash: cart_hash
      else
        # cancelはcodeがSUCCESS以外の時のみ
        # SUCCESSであればstatusがCOMPLETED以外(FAILED等)であっても返金は必要ない
        if res.body['code'] != "SUCCESS"
          # この場合(codeがsucess以外)のみキャンセル
          # テストはミドルウェアのapiサーバー(node)から200以外を返す形にすれば良い
          api_helper = create_api_helper_and_set_headers(
            '/paypay_cancel'
          )

          # paypayで支払い情報の問合せに必要な情報は以下
          api_helper.params = {
          "clientId" => order.company.pay_pay_info.client_id,
          "clientSecret" => client_secret,
          "merchantId" => order.company.pay_pay_info.merchant_id,
          "merchantPaymentId" => order.random_order_id
          }
          res = api_helper.post
        end
        logger.debug(res.body)
        #失敗したらカートは一旦消す
        order.cart.destroy
        if Rails.env.test?
          render json: res
        else
          render_500
        end
      end
    end
  end

  private

  def create_api_helper_and_set_headers(request_url)
    # paypayは別に固定IPでなくても良いが必要ならnode-serverでセキュリティ上IPで認証するのに使える
    # proxy = ENV['FIXIE_URL']
    #paypayはnodeサーバーがend_pointになる
    proxy = nil
    # todo herokuで無料インスタンス終了に付き以下は使えなくなった。paypayは提供不可なのでこのファイル自体消て良い
    end_point = Settings.paypay_url
    api_helper = ApiHelper.new(proxy, end_point)
    api_helper.request_uri = request_url
    api_helper.headers = {
      "Content-type" => 'application/json'
    }
    api_helper
  end

  def set_product_and_line_user
    @product = Product.find(params[:product_id])
    @line_user = LineUser.find_by(line_id: params[:line_id])
    @size_id = params[:size_id]
  end

  def set_confirm_url
    @confirm_url = "#{root_url(only_path: false)}payments/paypay/confirm"
  end

  def set_cart
    @cart = Cart.get_cart_by_hash(params[:cart_hash])
  end
end
