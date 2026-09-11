class ProductsCsvExportService
require 'csv'

  def initialize(products)
    @products = products
    @csv_column_names = %w(ID 名前 クーポン 送料/手数料無料 製品コード 商品説明文 URL 価格 軽減消費税率対応 免税対応 在庫 在庫表示 オススメ タグ)
  end

  def excute
    csv_data = CSV.generate(encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
      csv << @csv_column_names
      @products.each do |product|
        csv_column_values = [
          "#{product.id}",
          "#{product.name.try(:sjisable)}",
          "#{product.coupon_flg}",
          "#{product.no_extra_fee}",
          "#{product.jancode}",
          "#{product.description.try(:sjisable)}",
          "#{product.url}",
          "#{product.price}",
          "#{product.reduction_tax}",
          "#{product.tax_free_flg}",
          "#{product.quantity}",
          "#{product.disp_inventory_flg}",
          "#{product.recommend_flg}"
        ]
        tags = ''
        product.tags.each_with_index do |tag, index|
          tags << "#{tag.tag_name.try(:sjisable)}"
          tags << '/' unless index >= product.tags.length - 1
        end
        csv_column_values.push("#{tags}")
        csv << csv_column_values
      end
    end
  end
end
