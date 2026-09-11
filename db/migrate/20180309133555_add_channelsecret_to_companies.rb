class AddChannelsecretToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :channel_secret, :string
  end
end
