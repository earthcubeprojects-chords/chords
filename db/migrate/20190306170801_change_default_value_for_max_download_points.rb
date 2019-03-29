class ChangeDefaultValueForMaxDownloadPoints < ActiveRecord::Migration[5.1]
  def change
    change_column_default :profiles, :max_download_points, from: nil, to: 100000

    profile = Profile.first

    if profile && profile.max_download_points.blank?
      profile.max_download_points = 100000
      profile.save!
    end
  end
end
