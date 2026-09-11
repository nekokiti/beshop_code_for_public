class  Form::OrderFindForm
  include ActiveModel::Model

  attr_accessor :created_at_from, :created_at_to

  REGISTRABLE_ATTRIBUTES = %i(
    created_at_from(1i) created_at_from(2i) created_at_from(3i)
    created_at_to(1i) created_at_to(2i) created_at_to(3i)
  )

  def self.search_order(current_company, created_at_from, created_at_to)
    Order.my_orders(current_company).where("updated_at >= ? and updated_at <= ?",
                                           created_at_from, created_at_to).order(:id)
  end

  def self.search_order_with_products(current_company, created_at_from, created_at_to)
    if OccupationMst.is_reserve?(company: current_company)
      Order.my_orders(current_company).joins(:order_products).joins(:reserve_detail).select(
        "orders.*,
        order_products.product_name,
        order_products.product_price,
        order_products.jancode,
        order_products.quantity,
        reserve_details.take_over_date,
        reserve_details.take_over_time_from,
        reserve_details.take_over_time_to
        "
      ).where(
        "orders.updated_at >= ? and orders.updated_at <= ?", created_at_from, created_at_to
      ).order(:id)
    else
      Order.my_orders(current_company).joins(:order_products).left_joins(:shipping_info => :shipping_company).select(
        "orders.*,
        order_products.product_name,
        order_products.product_price,
        order_products.jancode,
        order_products.quantity,
        order_products.coupon_flg,
        shipping_infos.shipping_day,
        shipping_infos.shipping_number,
        shipping_companies.shipping_company_name
        "
      ).where(
        "orders.updated_at >= ? and orders.updated_at <= ?", created_at_from, created_at_to
      ).order(:id)
    end
  end
end
