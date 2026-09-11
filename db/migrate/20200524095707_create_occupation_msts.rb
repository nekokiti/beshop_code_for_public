class CreateOccupationMsts < ActiveRecord::Migration[5.0]
  def change
    create_table :occupation_msts do |t|
      t.string :name

      t.timestamps
    end
  end
end
