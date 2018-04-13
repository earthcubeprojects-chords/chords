FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password 'fake_passwd'
    is_administrator false
    is_data_viewer false
    is_data_downloader false

    factory :data_viewer do
      is_data_viewer true

      factory :data_downloader do
        is_data_downloader true

        factory :admin do
          is_administrator true
        end
      end
    end
  end
end
