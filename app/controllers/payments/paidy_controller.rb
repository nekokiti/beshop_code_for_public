class Payments::PaidyController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[webhook order_info]
  END_POINT = "https://api.paidy.com"
  STATUS_AUTHORIZED = "authorized"
  STATUS_AUTHORIZED_WEBHOOK = "authorize_success"

  def checkout() end

  def order_info
    cart_hash = params[:cart_hash]
    cart = Cart.get_cart_by_hash(cart_hash)
    user = cart.line_user
    items = []
    cart_products = cart.cart_products
    cart_products.each do |cp|
      product = cp.product
      items.push({ "id": product.id,
                   "quantity": CartProduct.product_quantity(
                               cart,
                               product,
                               cp.size
                             ),
                   "title": product.name,
                   "unit_price": (product.coupon_flg ? product.price * -1 : product.price)
      })
    end

    if cart.need_extra_fee? && cart.company.shipping.extra_fee > 0
      items.push({ "quantity": 1,
                   "title": "手数料",
                   "unit_price": cart.company.shipping.extra_fee
      })
    end

    # memo: 項目にその他の手数料等は無いが商品単価 + 税 + 送料 が ammountと同額である必要が有るため、
    # shippingに送料と手数料の合計額を入れる
    pay_load = {
      "amount": cart.need_extra_fee? ? cart.calc_total_price_in_cart : cart.calc_total_products_price_in_cart_with_tax,
      "currency": "JPY",
      "store_name": cart.company.company_name,
      "buyer": {
        "email": user.email,
        "name1": "#{user.last_name} #{user.first_name}",
        "phone": user.tel
      },
      "buyer_data": {
        "user_id": user.id,
        "age": user.age_since_account_created,
        "ltv": user.paid_total_price_excluded_paidy,
        "order_count": user.orders.count,
        "last_order_amount": user.last_order_price_excluded_paidy,
        "last_order_at": user.age_since_last_order_at_excluded_paidy
      },
      "order": {
        "items": items,
        "order_ref": cart_hash,
        "shipping": cart.need_extra_fee? ? cart.company.shipping.shipping_fee : 0,
        "tax": cart.calc_tax
      },
      "shipping_address": {
        "line1": user.address_street,
        "city": user.address_city,
        "state": user.address_state,
        "zip": (user.zip.include?('-') ? user.zip : user.zip.insert(3, '-'))
      }
    }
    render json: { status: 'SUCCESS', order_info: pay_load, public_key: cart.company.paidy_info.public_key }
  end

  def webhook
    cart = Cart.get_cart_by_hash(params["order_ref"])
    if cart.present? && authorized?(status: params["status"])
      save_order(cart, params["payment_id"])
    end
    head :ok
  end

  def callback_api
    # {"amount"=>"143", "created_at"=>"2021-07-23T09:41:48.624Z", "currency"=>"JPY", "id"=>"pay_YPqO3FQAAFwAOQVj", "status"=>"authorized"}
    paidy_callback_data = params["callbackData"]
    cart = Cart.get_cart_by_hash(params[:cart_hash])
    if cart.present? && authorized?(status: paidy_callback_data["status"])
      if save_order(cart, paidy_callback_data["id"])
        return render json: { status: 'SUCCESS' }
      else
        return render json: { status: 'OUT_OF_INVENTORY' }
      end
    else
      # todo すでに閉じていた場合はどうするか？
      Rails.logger.debug("was closed")
    end
  end

  private

  def save_order(cart, paidy_id)
    begin
      Order.transaction do
        order = Order.create_order(cart, Order::PAIDY)
        secret_key = cart.company.paidy_info.decrypt_keys
        request_uri = "/payments/#{paidy_id}"
        if Rails.env.test?
          res = ActiveSupport::OrderedOptions.new
          res.body = { "amount" => cart.calc_total_price_in_cart }
        else
          res = create_api_helper_and_set_headers(request_uri, secret_key).get
        end
        if !order.verified && res.body["amount"] == order.total_price
          if Product.check_inventory(cart)
            res = create_api_helper_and_set_headers(request_uri + "/captures", secret_key).post unless Rails.env.test?
            if res.status == 200 || Rails.env.test?
              OrderProduct.create_order_product(order, order.cart)
              Product.decrement_inventory(order.cart)
              # order.verify(res.body["captures"][0]["id"])
              order.verify(paidy_id)
              if Rails.env.test?
                PaidyCapture.create!(capture_id: 'cap_test', order: order)
              else
                PaidyCapture.create!(capture_id: res.body["captures"][0]["id"], order: order)
              end
              order.set_address_with_line_pay
            else
              logger.debug(res)
            end
            order.cart.destroy!
          else
            return false
          end
        end
      end
    rescue => e
      # todo 保存が失敗した場合の処理
      logger.debug(e.message)
    end
  end

  def authorized?(status: )
    STATUS_AUTHORIZED == status || STATUS_AUTHORIZED_WEBHOOK == status
  end

  def create_api_helper_and_set_headers(request_uri, secret_key)
    api_helper = ApiHelper.new(nil, END_POINT)
    api_helper.request_uri = request_uri
    api_helper.headers = {
      "Content-type" => 'application/json',
      "Paidy-Version" => '2018-04-10',
      "Authorization" => "Bearer #{secret_key}"
    }
    # メタデータ等が無い場合でも空が必要
    api_helper.params = {}
    api_helper
  end

end
