class AddDomainNameToProfile < ActiveRecord::Migration[5.1]
  def change
  	add_column :profiles, :domain_name, :string, null: false, :default => 'example.chordsrt.com'
  end
end
