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
      it{ is_expected.not_to be_able_to(:create, :measurement) }
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
      it{ is_expected.to be_able_to(:assign_api_key, user) }

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

      # About
      it{ is_expected.to be_able_to(:read, :about) }

      # Dashboard
      it{ is_expected.to be_able_to(:read, :dashboard) }

      # Data Download
      it{ is_expected.not_to be_able_to(:read, :data) }
      it{ is_expected.not_to be_able_to(:download, Instrument) }

      # Influxdb Tag
      it{ allow_read_only(InfluxdbTag) }

      # Linked Data
      it{ no_access_allowed(LinkedDatum) }

      # Measured Property
      it{ allow_read_only(MeasuredProperty) }

      # Site Type
      it{ allow_read_only(SiteType) }

      # Topic Category
      it{ allow_read_only(TopicCategory) }

      # Unit
      it{ allow_read_only(Unit) }
    end

    context 'when is only a downloader and secure viewing and downloading enabled' do
      let(:user) { FactoryBot.create(:data_downloader, roles: [:downloader]) }

      before do
        profile = Profile.first || Profile.initialize.first
        profile.secure_data_download = true
        profile.secure_data_viewing = true
        profile.save!
      end

      # Site
      it{ no_access_allowed(Site) }
      it{ is_expected.not_to be_able_to(:map, Site) }
      it{ is_expected.not_to be_able_to(:map_markers_geojson, Site) }
      it{ is_expected.not_to be_able_to(:map_balloon_json, Site) }

      # Instrument
      it{ no_access_allowed(Instrument) }

      it{ is_expected.not_to be_able_to(:duplicate, Instrument) }
      it{ is_expected.not_to be_able_to(:live, Instrument) }
      it{ is_expected.not_to be_able_to(:simulator, Instrument) }

      # Variable
      it{ no_access_allowed(Var) }

      # Measurement Creation
      it{ is_expected.not_to be_able_to(:create, :measurement) }
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
      it{ is_expected.to be_able_to(:assign_api_key, user) }

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

      # About
      it{ is_expected.to be_able_to(:read, :about) }

      # Dashboard
      it{ is_expected.not_to be_able_to(:read, :dashboard) }

      # Data Download
      it{ is_expected.to be_able_to(:read, :data) }
      it{ is_expected.to be_able_to(:download, Instrument) }

      # Influxdb Tag
      it{ no_access_allowed(InfluxdbTag) }

      # Linked Data
      it{ no_access_allowed(LinkedDatum) }

      # Measured Property
      it{ no_access_allowed(MeasuredProperty) }

      # Site Type
      it{ no_access_allowed(SiteType) }

      # Topic Category
      it{ no_access_allowed(TopicCategory) }

      # Unit
      it{ no_access_allowed(Unit) }
    end

    context 'when is only a downloader and secure viewing and downloading disabled' do
      let(:user) { FactoryBot.create(:data_downloader, roles: [:downloader]) }

      before do
        profile = Profile.first || Profile.initialize.first
        profile.secure_data_download = false
        profile.secure_data_viewing = false
        profile.save!
      end

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
      it{ is_expected.not_to be_able_to(:create, :measurement) }
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
      it{ is_expected.to be_able_to(:assign_api_key, user) }

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

      # About
      it{ is_expected.to be_able_to(:read, :about) }

      # Dashboard
      it{ is_expected.to be_able_to(:read, :dashboard) }

      # Data Download
      it{ is_expected.to be_able_to(:read, :data) }
      it{ is_expected.to be_able_to(:download, Instrument) }

      # Influxdb Tag
      it{ allow_read_only(InfluxdbTag) }

      # Linked Data
      it{ no_access_allowed(LinkedDatum) }

      # Measured Property
      it{ allow_read_only(MeasuredProperty) }

      # Site Type
      it{ allow_read_only(SiteType) }

      # Topic Category
      it{ allow_read_only(TopicCategory) }

      # Unit
      it{ allow_read_only(Unit) }
    end

    context 'when is only a measurement creator and secure viewing and downloading enabled' do
      let(:user) { FactoryBot.create(:data_creator) }

      before do
        profile = Profile.first || Profile.initialize
        profile.secure_data_viewing = true
        profile.save!
      end

      # Site
      it{ no_access_allowed(Site) }
      it{ is_expected.not_to be_able_to(:map, Site) }
      it{ is_expected.not_to be_able_to(:map_markers_geojson, Site) }
      it{ is_expected.not_to be_able_to(:map_balloon_json, Site) }

      # Instrument
      it{ no_access_allowed(Instrument) }

      it{ is_expected.not_to be_able_to(:duplicate, Instrument) }
      it{ is_expected.not_to be_able_to(:live, Instrument) }
      it{ is_expected.to be_able_to(:simulator, Instrument) }

      # Variable
      it{ no_access_allowed(Var) }

      # Measurement Creation
      it{ is_expected.to be_able_to(:create, :measurement) }
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
      it{ is_expected.not_to be_able_to(:assign_api_key, user) }

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

      # About
      it{ is_expected.to be_able_to(:read, :about) }

      # Dashboard
      it{ is_expected.not_to be_able_to(:read, :dashboard) }

      # Data Download
      it{ is_expected.not_to be_able_to(:read, :data) }
      it{ is_expected.not_to be_able_to(:download, Instrument) }

      # Influxdb Tag
      it{ no_access_allowed(InfluxdbTag) }

      # Linked Data
      it{ no_access_allowed(LinkedDatum) }

      # Measured Property
      it{ no_access_allowed(MeasuredProperty) }

      # Site Type
      it{ no_access_allowed(SiteType) }

      # Topic Category
      it{ no_access_allowed(TopicCategory) }

      # Unit
      it{ no_access_allowed(Unit) }
    end

    context 'when is only a measurement creator and secure viewing and downloading disabled' do
      let(:user) { FactoryBot.create(:data_creator) }

      before do
        profile = Profile.first || Profile.initialize.first
        profile.secure_data_download = false
        profile.secure_data_viewing = false
        profile.save!
      end

      # Site
      it{ allow_read_only(Site) }
      it{ is_expected.to be_able_to(:map, Site) }
      it{ is_expected.to be_able_to(:map_markers_geojson, Site) }
      it{ is_expected.to be_able_to(:map_balloon_json, Site) }

      # Instrument
      it{ allow_read_only(Instrument) }

      it{ is_expected.not_to be_able_to(:duplicate, Instrument) }
      it{ is_expected.to be_able_to(:live, Instrument) }
      it{ is_expected.to be_able_to(:simulator, Instrument) }

      # Variable
      it{ allow_read_only(Var) }

      # Measurement Creation
      it{ is_expected.to be_able_to(:create, :measurement) }
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
      it{ is_expected.to be_able_to(:assign_api_key, user) }

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

      # About
      it{ is_expected.to be_able_to(:read, :about) }

      # Dashboard
      it{ is_expected.to be_able_to(:read, :dashboard) }

      # Data Download
      it{ is_expected.to be_able_to(:read, :data) }
      it{ is_expected.to be_able_to(:download, Instrument) }

      # Influxdb Tag
      it{ allow_read_only(InfluxdbTag) }

      # Linked Data
      it{ no_access_allowed(LinkedDatum) }

      # Measured Property
      it{ allow_read_only(MeasuredProperty) }

      # Site Type
      it{ allow_read_only(SiteType) }

      # Topic Category
      it{ allow_read_only(TopicCategory) }

      # Unit
      it{ allow_read_only(Unit) }
    end

    context 'when is a site configurator' do
      let(:user) { FactoryBot.create(:site_configurator) }

      # Site
      it{ allow_crud(Site) }
      it{ is_expected.to be_able_to(:map, Site) }
      it{ is_expected.to be_able_to(:map_markers_geojson, Site) }
      it{ is_expected.to be_able_to(:map_balloon_json, Site) }

      # Instrument
      it{ allow_crud(Instrument) }

      it{ is_expected.to be_able_to(:duplicate, Instrument) }
      it{ is_expected.to be_able_to(:live, Instrument) }
      it{ is_expected.to be_able_to(:simulator, Instrument) }

      # Variable
      it{ allow_crud(Var) }

      # Measurement Creation
      it{ is_expected.not_to be_able_to(:create, :measurement) }
      it{ is_expected.to be_able_to(:delete_test, :measurement) }

      # Profile
      it{ allow_crud(Profile) }
      it{ is_expected.to be_able_to(:export_configuration, Profile) }
      it{ is_expected.to be_able_to(:import_configuration, Profile) }
      it{ is_expected.to be_able_to(:export_influxdb, Profile) }
      it{ is_expected.to be_able_to(:import_influxdb, Profile) }
      it{ is_expected.to be_able_to(:test_sending_email, Profile) }

      # User
      it{ allow_read_update(User) }
      it{ is_expected.to be_able_to(:assign_api_key, user) }

      it 'can read other users' do
        user2 = FactoryBot.create(:user)

        is_expected.to be_able_to(:read, user)
        is_expected.to be_able_to(:read, user2)
      end

      it 'cannot update other users' do
        user2 = FactoryBot.create(:user)

        is_expected.to be_able_to(:update, user)
        is_expected.not_to be_able_to(:update, user2)
      end

      # About
      it{ is_expected.to be_able_to(:read, :about) }

      # Dashboard
      it{ is_expected.to be_able_to(:read, :dashboard) }

      # Data Download
      it{ is_expected.to be_able_to(:read, :data) }
      it{ is_expected.to be_able_to(:download, Instrument) }

      # Influxdb Tag
      it{ allow_crud(InfluxdbTag) }

      # Linked Data
      it{ allow_crud(LinkedDatum) }

      # Measured Property
      it{ allow_crud(MeasuredProperty) }

      # Site Type
      it{ allow_crud(SiteType) }

      # Topic Category
      it{ allow_crud(TopicCategory) }

      # Unit
      it{ allow_crud(Unit) }
    end

    context 'when is an admin' do
      let(:user) { FactoryBot.create(:admin) }

      # Site
      it{ is_expected.to be_able_to(:manage, Site) }

      # Instrument
      it{ is_expected.to be_able_to(:manage, Instrument) }

      # Variable
      it{ is_expected.to be_able_to(:manage, Var) }

      # Measurement Creation
      it{ is_expected.not_to be_able_to(:create, :measurement) }
      it{ is_expected.to be_able_to(:delete_test, :measurement) }

      # Profile
      it{ is_expected.to be_able_to(:manage, Profile) }

      # User
      it{ is_expected.to be_able_to(:manage, User) }

      it 'cannot destroy self' do
        user2 = FactoryBot.create(:user)

        is_expected.not_to be_able_to(:destroy, user)
        is_expected.to be_able_to(:destroy, user2)
      end

      # About
      it{ is_expected.to be_able_to(:read, :about) }

      # Dashboard
      it{ is_expected.to be_able_to(:read, :dashboard) }

      # Data Download
      it{ is_expected.to be_able_to(:read, :data) }
      it{ is_expected.to be_able_to(:download, Instrument) }

      # Influxdb Tag
      it{ is_expected.to be_able_to(:manage, InfluxdbTag) }

      # Linked Data
      it{ is_expected.to be_able_to(:manage, LinkedDatum) }

      # Measured Property
      it{ is_expected.to be_able_to(:manage, MeasuredProperty) }

      # Site Type
      it{ is_expected.to be_able_to(:manage, SiteType) }

      # Topic Category
      it{ is_expected.to be_able_to(:manage, TopicCategory) }

      # Unit
      it{ is_expected.to be_able_to(:manage, Unit) }
    end

    context 'when is guest and secure download/view enabled' do
      let(:user) { FactoryBot.create(:guest) }

      before do
        profile = Profile.first || Profile.initialize.first
        profile.secure_data_download = true
        profile.secure_data_viewing = true
        profile.save!
      end

      # Site
      it{ no_access_allowed(Site) }
      it{ is_expected.not_to be_able_to(:map, Site) }
      it{ is_expected.not_to be_able_to(:map_markers_geojson, Site) }
      it{ is_expected.not_to be_able_to(:map_balloon_json, Site) }

      # Instrument
      it{ no_access_allowed(Instrument) }

      it{ is_expected.not_to be_able_to(:duplicate, Instrument) }
      it{ is_expected.not_to be_able_to(:live, Instrument) }
      it{ is_expected.not_to be_able_to(:simulator, Instrument) }

      # Variable
      it{ no_access_allowed(Var) }

      # Measurement Creation
      it{ is_expected.not_to be_able_to(:create, :measurement) }
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
      it{ is_expected.not_to be_able_to(:assign_api_key, user) }

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

      # About
      it{ is_expected.to be_able_to(:read, :about) }

      # Dashboard
      it{ is_expected.not_to be_able_to(:read, :dashboard) }

      # Data Download
      it{ is_expected.not_to be_able_to(:read, :data) }
      it{ is_expected.not_to be_able_to(:download, Instrument) }

      # Influxdb Tag
      it{ no_access_allowed(InfluxdbTag) }

      # Linked Data
      it{ no_access_allowed(LinkedDatum) }

      # Measured Property
      it{ no_access_allowed(MeasuredProperty) }

      # Site Type
      it{ no_access_allowed(SiteType) }

      # Topic Category
      it{ no_access_allowed(TopicCategory) }

      # Unit
      it{ no_access_allowed(Unit) }
    end

    context 'when is guest and secure download enabled / secure view disabled' do
      let(:user) { FactoryBot.create(:guest) }

      before do
        profile = Profile.first || Profile.initialize.first
        profile.secure_data_download = true
        profile.secure_data_viewing = false
        profile.save!
      end

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
      it{ is_expected.not_to be_able_to(:create, :measurement) }
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
      it{ is_expected.to be_able_to(:assign_api_key, user) }

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

      # About
      it{ is_expected.to be_able_to(:read, :about) }

      # Dashboard
      it{ is_expected.to be_able_to(:read, :dashboard) }

      # Data Download
      it{ is_expected.not_to be_able_to(:read, :data) }
      it{ is_expected.not_to be_able_to(:download, Instrument) }

      # Influxdb Tag
      it{ allow_read_only(InfluxdbTag) }

      # Linked Data
      it{ no_access_allowed(LinkedDatum) }

      # Measured Property
      it{ allow_read_only(MeasuredProperty) }

      # Site Type
      it{ allow_read_only(SiteType) }

      # Topic Category
      it{ allow_read_only(TopicCategory) }

      # Unit
      it{ allow_read_only(Unit) }
    end

    context 'when is guest and secure download disabled / secure view disabled' do
      let(:user) { FactoryBot.create(:guest) }

      before do
        profile = Profile.first || Profile.initialize.first
        profile.secure_data_download = false
        profile.secure_data_viewing = false
        profile.save!
      end

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
      it{ is_expected.not_to be_able_to(:create, :measurement) }
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
      it{ is_expected.to be_able_to(:assign_api_key, user) }

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

      # About
      it{ is_expected.to be_able_to(:read, :about) }

      # Dashboard
      it{ is_expected.to be_able_to(:read, :dashboard) }

      # Data Download
      it{ is_expected.to be_able_to(:read, :data) }
      it{ is_expected.to be_able_to(:download, Instrument) }

      # Influxdb Tag
      it{ allow_read_only(InfluxdbTag) }

      # Linked Data
      it{ no_access_allowed(LinkedDatum) }

      # Measured Property
      it{ allow_read_only(MeasuredProperty) }

      # Site Type
      it{ allow_read_only(SiteType) }

      # Topic Category
      it{ allow_read_only(TopicCategory) }

      # Unit
      it{ allow_read_only(Unit) }
    end

    context 'when is registered user with measurements/downloader' do
      let(:user) { FactoryBot.create(:data_creator, roles: [:registered_user, :downloader, :measurements]) }

      # Site
      it{ allow_read_only(Site) }
      it{ is_expected.to be_able_to(:map, Site) }
      it{ is_expected.to be_able_to(:map_markers_geojson, Site) }
      it{ is_expected.to be_able_to(:map_balloon_json, Site) }

      # Instrument
      it{ allow_read_only(Instrument) }

      it{ is_expected.not_to be_able_to(:duplicate, Instrument) }
      it{ is_expected.to be_able_to(:live, Instrument) }
      it{ is_expected.to be_able_to(:simulator, Instrument) }

      # Variable
      it{ allow_read_only(Var) }

      # Measurement Creation
      it{ is_expected.to be_able_to(:create, :measurement) }
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
      it{ is_expected.to be_able_to(:assign_api_key, user) }

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

      # About
      it{ is_expected.to be_able_to(:read, :about) }

      # Dashboard
      it{ is_expected.to be_able_to(:read, :dashboard) }

      # Data Download
      it{ is_expected.to be_able_to(:read, :data) }
      it{ is_expected.to be_able_to(:download, Instrument) }

      # Influxdb Tag
      it{ allow_read_only(InfluxdbTag) }

      # Linked Data
      it{ no_access_allowed(LinkedDatum) }

      # Measured Property
      it{ allow_read_only(MeasuredProperty) }

      # Site Type
      it{ allow_read_only(SiteType) }

      # Topic Category
      it{ allow_read_only(TopicCategory) }

      # Unit
      it{ allow_read_only(Unit) }
    end

    context 'when is an admin with downloader' do
      let(:user) { FactoryBot.create(:data_creator, roles: [:admin, :downloader]) }

      # Site
      it{ is_expected.to be_able_to(:manage, Site) }

      # Instrument
      it{ is_expected.to be_able_to(:manage, Instrument) }

      # Variable
      it{ is_expected.to be_able_to(:manage, Var) }

      # Measurement Creation
      it{ is_expected.not_to be_able_to(:create, :measurement) }
      it{ is_expected.to be_able_to(:delete_test, :measurement) }

      # Profile
      it{ is_expected.to be_able_to(:manage, Profile) }

      # User
      it{ is_expected.to be_able_to(:manage, User) }

      it 'cannot destroy self' do
        user2 = FactoryBot.create(:user)

        is_expected.not_to be_able_to(:destroy, user)
        is_expected.to be_able_to(:destroy, user2)
      end

      # About
      it{ is_expected.to be_able_to(:read, :about) }

      # Dashboard
      it{ is_expected.to be_able_to(:read, :dashboard) }

      # Data Download
      it{ is_expected.to be_able_to(:read, :data) }
      it{ is_expected.to be_able_to(:download, Instrument) }

      # Influxdb Tag
      it{ is_expected.to be_able_to(:manage, InfluxdbTag) }

      # Linked Data
      it{ is_expected.to be_able_to(:manage, LinkedDatum) }

      # Measured Property
      it{ is_expected.to be_able_to(:manage, MeasuredProperty) }

      # Site Type
      it{ is_expected.to be_able_to(:manage, SiteType) }

      # Topic Category
      it{ is_expected.to be_able_to(:manage, TopicCategory) }

      # Unit
      it{ is_expected.to be_able_to(:manage, Unit) }
    end

    context 'when is a site configurator with downloader' do
      let(:user) { FactoryBot.create(:data_creator, roles: [:site_config, :downloader]) }

      # Site
      it{ allow_crud(Site) }
      it{ is_expected.to be_able_to(:map, Site) }
      it{ is_expected.to be_able_to(:map_markers_geojson, Site) }
      it{ is_expected.to be_able_to(:map_balloon_json, Site) }

      # Instrument
      it{ allow_crud(Instrument) }

      it{ is_expected.to be_able_to(:duplicate, Instrument) }
      it{ is_expected.to be_able_to(:live, Instrument) }
      it{ is_expected.to be_able_to(:simulator, Instrument) }

      # Variable
      it{ allow_crud(Var) }

      # Measurement Creation
      it{ is_expected.not_to be_able_to(:create, :measurement) }
      it{ is_expected.to be_able_to(:delete_test, :measurement) }

      # Profile
      it{ allow_crud(Profile) }
      it{ is_expected.to be_able_to(:export_configuration, Profile) }
      it{ is_expected.to be_able_to(:import_configuration, Profile) }
      it{ is_expected.to be_able_to(:export_influxdb, Profile) }
      it{ is_expected.to be_able_to(:import_influxdb, Profile) }
      it{ is_expected.to be_able_to(:test_sending_email, Profile) }

      # User
      it{ allow_read_update(User) }
      it{ is_expected.to be_able_to(:assign_api_key, user) }

      it 'can read other users' do
        user2 = FactoryBot.create(:user)

        is_expected.to be_able_to(:read, user)
        is_expected.to be_able_to(:read, user2)
      end

      it 'cannot update other users' do
        user2 = FactoryBot.create(:user)

        is_expected.to be_able_to(:update, user)
        is_expected.not_to be_able_to(:update, user2)
      end

      # About
      it{ is_expected.to be_able_to(:read, :about) }

      # Dashboard
      it{ is_expected.to be_able_to(:read, :dashboard) }

      # Data Download
      it{ is_expected.to be_able_to(:read, :data) }
      it{ is_expected.to be_able_to(:download, Instrument) }

      # Influxdb Tag
      it{ allow_crud(InfluxdbTag) }

      # Linked Data
      it{ allow_crud(LinkedDatum) }

      # Measured Property
      it{ allow_crud(MeasuredProperty) }

      # Site Type
      it{ allow_crud(SiteType) }

      # Topic Category
      it{ allow_crud(TopicCategory) }

      # Unit
      it{ allow_crud(Unit) }
    end
  end
end
