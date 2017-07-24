class AddDomainNameToProfile < ActiveRecord::Migration
  def change
  	add_column :profiles, :domain_name, :string, null: false, :default => 'portal.chordsrt.com'
  end
end
