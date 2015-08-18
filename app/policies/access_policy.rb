class AccessPolicy
  include AccessGranted::Policy

  def configure(user)

    # The most important admin role, gets checked first

    role :administrator, { is_administrator: true } do
      can [:view, :manage], User
      can [:manage], Profile
      can [:view, :manage], Site
      can [:view, :manage], Instrument

      can [:view, :manage], Measurement
    end

    # Less privileged moderator role
    # role :data_viewer, proc {|u| u.moderator? } do
    #   can [:update, :destroy], Post
    #   can :update, User
    # end

    # The basic role. Applies to every user.
    # role :data_viewer do
    #   can :create, Post
    # 
    #   can [:update, :destroy], Post do |post|
    #     post.user_id == user.id && post.comments.empty?
    #   end
    # end
  end
end