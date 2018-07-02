FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password 'fake_passwd'
    roles [:registered_user]

    factory :data_downloader do
      roles [:downloader, :registered_user]
    end

    factory :admin do
      roles [:admin]
    end

    factory :data_creator do
      roles [:measurements]
      api_key { self.generate_api_key }
    end

    factory :site_configurator do
      roles [:site_config, :registered_user]
    end
  end
end
