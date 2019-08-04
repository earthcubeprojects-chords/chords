class AddRolesMaskToUsers < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :roles_mask, :integer

    map_existing_roles_to_mask
  end

  def down
    remove_column :users, :roles_mask, :integer
  end

  def map_existing_roles_to_mask
    # [:admin :site_config :measurements :downloader :registered_user]
    User.all.each do |user|
      current_roles = []

      if user.is_administrator
        current_roles.concat(['admin'])
      end

      if user.is_data_viewer
        current_roles.concat(['registered_user'])
      end

      if user.is_data_downloader
        current_roles.concat(%w[downloader registered_user])
      end

      user.roles = current_roles

      begin
        user.save!
      rescue Exception, e
        Rails.logger.warn "#{user.email} roles could not be updated!"
      end
    end
  end
end
