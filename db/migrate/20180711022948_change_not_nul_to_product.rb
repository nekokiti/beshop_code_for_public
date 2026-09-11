class ChangeNotNulToProduct < ActiveRecord::Migration[5.0]
  def up
    # downは[変更前]の定義
    # Not Null制約を外す(nullがtrue(ok))
    change_column_null :products, :url, true
    # Not Null制約をつける(nullがfalse(ng))
    change_column_null :products, :price, false
  end
  def down
    # upは[変更後]の定義
    change_column_null :products, :url, false
    change_column_null :products, :price, true
  end
end
