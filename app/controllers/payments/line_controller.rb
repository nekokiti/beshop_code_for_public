class Payments::LineController < ApplicationController
  before_action :set_confirm_url, only: %i[reserve]
  before_action :set_cart, only: %i[reserve]
  before_action :set_product_and_line_user, only: %i[reserve_by_one_to_one]

  #1対1トークの場合はこちら
  def reserve_by_one_to_one
    begin
      cart = CreateCartByChatModeService.new(
        line_user: @line_user, product: @product, size_id: @size_id
      ).execute
    rescue => e
      logger.debug(e.message)
    end
    if Rails.env.test?
      head :found
    else
      redirect_to action: :reserve, cart_hash: cart.cart_hash.to_s
    end
  end

  # 同一商品を複数個と言う概念は無いかもしれない(paypalはある)
  # 通常のカートの場合はこちら
  def reserve
    api_helper = create_api_helper_and_set_headers('/v2/payments/request',
                                                   @cart.company.line_pay_info)
    res = nil
    order = nil
    begin
      Order.transaction do
        order = Order.create_order(@cart, Order::LINE_PAY)
        api_helper.params = {
          "productName" => "#{order.company.company_name}でのお買い物",
          "amount" => order.total_price,
          "currency" => "JPY",
          "confirmUrl" => @confirm_url,
          "orderId" => order.random_order_id,
          "productImageUrl" => @cart.products.first.image_path_url(:line_pay)
        }
        res = api_helper.post
        order.update!(txn_id: res.body['info']['transactionId'])
      end
      unless Rails.env.test?
        #["app"] だとlineのurlスキームを開く
        if Product.check_inventory(@cart)
          redirect_to res.body['info']['paymentUrl']["web"]
        else
          redirect_to controller: 'payments/common',
                      action: 'inventory_error',
                      cart_hash: params[:cart_hash]
          return
        end
      else
        json = {
          'transaction_id' => order.txn_id,
          'return_message' => res.body['returnMessage']
        }
        render json: json
      end
    rescue => e
      logger.debug(e.message)
    end
  end

  def confirm
    transaction_id = params[:transactionId]
    order = Order.find_by(txn_id: transaction_id)
    api_helper = create_api_helper_and_set_headers(
      line_api_confirm_url(transaction_id),
      order.company.line_pay_info
    )
    api_helper.params = {
      "amount" => order.total_price,
      "currency" => "JPY"
    }
    res = Rails.env.test? ? api_helper.line_confirm_response_mock : api_helper.post
    if res.body['returnCode'] == "0000"
      cart_hash = order.cart.cart_hash
      # set discount manually for test
      # res.body['info']['payInfo'].push(
      #  {"method" => "DISCOUNT", "amount" => "100"}
      # )
      # Rails.logger.debug("confirm_response:#{res.inspect}")
      begin
        ActiveRecord::Base.transaction do
          res.body["info"]["payInfo"].each do |info|
            # 今のところLINEPAYクーポンは使えないと言う認識で問題ない
            order.discount = info["amount"] if info["method"] == "DISCOUNT"
            order.save!
          end
          OrderProduct.create_order_product(order, order.cart)
          Product.decrement_inventory(order.cart)
          order.verify(transaction_id)
          order.set_address_with_line_pay
          order.cart.destroy!
        end
      rescue => e
        logger.debug(e.message)
        render_500
      end
      redirect_to controller: 'payments/common', action: 'complete', cart_hash: cart_hash
    else
      logger.debug(res.body)
      #失敗したらカートは一旦消す
      order.cart.destroy
      render_500
    end
  end

  private

  def create_api_helper_and_set_headers(request_url, line_pay_info)
    proxy = ENV['FIXIE_URL']
    end_point = "https://api-pay.line.me"
    api_helper = ApiHelper.new(proxy, end_point)
    api_helper.request_uri = request_url
    api_helper.headers = {
      "Content-type" => 'application/json',
      "X-LINE-ChannelId" => line_pay_info.channel_id,
      "X-LINE-ChannelSecret" => line_pay_info.decrypt_keys
    }
    api_helper
  end

  def set_product_and_line_user
    @product = Product.find(params[:product_id])
    @line_user = LineUser.find_by(line_id: params[:line_id])
    @size_id = params[:size_id]
  end

  def set_confirm_url
    @confirm_url = "#{root_url(only_path: false)}payments/line/confirm"
  end

  def set_cart
    @cart = Cart.get_cart_by_hash(params[:cart_hash])
  end

  def line_api_confirm_url(transaction_id)
    '/v2/payments/' + transaction_id + '/confirm'
  end
end
