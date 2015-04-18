class UserFile < ActiveRecord::Base
   def list
     @user_files = UserFile.find(:all)
   end
   def show
     @user_file = UserFile.find(params[:name])
   end
   def new
   end
   def create
   end
   def edit
   end
   def update
   end
   def delete
     UserFile.find(params[:name]).destroy
   end
end
