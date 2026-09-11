module Payments
  class Payments::PaypalExpressController < ApplicationController
  include PaymentUtility
  #protect_from_forgery with: :null_session
  #before_action -> {
  #  set_gateway_settings(params[:cart_hash])
  #}, only: [:new, :purchase]
  skip_before_action :verify_authenticity_token, :only => [:ipn]

    ### PayPalの支払画面に遷移するために必要な情報を取得して
    ### 支払画面にリダイレクトする
    def new# {{{
      product_arr = []
      cart = Cart.get_cart_by_hash(params[:cart_hash])
      gateway_information = PaypalInfo.new
      gateway_information.setup_gateway_information(cart.company)
      billing = gateway_information.gateway
      cart_products = cart.cart_products
      cart_products.each do |cp|
        p = cp.product
        name = p.name
        amount = p.price * 100
        # paypalマイナス値入るらしい
        amount *= -1 if p.coupon_flg
        number = p.id
        #description = p.description 長さに気を付ける
        # マイナス商品が最初に来ると何故かipnにofferが入らない
        if p.coupon_flg
          product_arr.push({ name: name,
                             amount: amount,
                             number: number,
                             quantity: CartProduct.product_quantity(
                               cart,
                               p,
                               cp.size
                             )
          })
        else
          product_arr.unshift({ name: name,
                             amount: amount,
                             number: number,
                             quantity: CartProduct.product_quantity(
                               cart,
                               p,
                               cp.size
                             )
          })
        end
      end

      subtotal = cart.calc_total_products_price_in_cart_without_tax * 100
      shipping = cart.need_extra_fee? ? cart.company.shipping.shipping_fee * 100 : 0
      handling = cart.need_extra_fee? ? cart.company.shipping.extra_fee * 100 : 0
      order_total = cart.need_extra_fee? ? cart.calc_total_price_in_cart * 100 : cart.calc_total_products_price_in_cart_with_tax * 100
      tax = cart.calc_tax * 100
      address_override = params[:use_app_address].to_i

      # 支払画面に飛ぶために必要な情報を取得する
      response = billing.setup_purchase(
        order_total,
        subtotal: subtotal,
        shipping: shipping,
        handling: handling,
        tax: tax,
        ip:                request.remote_ip,
        return_url:        payments_paypal_purchase_url, # PayPalで支払い処理後に戻るURL
        cancel_return_url: payments_paypal_cancel_url,   # PayPalでキャンセル処理後に戻るURL
        items: product_arr,
        address_override: address_override,
        address: cart.line_user.make_address_options_for_paypal(address_override)
        #address: {:name => "Bob Johnson", :zip => "90210", :address1 => "123 Fake St.", :city => "Beverly Hills", :phone => "310-123-4567", :state => "CA", :country => "US"}
        
      )

      Rails.logger.debug(response.inspect)

      # 在庫の最終チェック
      if Product.check_inventory(cart)
        # review: falseに設定するとPayPal側で「今すぐ支払う」というボタン名に変わる
        # trueにすると「同意して支払う」となる
        # ボタン文言が変わるだけでそれ以外の違いは一切ない
        redirect_to billing.redirect_url_for(response.token, review: false)
      else
        unless Rails.env.test?
          redirect_to controller: 'payments/common',
                      action: 'inventory_error',
                      cart_hash: params[:cart_hash]
          return
        end
        render head :no_content, status: :ok
      end
    end# }}}

    ### PayPalの支払画面で手続き後にアプリケーションに戻ってくるので
    ### 購入処理をする
    def purchase# {{{
      cart_hash = params[:cart_hash]
      cart = Cart.get_cart_by_hash(cart_hash)
      gateway_information = PaypalInfo.new
      gateway_information.setup_gateway_information(cart.company)
      billing = gateway_information.gateway
      # details_forで金額や支払い先などの情報が取得できるので
      # 確認画面を表示したりする時に使う
      detail = billing.details_for(params[:token])

      item_details = detail.params["PaymentDetails"]["PaymentDetailsItem"]
      products = make_items_array(item_details)

      order_total = detail.params["order_total"].to_i
      item_total = detail.params["item_total"].to_i
      tax_total = detail.params["tax_total"].to_i
      shipping_total = detail.params["shipping_total"].to_i
      handling_total = detail.params["handling_total"].to_i

      # 購入処理
      notify_url = "#{root_url(only_path: false)}payments/paypal/notify" # IPNを受け取るURL

      response = billing.purchase(
        order_total * 100,
        subtotal: item_total * 100,
        shipping: shipping_total * 100,
        handling: handling_total * 100,
        tax: tax_total * 100,
        ip:  request.remote_ip,
        token: params[:token],
        custom: cart.id,
        payer_id: params[:PayerID],
        notify_url: notify_url, # IPNを受け取るURLlocalhostだとPayPalからアクセスできないので 開発時にはngrokなどを使う
        items: products
      )

      if response.success?
        begin
          Order.transaction do
            order = Order.create_order(cart, Order::PAYPAL)
            # ここでorder_productsにsizeを設定する
            OrderProduct.create_order_product(order, order.cart)
            Product.decrement_inventory(order.cart)
            #ここでカートも削除する
            cart.destroy
          end
        rescue => e
          logger.error 'order save with cart destroy transaction failed.'
          logger.error("#{e.message}")
        end
        # payments/common#completeに飛ばす
        # redirect_to payments_common_complete_path
        redirect_to controller: 'payments/common', action: 'complete', cart_hash: cart_hash
      else
        logger.error 'purchase failed.'
        render_500
      end
    end# }}}

    def cancel; end

    # IPNを受け取ったときの処理
    def ipn# {{{
      notify = OffsitePayments::Integrations::Paypal::Notification.new(request.raw_post)
      # notify.params.each do |k, v|
        # logger.debug("#{k}==>#{v}")
      # end
      response = validate_IPN_notification(request.raw_post)
      # check whether the paymentStatus is Completed
      logger.debug("ipn_response:#{response}")
      case response
      when "VERIFIED"
        logger.debug("ipn validated")
        #notify.paramsのキーをparamsのキーにすればipnからの値を取れる
        cart_id = params['custom']
        cart = Cart.get_cart_by_id_with_deleted(cart_id)
        order = cart.order
        company = order.company
        # check that txnId has not been previously processed
        # check that receiverEmail is your Primary PayPal email
        # check that paymentAmount/paymentCurrency are correct
        if order.order_validation(ipn_params: params, order: order) \
            && company.check_email(params['receiver_email'])
          logger.debug("Throw validation")
          #status = params['payment_status']
          #address_street = params['address_street']
          if order.verify(params['txn_id'])
            order.set_address_with_paypal(params)
            order.set_total_price(params)
          else
            logger.debug("couldn't update verified flag to order")
          end
        else
          logger.debug("validation error")
        end
      when "INVALID"
        logger.debug("ipn invalid")
        # log for investigation
      else
        logger.debug("ipn errror")
        # error
      end
      head :ok
    end# }}}

   private

    def validate_IPN_notification(raw)# {{{
      uri = URI.parse(ENV['PAYPAL_IPN'])
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 60
      http.read_timeout = 60
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
      response = http.post(uri.request_uri, raw,
                           'Content-Length' => "#{raw.size}",
                           'User-Agent' => "My custom user agent"
                         ).body
    end# }}}
   end
end
