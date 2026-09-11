class AddEmailIdToPaypalInfos < ActiveRecord::Migration[5.0]
  def change
    add_column :paypal_infos, :email_id, :string
  end
end
