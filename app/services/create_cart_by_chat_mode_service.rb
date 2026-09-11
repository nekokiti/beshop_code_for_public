class CreateCartByChatModeService

  def initialize(line_user:, product:, size_id: Size::NO_SIZE)
    @line_user = line_user
    @product = product
    @size_id = size_id == Size::NO_SIZE ? nil : size_id
  end

  def execute
    ActiveRecord::Base.transaction do
      cart = Cart.create_cart(@line_user, @product.company, chat_mode: true)
      #チャットモードでも、購入ボタンを押すだけ押して買わないとアイテムが残ってしまうため、必ず追加前に削除する。
      cart.cart_products.try(:delete_all)
      cart.add_cart(@product.id, 1, @size_id)
      cart
    end
  end
end
