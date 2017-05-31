class AddDoiToProfile < ActiveRecord::Migration
  def change
  	add_column :profiles, :doi, :text, :length => 2000
  end
end
