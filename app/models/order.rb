class Order < ApplicationRecord
  require "securerandom"

  belongs_to :line_user
  #belongs_to :payer, optional: true
  belongs_to :company
  belongs_to :cart, optional: true
  has_many :order_products, dependent: :destroy
  has_one :take_over_time, dependent: :destroy
  has_one :shipping_info, dependent: :destroy
  has_one :shipping_company
  has_one :reserve_detail, dependent: :destroy
  has_one :paidy_capture, dependent: :destroy

  accepts_nested_attributes_for :shipping_info

  scope :my_orders, ->(current_company) { where(company_id: current_company, verified: true) }
  scope :order_histories, ->(line_user, company, limit) {
    where(line_user_id: line_user, company_id: company, verified: true).limit(limit).order('created_at DESC')
  }
  scope :excluded_paidy, -> { where.not(payment_method: PAIDY) }

  LINE_PAY = "line_pay"
  PAYPAL = "paypal"
  PAYPAY = "paypay"
  PAIDY = "paidy"
  TAKEOUT = "takeout"
  RESERVE = "reserve"
  CASH_ON_DELIVERY = "cash_on_delivery"
  BANK_TRANSFER = "bank_transfer"

  def display_name
    if payment_method == CASH_ON_DELIVERY
      '代引き'
    elsif payment_method == BANK_TRANSFER
      '銀行振込'
    end
  end

  def self.with_in_one_month(order_histories)
    # NOTE
    # 取り置き購入と一般購入の販売履歴が混在している時
    # 現在会社の取り置き購入フラグが立っている状態であれば1ヵ月以内の取り置きのレシートのみ返す。
    # 現在会社が一般状態であれば取り置き購入のレシートが1ヵ月以内かどうかは考慮せず混ぜて返す。
    # つまり現在取り置き購入フラグが立っている状態の場合は取り置きのレシートのみしか返さないが
    # 現在の運用状況(特定の会社のみが取り置き購入フラグのみを立てており、一般利用はしていない)
    # のでそれで構わない。
    return order_histories unless OccupationMst.is_reserve?(company: order_histories.first.company)

    order_histories.joins(:reserve_detail).merge(ReserveDetail.excluded_one_month_before).distinct
  end

  def self.create_order(cart, provider)
    order = Order.find_or_initialize_by(cart: cart)
    return order if order.verified

    order.line_user = cart.line_user
    order.cart = cart
    order.company = cart.company
    order.tax = cart.calc_tax

    # TAKEOUT / 予約販売店舗受け取り商品、及び手数料無し商品のみ注文の場合は手数料及び配送料は無い。当然合計金額もそれ等を考慮しない。
    order.total_price = cart.calc_total_products_price_in_cart_with_tax
    order.discount = cart.calc_coupon_price_in_cart

    # ただし、TAKEOUTと通販が混在していた場合(但し現在の仕様では混在不可)と
    # 通常の商品購入では当然発生する
    unless provider == TAKEOUT || provider == RESERVE
      order.mc_shipping = cart.need_extra_fee? ? cart.company.shipping.shipping_fee.to_i : 0
      order.mc_handling = cart.need_extra_fee? ? cart.company.shipping.extra_fee.to_i : 0
      order.total_price = cart.calc_total_price_in_cart if cart.need_extra_fee?
      order.total_price += order.company.cash_on_delivery_info.price if provider == CASH_ON_DELIVERY
      order.payment_method = provider
    end

    order.random_order_id = SecureRandom.uuid unless provider == PAYPAL
    order.txn_id = order.random_order_id if \
      provider == TAKEOUT ||
      provider == CASH_ON_DELIVERY ||
      provider == BANK_TRANSFER ||
      provider == RESERVE
    order.verified = false
    order.save!

    order
  end

  def order_validation(ipn_params:, order:)
    !check_ipn(ipn_params['txn_id']) && order.total_price == ipn_params['mc_gross'].to_i
  end

  def verify(txn_id)
    update!(verified: true, txn_id: txn_id)
  end

  def set_address_with_pay_pay
    set_address_with_line_pay
  end

  def set_address_with_line_pay
    zip = line_user.try(:zip)
    address_country = "JP"
    address_state = line_user.try(:address_state)
    address_city = line_user.try(:address_city)
    address_street = line_user.try(:address_street)
    first_name = line_user.try(:first_name)
    last_name = line_user.try(:last_name)
    tel = line_user.try(:tel)
    email = line_user.try(:email)
    update!(room_number: line_user.try(:room_number)) if company.occupation_mst_id == OccupationMst::HOTEL
    update!(zip: zip, address_country: address_country, address_state: address_state, address_city: address_city,
            address_street: address_street,  first_name: first_name, last_name: last_name, tel: tel)
  end

  def set_address_with_paypal(params)
    zip = params["address_zip"]
    address_country = params["address_country"]
    address_state = params["address_state"]
    address_city = params["address_city"]
    address_street = params["address_street"]
    first_name = params["first_name"]
    last_name = params["last_name"]
    email = params["payer_email"]
    shipping = params["mc_shipping"]
    handling = params["mc_handling"]
    tax = params["tax"]
    # paypalはビジネスアカウントの設定でcontact_phoneをrequireにしないとipnでcontact_phoneを送らないらしい
    tel = params["contact_phone"].nil? ? line_user.tel : params["contact_phone"]
    update!(room_number: line_user.try(:room_number)) if company.occupation_mst_id == OccupationMst::HOTEL
    update!(zip: zip, address_country: address_country, address_state: address_state, address_city: address_city,
            address_street: address_street,  first_name: first_name, last_name: last_name, email: email,
            mc_shipping: shipping, mc_handling: handling, tax: tax, tel: tel)
  end

  def set_total_price(params)
    total_price = params['mc_gross']
    update(total_price: total_price)
  end

  private

    def check_ipn(txn_id)
      Order.exists?(txn_id: txn_id)
    end
end
