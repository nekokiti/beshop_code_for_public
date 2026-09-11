module IpnMacros

  def paidy_webhook_api_data(cart)
    params =
    {
      payment_id: "pay_xxxxxx",
      status: "authorize_success",
      event_type: "payment",
      order_ref: cart.cart_hash,
      event_datetime: "2021-08-05 21:38:16",
      timestamp: "2021-08-05T12:38:16.220Z",
      controller: "payments/paidy",
      action: "webhook",
      paidy: {
        payment_id: "pay_YQvbrywAAFEAlMyU",
        status: "authorize_success",
        event_type: "payment",
        order_ref: cart.cart_hash,
        event_datetime: "2021-08-05 21:38:16",
        timestamp: "2021-08-05T12:38:16.220Z",
      }
    }
    return params.with_indifferent_access
  end

  def paidy_callback_api_data(cart)
    params =
    {
      callbackData: {
        amount: cart.calc_total_price_in_cart,
        created_at: "2021-08-05T12:30:10.077Z",
        currency: "JPY",
        id: "pay_test",
        status: "authorized",
      },
      cart_hash: cart.cart_hash
    }
    return params.with_indifferent_access
  end

end
