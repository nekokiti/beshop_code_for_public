class AddChannelaccesstokenToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :channel_access_token, :string
  end
end
