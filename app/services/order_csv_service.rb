class OrderCsvService
PREFIX_FOR_TXN_ID = "beshop_"
require 'csv'

  def initialize(order)
    @orders = order
    @csv_column_names = %w(ID 郵便番号 住所 名前 電話番号 商品名 製品コード 単価(税込) 数量 クーポン利用額 取引合計金額 注文日時 配送業者 配送予定日 送り先番号 支払方法)
    @csv_column_names << "部屋番号" if OccupationMst.is_hotel?(company: @orders.first.company)

    if OccupationMst.is_reserve?(company: @orders.first.company)
      @csv_column_names = %w(ID 郵便番号 住所 名前 電話番号 商品名 製品コード 単価(税込) 数量 取引合計金額 注文日時 受け取り予定日 受け取り開始予定時刻 受け取り終了予定時刻)
    end
  end

  def excute
    csv_data = CSV.generate(encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
      csv << @csv_column_names
      @orders.each do |order|
        if OccupationMst.is_reserve?(company: order.company)
          csv_column_values = [
            "#{PREFIX_FOR_TXN_ID}#{order.id}",
            "#{order.zip.try(:sjisable)}",
            "#{order.address_state.try(:sjisable)}#{order.address_city.try(:sjisable)}#{order.address_street.try(:sjisable)}",
            "#{order.last_name.try(:sjisable)}#{order.first_name.try(:sjisable)}",
            "#{order.tel.try(:sjisable)}",
            "#{order.product_name.try(:sjisable)}",
            "#{order.try(:jancode)}",
            "#{order.product_price}",
            "#{order.try(:quantity)}",
            "#{order.total_price}",
            "#{order.updated_at.strftime("%Y%m%d%H%M")}",
            "#{order.take_over_date}",
            "#{order.take_over_time_from&.in_time_zone('Tokyo')&.strftime('%R')}",
            "#{order.take_over_time_to&.in_time_zone('Tokyo')&.strftime('%R')}"
          ]
        else
          next if order.coupon_flg
          csv_column_values = [
            "#{PREFIX_FOR_TXN_ID}#{order.id}",
            "#{order.zip.try(:sjisable)}",
            "#{order.address_state.try(:sjisable)}#{order.address_city.try(:sjisable)}#{order.address_street.try(:sjisable)}",
            "#{order.last_name.try(:sjisable)}#{order.first_name.try(:sjisable)}",
            "#{order.tel.try(:sjisable)}",
            "#{order.product_name.try(:sjisable)}",
            "#{order.try(:jancode)}",
            "#{order.product_price}",
            "#{order.try(:quantity)}",
            "#{order.discount}",
            "#{order.total_price}",
            "#{order.updated_at.strftime("%Y%m%d%H%M")}",
            "#{order.try(:shipping_company_name)}",
            "#{order.try(:shipping_day)&.strftime("%Y%m%d")}",
            "#{order.try(:shipping_number)}",
            "#{order.try(:payment_method)}"
          ]
          csv_column_values << "#{order.try(:room_number)}" if OccupationMst.is_hotel?(company: order.company)
        end
        csv << csv_column_values
      end
    end
  end

  private

  attr_accessor :order
end
