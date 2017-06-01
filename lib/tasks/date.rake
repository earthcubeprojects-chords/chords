# class ClientsController < ApplicationController
# 	def index
# 		if params[:status] == "activated"
# 			@clients = Client.activated
# 		else
# 			@clients = Client.inactivated
# 		end
# 	end

# 	def create
# 		@client = Client.new(params[:GET /clients?ids[]=1&ids[]=2&ids[]=3])
# 		if @client.save
# 			redirect_to @client
# 		else
# 			render "new"
# 		end
# 	end
# end

#http://guides.rubyonrails.org/action_controller_overview.html
#LOOK at sec 5.1