class AddLastUrlToInstruments < ActiveRecord::Migration[5.1]
  def change
    add_column :instruments, :last_url, :string
  end
end
