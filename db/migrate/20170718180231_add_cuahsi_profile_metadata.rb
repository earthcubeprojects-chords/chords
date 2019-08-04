class AddCuahsiProfileMetadata < ActiveRecord::Migration[5.1]
  def change
  	add_column :profiles, :contact_name, :string, null: false, :default => 'Contact Name'
  	add_column :profiles, :contact_phone, :string, null: false, :default => 'Contact Phone'
  	add_column :profiles, :contact_email, :string, null: false, :default => 'Contact Email'
  	add_column :profiles, :contact_address, :string, null: false, :default => 'Contact Address'
  	add_column :profiles, :contact_city, :string, null: false, :default => 'Contact City'
    add_column :profiles, :contact_state, :string, null: false, :default => 'Contact State'
    add_column :profiles, :contact_country, :string, null: false, :default => 'Contact Country'
    add_column :profiles, :contact_zipcode, :string, null: false, :default => 'Contact Zipcode'
  end
end