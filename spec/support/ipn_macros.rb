module IpnMacros
  def create_ipn(cart)
      extra_fee = cart.company.shipping.extra_fee
      shipping_fee = cart.company.shipping.shipping_fee
      params = {
        protection_eligibility: 'Eligible',
        address_status: 'confirmed',
        payer_id: '4SEWTRBLREK88',
        address_street: 'Nishi 4-chome, Kita 55-jo, Kita-ku',
        payment_date: '08:18:18 Jan 05, 2018 PST',
        payment_status: 'Completed',
        charset: 'UTF-8',
        address_zip: '150-0002',
        mc_shipping: shipping_fee,
        mc_handling: extra_fee,
        first_name: 'test',
        mc_fee: '266',
        address_country_code: 'JP',
        address_name: 'buyer test',
        notify_version: '3.8',
        custom: 'EC-9X783654WP0411619',
        payer_status: 'verified',
        business: 'k_naohiro-facilitator@byte-road.com',
        address_country: 'Japan',
        address_city: 'Shibuya-ku',
        verify_sign: 'ALmedih1HtYLznZL2PeDntdxXU2SA.b0Dkxtu0cUqMFp-ci3ZGfrfyhc',
        payer_email: 'k_naohiro-buyer@byte-road.com',
        tax1: '0',
        tax2: '0',
        txn_id: '7UA70089UY410791B',
        payment_type: 'instant',
        last_name: 'buyer',
        address_state: 'Tokyo',
        receiver_email: 'k_naohiro-facilitator@byte-road.com',
        payment_fee: '',
        receiver_id: 'FQBLZW7A3CLBN',
        txn_type: 'cart',
        mc_currency: 'JPY',
        residence_country: 'JP',
        test_ipn: '1',
        transaction_subject: '',
        payment_gross: '',
        ipn_track_id: 'a70b25e0c69bc'
      }
      mc_gross = 0
      item_count = 0
      offer_count = 0
      cart.cart_products.each_with_index do |cp|
        if cp.product.coupon_flg
          offer_count += 1
          params[("offer_amount" + (offer_count).to_s).to_sym] = cp.product.price
        else
          mc_gross += cp.product.price
          item_count += 1
          params[("mc_gross_" + (item_count).to_s).to_sym] = cp.product.price
          params[("item_number" + (item_count).to_s).to_sym] = cp.product.id
          params[("item_name" + (item_count).to_s).to_sym] = cp.product.name
          params[("quantity" + (item_count).to_s).to_sym] = CartProduct.product_quantity(cart, cp.product, cp.size)
        end
      end
      params[:num_cart_items] = item_count
      params[:num_offers] = offer_count
      params[:tax] = cart.calc_tax
      params[:mc_gross] = \
            cart.need_extra_fee? ? cart.calc_total_price_in_cart : cart.calc_total_products_price_in_cart_with_tax
      return params.with_indifferent_access
  end
end
