module PaymentUtility
  extend ActiveSupport::Concern
  def make_items_array(params)
    products = []
    products_hash = {}
    params.each do |k, v|
      if k.kind_of?(String)
        case k
        when "Name" then
          products_hash[:name] = v
        when "Number" then
          products_hash[:number] = v
        when "Quantity" then
          products_hash[:quantity] = v.to_i
        when "Amount" then
          products_hash[:amount] = v.to_i * 100
        end
        products[0] = products_hash
      #カートの商品が複数存在する
      elsif k.kind_of?(Hash)
        name = k["Name"]
        number = k["Number"]
        quantity = k["Quantity"].to_i
        amount = k["Amount"].to_i * 100
        products.push({name: name, number: number, quantity: quantity, amount: amount})
      end
    end
    return products
  end
end
