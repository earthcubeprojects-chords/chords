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

    if !user || user.role?(:guest)
      guest_user

      if !profile.secure_data_viewing
        registered_user(nil)
      end

      if !profile.secure_data_download
        data_downloader(nil)
      end
    end

    if user.role?(:registered_user)
      registered_user(user)

      if !profile.secure_data_download
        can :download, Instrument
      end
    end

    if user.role?(:downloader)
      data_downloader(user)
    end

    if user.role?(:measurements)
      measurement_creator(user)
    end

    if user.role?(:site_config)
      site_configurator(user)
    end

    if user.role?(:admin)
      admin(user)
    end
  end

  def guest_user
    can :read, :about
  end

  def registered_user(user)
    can :read, :all

    can :map, Site
    can :map_markers_geojson, Site
    can :map_balloon_json, Site

    can :live, Instrument

    cannot :read, User
    cannot :read, :data

    if user
      can [:read, :update], User, id: user.id
      can :assign_api_key, User, id: user.id
    end

    cannot :read, Profile
    cannot :read, LinkedDatum
  end

  def data_downloader(user)
    registered_user(user)

    can :download, Instrument
    can :read, :data
  end

  def measurement_creator(user)
    can :create, :measurement
  end

  def site_configurator(user)
    registered_user(user)
    can :manage, :all

    can :duplicate, Instrument
    can :simulator, Instrument

    can :delete_test, :measurement

    can :export, Profile
    can :import, Profile

    cannot :manage, User
  end

  def admin(user)
    site_configurator(user)

    can :manage, :all
  end
end
