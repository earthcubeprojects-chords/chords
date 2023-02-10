FactoryBot.define do
  factory :instrument do
    name { Faker::Lorem.word }
    site { Site.first || FactoryBot.create(:site) }
    display_points { rand 1..100 }
    sample_rate_seconds { [1, 5, 30, 60, 300, 900, 1800, 3600].sample }
    description { Faker::HitchhikersGuideToTheGalaxy.quote }
    plot_offset_value { rand 1..100 }
    plot_offset_units { ['hours', 'days', 'weeks'].sample }
    topic_category { TopicCategory.all.sample }
    is_active { true }
  end
end
