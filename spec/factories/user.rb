FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'fake_passwd' }
    roles { [:registered_user] }

    factory :data_downloader do
      roles { [:downloader, :registered_user] }
      api_key { User.generate_api_key }
    end

    factory :admin do
      roles { [:admin] }
    end

    factory :data_creator do
      roles { [:measurements] }
      api_key { User.generate_api_key }
    end

    factory :site_configurator do
      roles { [:site_config] }
    end

    factory :guest do
      roles { [:guest] }
    end
  end
end
