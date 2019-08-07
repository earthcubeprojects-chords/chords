class ChangeProfileDescriptionToText < ActiveRecord::Migration
  def change
    change_column :profiles, :description, :text
  end
end
