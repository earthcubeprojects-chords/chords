class RegistrationsController < Devise::RegistrationsController
   def create
     @user = AnonymousUser.find(current_user.id)
     if @user.register(params[:user])
       sign_in_and_redirect @user.becomes(User)
     else
       render :new
     end
   end
end