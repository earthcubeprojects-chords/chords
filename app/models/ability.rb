class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    profile = Profile.first

    if !user
      guest_user(profile, nil)
    elsif user.role?(:guest)
      guest_user(profile, user)
    end

    if !user || user.role?(:guest)
      if !profile.secure_data_viewing
        registered_user(profile, nil)
      end

      if !profile.secure_data_download
        data_downloader(profile, nil)
      end
    end

    if user.role?(:registered_user)
      registered_user(profile, user)

      if !profile.secure_data_download
        can :download, Instrument
      end
    end

    if user.role?(:downloader)
      data_downloader(profile, user)
    end

    if user.role?(:measurements)
      measurement_creator(profile, user)
    end

    if user.role?(:site_config)
      site_configurator(profile, user)
    end

    if user.role?(:admin)
      admin(profile, user)
    end
  end

  def guest_user(profile, user)
    can :read, :about

    cannot :read, User
    cannot :read, :data if profile.secure_data_download

    if user
      can [:read, :update], User, id: user.id
    end
  end

  def registered_user(profile, user)
    can :read, :all

    can :map, Site
    can :map_markers_geojson, Site
    can :map_balloon_json, Site

    can :live, Instrument

    cannot :read, User
    cannot :read, :data if profile.secure_data_download

    if user
      can [:read, :update], User, id: user.id
      can :assign_api_key, User, id: user.id
    end

    cannot :read, Profile
    cannot :read, LinkedDatum
  end

  def data_downloader(profile, user)
    registered_user(profile, user)

    can :download, Instrument
    can :read, :data
  end

  def measurement_creator(profile, user)
    cannot :read, User
    cannot :read, :data

    if user
      can [:read, :update], User, id: user.id
    end

    can :read, :about

    can :create, :measurement
  end

  def site_configurator(profile, user)
    can :manage, :all

    can :map, Site
    can :map_markers_geojson, Site
    can :map_balloon_json, Site

    can :live, Instrument

    cannot :manage, User
    can :read, User

    if user
      can [:update], User, id: user.id
      can :assign_api_key, User, id: user.id
    end

    can :duplicate, Instrument
    can :simulator, Instrument

    can :delete_test, :measurement

    can :export, Profile
    can :import, Profile

    cannot :create, :measurement
  end

  def admin(profile, user)
    site_configurator(profile, user)

    can :manage, :all

    cannot :create, :measurement

    if user
      cannot :destroy, User, id: user.id
    end
  end
end
