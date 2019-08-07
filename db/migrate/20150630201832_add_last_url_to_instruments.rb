class AddLastUrlToInstruments < ActiveRecord::Migration
  def change
    add_column :instruments, :last_url, :string
  end
end
