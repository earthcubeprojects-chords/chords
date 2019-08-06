class RadarDatum < ApplicationRecord
    has_one_attached :map_data
    has_one_attached :overlay_image

    #after_save :update_lat_lon

    def update_lat_lon
        if self.map_data.attached? do
            json_data = self.map_data.download
            map_json = JSON.parse(json_data)
            json_key = RadarDatum.last.update_lat_lon.keys.first
            self.origin_lat = map_json[json_key].first.first
            self.origin_lon = map_json[json_key].first.second
            self.save
        end 
    end 
end

end 

