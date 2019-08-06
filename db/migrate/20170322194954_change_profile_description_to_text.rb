class ChangeProfileDescriptionToText < ActiveRecord::Migration[5.1]
  def change
    change_column :profiles, :description, :text
  end
end
