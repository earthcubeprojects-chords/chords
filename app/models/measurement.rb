class Measurement < ActiveRecord::Base
  belongs_to :instrument


  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |measurement|
        csv << measurement.attributes.values_at(*column_names)
      end
    end
  end

end
