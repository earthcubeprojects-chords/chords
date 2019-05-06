FactoryBot.define do
  factory :var do
    name { Faker::Lorem.word }
    shortname { Faker::Lorem.word }
    instrument { Instrument.first || FactoryBot.create(:instrument) }
    measured_property { MeasuredProperty.find(MeasuredProperty.pluck(:id).shuffle.first) }
    unit { Unit.find(Unit.pluck(:id).shuffle.first) }
  end
end
