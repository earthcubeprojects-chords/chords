class AddDoiCitationToProfile < ActiveRecord::Migration
  def change
  	add_column :profiles, :doi_citation, :text, :length => 65535
  end
end
