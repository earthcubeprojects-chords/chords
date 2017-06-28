require 'csv'

class Unit < ActiveRecord::Base
    has_many :vars

		validates :name, uniqueness: { case_sensitive: false }
  	validates :abbreviation, uniqueness: { case_sensitive: false }


  	def self.populate
  		csv_file = Rails.root + 'lib/assets/units.csv'
  		csv_text = File.read(csv_file)
			csv = CSV.parse(csv_text, :headers => true)
			csv.each do |row|
				fields = row.to_hash
				unit = Unit.new
				unit.name = fields["UnitsName"]
				unit.abbreviation = fields["UnitsAbbreviation"]
				unit.save
			end
  	end



end
