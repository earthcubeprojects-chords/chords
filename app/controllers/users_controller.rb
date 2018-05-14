class UsersController < ApplicationController
  load_and_authorize_resource

  before_action :authenticate_user!

  def index
  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if !current_user.role?(:admin)
        # Don't allow non-admins to modify roles
        params[:user].delete 'roles'

        # (Also) Don't let the current user disable their own admin account!
        if !params[:user][:roles].include?('admin')
          params[:user][:roles] += ',admin'
        end
      end

      if @user.update(user_params)
        format.html{ redirect_to @user, notice: 'User was successfully updated.' }
        # format.json { render :show, status: :ok, location: @user }
        format.json{ respond_with_bip(@user) }
      else
        format.html{ render :edit }
        # format.json { render json: @user.errors, status: :unprocessable_entity }
        format.json{ respond_with_bip(@user) }
      end
    end
  end

private
  def user_params
    params.require(:user).permit(:email, :roles)
  end
end
