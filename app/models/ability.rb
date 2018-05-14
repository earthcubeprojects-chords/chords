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

    if !user || user.role?(:guest)
      guest_user
    end

    if user.role?(:registered_user)
      registered_user(user)
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
    can :read, :monitor

    cannot :read, User
    can :read, User, id: user.id

    cannot :read, Profile
  end

  def data_downloader(user)
    registered_user(user)
  end

  def measurement_creator(user)
    can :create, Measurement
  end

  def site_configurator(user)
    registered_user(user)
    can :manage, :all

    can :export, Profile
    can :import, Profile

    cannot :manage, User
  end

  def admin(user)
    can :manage, :all

    can :export, Profile
    can :import, Profile
  end
end
