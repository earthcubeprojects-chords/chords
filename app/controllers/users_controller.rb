class UsersController < ApplicationController
  load_and_authorize_resource

  before_action :authenticate_user!

  def index
  end

  def show
  end

  def edit
  end

  def destroy
    respond_to do |format|
      if @user.destroy
        format.html{ redirect_to users_path, notice: 'User was successfully deleted' }
      else
        format.html{ render :edit, alert: 'User could not be deleted' }
      end
    end
  end

  def update
    respond_to do |format|
      if !current_user.role?(:admin)
        # Don't allow non-admins to modify roles
        params[:user].delete 'roles'
      elsif current_user.id == @user.id
        # (Also) Don't let the current user disable their own admin account!
        if !(params[:user][:roles].include?('admin') || params[:user][:roles].include?(:admin))
          params[:user][:roles] << :admin
        end
      end

      if @user.update(user_params)
        format.html{ redirect_to @user, notice: 'User was successfully updated' }
        # format.json { render :show, status: :ok, location: @user }
        format.json{ respond_with_bip(@user) }
      else
        format.html{ render :edit }
        # format.json { render json: @user.errors, status: :unprocessable_entity }
        format.json{ respond_with_bip(@user) }
      end
    end
  end

  def assign_api_key
    @user = User.where(id: params[:user_id]).first
    @user.api_key = User.generate_api_key
    @user.save!

    redirect_to @user
  end

private
  def user_params
    params.require(:user).permit(:email, roles: [])
  end
end
