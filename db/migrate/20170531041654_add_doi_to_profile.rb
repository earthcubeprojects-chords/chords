class AddDoiToProfile < ActiveRecord::Migration[5.1]
  def change
  	add_column :profiles, :doi, :text, :length => 2000
  end
end
