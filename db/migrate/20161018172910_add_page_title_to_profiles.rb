class AddPageTitleToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :page_title, :string, :length => 255, :default => "CHORDS Portal"
  end
end
