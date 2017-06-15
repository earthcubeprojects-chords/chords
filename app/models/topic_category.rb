class TopicCategory < ActiveRecord::Base

	validates :name, uniqueness: { case_sensitive: false }
  	validates :definition, uniqueness: { case_sensitive: false }

end
