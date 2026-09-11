class ChangeReserveReference < ActiveRecord::Migration[5.0]
  def change
    remove_reference :reserve_time_as, :company, index: true, foreign_key: true
    remove_reference :reserve_time_bs, :company, index: true, foreign_key: true

    add_reference :reserve_time_as, :company_reserve, foreign_key: true
    add_reference :reserve_time_bs, :company_reserve, foreign_key: true
  end
end
