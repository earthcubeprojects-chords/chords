class Instrument < ActiveRecord::Base
  belongs_to :site
  has_many :instruments
end
