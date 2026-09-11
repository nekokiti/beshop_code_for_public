class AddMoviePathToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :movie_path, :string
  end
end
