require 'rails_helper'
require "cancan/matchers"

describe 'User' do
  describe 'abilities' do
    let!(:profile) { Profile.initialize }

    subject(:ability) { Ability.new(user) }
    let(:user){ nil }

    def allow_read_only(object)
      is_expected.not_to be_able_to(:create, object)
      is_expected.to be_able_to(:read, object)
      is_expected.not_to be_able_to(:update, object)
      is_expected.not_to be_able_to(:destroy, object)
    end

    def allow_crud(object)
      is_expected.to be_able_to(:create, object)
      is_expected.to be_able_to(:read, object)
      is_expected.to be_able_to(:update, object)
      is_expected.to be_able_to(:destroy, object)
    end

    def allow_read_update(object)
      is_expected.not_to be_able_to(:create, object)
      is_expected.to be_able_to(:read, object)
      is_expected.to be_able_to(:update, object)
      is_expected.not_to be_able_to(:destroy, object)
    end

    def no_access_allowed(object)
      is_expected.not_to be_able_to(:create, object)
      is_expected.not_to be_able_to(:read, object)
      is_expected.not_to be_able_to(:update, object)
      is_expected.not_to be_able_to(:destroy, object)
    end

  # let(:downloader) { FactoryBot.create(:data_downloader, roles: [:downloader]) }
  # let(:measurements) { FactoryBot.create(:data_creator) }
  # let(:configurator) { FactoryBot.create(:site_configurator) }
  # let(:admin) { FactoryBot.create(:admin) }
  # let(:guest) { FactoryBot.create(:guest) }
  # let(:mixed_user) { FactoryBot.create(:data_creator, roles: [:registered_user, :downloader, :measurements]) }
  # let(:admin_api) { FactoryBot.create(:data_creator, roles: [:admin, :downloader]) }
  # let(:configurator_api) { FactoryBot.create(:data_creator, roles: [:site_config, :downloader]) }

    context 'when is registered user' do
      let(:user) { FactoryBot.create(:user) }

      # Site
      it{ allow_read_only(Site) }
      it{ is_expected.to be_able_to(:map, Site) }
      it{ is_expected.to be_able_to(:map_markers_geojson, Site) }
      it{ is_expected.to be_able_to(:map_balloon_json, Site) }

      # Instrument
      it{ allow_read_only(Instrument) }

      it{ is_expected.not_to be_able_to(:duplicate, Instrument) }
      it{ is_expected.to be_able_to(:live, Instrument) }
      it{ is_expected.not_to be_able_to(:simulator, Instrument) }

      # Variable
      it{ allow_read_only(Var) }

      # Measurement Creation
      it{ is_expected.not_to be_able_to(:url_create, :measurement) }
      it{ is_expected.not_to be_able_to(:delete_test, :measurement) }

      # Profile
      it{ no_access_allowed(Profile) }
      it{ is_expected.not_to be_able_to(:export_configuration, Profile) }
      it{ is_expected.not_to be_able_to(:import_configuration, Profile) }
      it{ is_expected.not_to be_able_to(:export_influxdb, Profile) }
      it{ is_expected.not_to be_able_to(:import_influxdb, Profile) }
      it{ is_expected.not_to be_able_to(:test_sending_email, Profile) }

      # User
      it{ allow_read_update(User) }

      it 'cannot read other users' do
        user2 = FactoryBot.create(:user)

        is_expected.to be_able_to(:read, user)
        is_expected.not_to be_able_to(:read, user2)
      end

      it 'cannot update other users' do
        user2 = FactoryBot.create(:user)

        is_expected.to be_able_to(:update, user)
        is_expected.not_to be_able_to(:update, user2)
      end
    end
  end
end
