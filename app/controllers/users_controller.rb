class UsersController < ApplicationController
  before_action :authenticate_user!

  before_action :set_user, only: [:show, :edit, :update]
  
  def index
    authorize! :manage, current_user

    @users = User.all
  end

  def show
    # @user = User.find(params[:id])

    authorize! :view, @user

    unless @user == current_user
      redirect_to :controller => 'about', :action => 'index'  , :alert => "Access denied."
    end
  end

  # GET /users/1/edit
  def edit
    authorize! :view, @user
  end
  
  
  
  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update

    authorize! :manage, @user
        
    respond_to do |format|

      if (current_user.id == @user.id) 
        # Don't let a non-administrator assign themselves admin/download/viewing priviledges.
        # (Also) Don't let the current user disable their own admin account!
        params[:user].delete "is_administrator"
        if ! current_user.is_administrator
          params[:user].delete "is_data_downloader"
          params[:user].delete "is_data_viewer"
        end
      end   
      

      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        # format.json { render :show, status: :ok, location: @user }
        format.json { respond_with_bip(@user) }
      else
        format.html { render :edit }
        # format.json { render json: @user.errors, status: :unprocessable_entity }
        format.json { respond_with_bip(@user) }
      end
    end
  end  


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(
        :email, :is_administrator, :is_data_viewer, :is_data_downloader
        )
    end
    

end