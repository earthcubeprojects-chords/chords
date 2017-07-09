class InfluxdbTag < ActiveRecord::Base
  belongs_to :instrument
end
