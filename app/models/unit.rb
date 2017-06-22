class Unit < ActiveRecord::Base
	has_many :vars
  
  	validates :name, uniqueness: { case_sensitive: false }
  	validates :abbreviation, uniqueness: { case_sensitive: false }

end
