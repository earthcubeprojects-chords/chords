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

    if !user
      guest_user
    elsif user.is_administrator
      admin
    elsif user.is_data_downloader
      data_downloader
    elsif user.is_data_viewer
      data_viewer
    else
      registered_user
    end
  end

  def guest_user
    can :read, :about
  end

  def registered_user
    guest_user
  end

  def data_viewer
    registered_user
  end

  def data_downloader
    data_viewer
  end

  def admin
    can :manage, :all
  end
end
