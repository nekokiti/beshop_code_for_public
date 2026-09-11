# 商品作成→タグ関連→カートに入れる→オーダーにする
# 処理はまとめて以下のモジュールに記載
module SampleOrderMacros
  def create_sample_order
    let(:cart) do
      Cart.create_cart(line_user, company)
    end
    let(:s_size) { Size.find(Size::S) }
    let(:m_size) { Size.find(Size::M) }
    let(:l_size) { Size.find(Size::L) }
    let!(:shipping) { create(:shipping, company: company) }
    let(:company) { create(:company) }
    let(:line_user) { create(:line_user, company: company) }
    let(:tags) do
      tags = []
      4.times do
        tags << create(:tag, company: company)
      end
      1.times do
        tags << create(:tag, company: company, url: Faker::Internet.url)
      end
      5.times do
        tags << create(:tag,
                       company: company,
                       image_path: Rack::Test::UploadedFile.new(Rails.root.join('spec/support/sample.jpg'), 'image/jpeg'))
      end
      tags
    end
    let!(:products) do
      products = []
      3.times do |x|
        res = create(:product, jancode: Faker::Lorem.characters(number: 20), company: company, tags: tags, disp_inventory_flg: true)
        CartProduct.update_cart_product(cart, res.id, 1)
        products << res
      end
      products
    end
    let!(:products_has_size) do
      products = []
      3.times do
        res = create(:product,
                      has_size: true,
                      company: company, tags: tags,
                      sizes: Size.all)

        #サイズごとの在庫を設定
        SizeProduct.releated_size(res, s_size)
                   .update_attribute(:quantity, 5)
        SizeProduct.releated_size(res, m_size)
                   .update_attribute(:quantity, 5)
        SizeProduct.releated_size(res, l_size)
                   .update_attribute(:quantity, 5)

        #サイズ有り商品はSサイズを購入
        CartProduct.update_cart_product(cart, res.id, 1, Size::S)
        products << res
      end
      products
    end
    let(:order) do
      order = Order.create_order(cart, Order::LINE_PAY)
      OrderProduct.create_order_product(order, order.cart)
      order
    end
  end
end
