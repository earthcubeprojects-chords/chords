class RemoveOldRolesColumnsOnUser < ActiveRecord::Migration[5.1]
  def up
    remove_column :users, :is_administrator, :boolean
    remove_column :users, :is_data_viewer, :boolean
    remove_column :users, :is_data_downloader, :boolean
  end

  def down
    add_column :users, :is_administrator, :boolean
    add_column :users, :is_data_viewer, :boolean
    add_column :users, :is_data_downloader, :boolean

    map_roles_mask_to_old_roles
  end

  def map_roles_mask_to_old_roles
    # [:admin :site_config :measurements :downloader :registered_user]
    User.all.each do |user|
      if user.role?(:admin)
        user.is_administrator = true
      end

      if user.role?(:registered_user)
        user.is_data_viewer = true
      end

      if user.role?(:downloader)
        user.is_data_downloader = true
      end

      begin
        user.save!
      rescue Exception, e
        Rails.logger.warn "#{user.email} roles could not be updated!"
      end
    end
  end
end
