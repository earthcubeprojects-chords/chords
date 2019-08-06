class AddPageTitleToProfiles < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :page_title, :string, :length => 255, :default => "CHORDS Portal"
  end
end
