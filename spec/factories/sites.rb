FactoryBot.define do
  factory :site do
    name { Faker::OnePiece.location }
    lat { Faker::Address.latitude }
    lon { Faker::Address.longitude }
    description { Faker::HitchhikersGuideToTheGalaxy.quote }
    elevation { rand 0..10000 }
  end
end
