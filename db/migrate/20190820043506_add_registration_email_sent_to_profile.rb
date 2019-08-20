class AddRegistrationEmailSentToProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :registration_email_sent, :boolean, :default => false
  end
end
