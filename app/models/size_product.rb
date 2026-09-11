class SizeProduct < ApplicationRecord
  default_scope { order(:size_id) }
  belongs_to :size
  belongs_to :product

  def self.releated_size(product, size)
    where(product: product, size: size).first
  end

  def self.check_quantity(product)
    # 引数で渡したサイズ有り商品の中から在庫が存在する商品IDとサイズIDの組合わせを返す
    select("product_id, size_id").where(product: product).where("quantity > ?", 0)
  end

end
