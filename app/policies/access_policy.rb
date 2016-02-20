class AccessPolicy
  include AccessGranted::Policy

  def configure

    # The most important admin role, gets checked first

    role :administrator, { is_administrator: true } do
      can [:view, :manage], User
      can [:manage], Profile
      can [:view, :download, :manage], Site
      can [:view, :download, :manage], Instrument
      can [:view, :download, :manage], Var
      can [:view, :download, :manage], Measurement
    end


    role :data_viewer, { is_data_viewer: true } do
      can [:view], Site
      can [:view], Instrument
      can [:view], Var
      can [:view], Measurement

    end

    role :data_downloader, { is_data_downloader: true } do
      can [:download], Site
      can [:download], Instrument
      can [:download], Var
      can [:download], Measurement
    end

    # The basic role. Applies to every user.
    role :registered_user do
      can [:view, :manage], User do |registered_user|
        registered_user.id == user.id
      end
    end

    # Less privileged moderator role
    # role :data_viewer, proc {|u| u.moderator? } do
    #   can [:update, :destroy], Post
    #   can :update, User
    # end

    # role :data_viewer do
    #   can :create, Post
    # 
    #   can [:update, :destroy], Post do |post|
    #     post.user_id == user.id && post.comments.empty?
    #   end
    # end
  end
end