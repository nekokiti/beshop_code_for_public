module ProductsHelper
  def size_name(index)
    Size.find(index + 1).name
  end
end
